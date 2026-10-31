#!/usr/bin/env python3
"""Run the real Lua expedition headlessly; write reproducible JSON, CSV and Markdown.

Use tools/expedition_report.ps1 on Windows to obtain the pinned LuaJIT automatically.
No network, player saves, or simulation-rule changes are involved in reporting.
"""
import argparse
import collections
import csv
import datetime as dt
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent
POLICIES = ('careful', 'peaceful', 'fighter')


def seeds(value):
    result = set()
    try:
        for part in value.split(','):
            bounds = [int(x) for x in part.strip().split(':')]
            if len(bounds) == 1:
                first = last = bounds[0]
            elif len(bounds) == 2:
                first, last = bounds
            else:
                raise ValueError()
            if not 0 <= first <= last <= 2147483646 or last-first >= 1000:
                raise ValueError()
            result.update(range(first, last+1))
        if not result or len(result) > 1000:
            raise ValueError()
        return sorted(result)
    except ValueError:
        raise argparse.ArgumentTypeError('Use seeds such as 1:40,1848 (0..2147483646; at most 1000).')


def policies(value):
    result = [part.strip() for part in value.split(',')]
    if not result or len(result) != len(set(result)) or any(p not in POLICIES for p in result):
        raise argparse.ArgumentTypeError('Choose distinct policies: careful,peaceful,fighter.')
    return result


def bounded(low, high):
    def parse(value):
        try:
            number = int(value)
            if low <= number <= high:
                return number
        except ValueError:
            pass
        raise argparse.ArgumentTypeError(f'Expected an integer from {low} to {high}.')
    return parse


def digest(data):
    return hashlib.sha256(data).hexdigest()


def source_digest(data):
    # Git may check the same text out with CRLF or LF on Windows.
    return digest(data.replace(b'\r\n', b'\n'))


def encoded(data):
    return (json.dumps(data, ensure_ascii=False, sort_keys=True, indent=2, allow_nan=False)+'\n').encode('utf-8')


def write_json(path, data):
    temporary = path.with_suffix(path.suffix+'.tmp')
    temporary.write_bytes(encoded(data))
    temporary.replace(path)


def provenance(lua):
    def git(*args):
        return subprocess.check_output(['git', *args], cwd=ROOT).decode('utf-8').strip()
    files = set()
    for folder in ('simulation', 'content', 'tools/report'):
        files.update((ROOT/folder).rglob('*.lua'))
    files.update(ROOT/name for name in ('services/save.lua', 'tools/expedition_report.py',
        'tools/expedition_report.ps1', 'tools/common.ps1', 'tools/defold-version.json'))
    hashes = {p.relative_to(ROOT).as_posix(): source_digest(p.read_bytes()) for p in sorted(files)}
    hashes['runtime/luajit-64.exe'] = digest(lua.read_bytes())
    dependency = lua.with_name('libwinpthread-1.dll')
    if dependency.is_file():
        hashes['runtime/libwinpthread-1.dll'] = digest(dependency.read_bytes())
    return {'commit': git('rev-parse', 'HEAD'), 'working_tree_changes': bool(git('status', '--porcelain')),
            'source_sha256': digest(encoded(hashes)), 'files': hashes}


def execute(lua, selected_seeds, selected_policies, max_actions, stall_visits, compare):
    command = [str(lua), 'tools/report/main.lua', ','.join(map(str, selected_seeds)),
               ','.join(selected_policies), str(max_actions), str(stall_visits), '1' if compare else '0']
    result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=180)
    if result.returncode:
        raise RuntimeError('Lua report process failed: '+result.stderr.decode('utf-8', errors='replace')[:6000])
    rows = [json.loads(line) for line in result.stdout.decode('utf-8').splitlines() if line.strip()]
    if not rows or len({row['id'] for row in rows}) != len(rows):
        raise RuntimeError('Reporter produced no rows or duplicate run IDs')
    return rows


def csv_row(run):
    t, final, low = run['totals'], run['final'], run['minimum']
    return {'id': run['id'], 'kind': run['kind'], 'seed': run['seed'], 'policy': run['strategy'],
            'status': run['status'], 'outcome': run['outcome'], 'start_day': run['initial_snapshot']['run']['day'],
            'end_day': final['day'], 'elapsed_days': t['days'], 'actions': run['actions'],
            'recovery_actions': t['recovery_actions'], 'recovery_days': t['recovery_days'],
            'food_min': low['food']['value'], 'food_final': final['food'], 'cargo_final': final['cargo'],
            'wagon_min': low['wagon']['value'], 'traveler_min': low['traveler']['value'],
            'crew_energy_min': min(v['energy']['value'] for v in run['crew_minimum'].values()),
            'crew_condition_min': min(v['condition']['value'] for v in run['crew_minimum'].values()),
            'food_decreases': t['food_decreases'], 'energy_decreases': t['energy_decreases'],
            'condition_decreases': t['condition_decreases'], 'combat_exchanges': t['combat_exchanges'],
            'travel_ticks': t['travel_ticks'], 'longest_travel_stretch':t['longest_travel_stretch'], 'decision_gates': len(run['waits']),
            'failure': run.get('failure', {}).get('message', '')}


def write_csv(path, rows):
    if not rows:
        return
    with path.open('w', encoding='utf-8', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def paired_summary(rows):
    starts = collections.defaultdict(dict)
    for run in rows:
        if run['kind']=='comparison':
            starts[(run['parent'],run['encounter']['index'])][run['encounter']['method']]=run
    samples=collections.defaultdict(list)
    for branches in starts.values():
        first=next(iter(branches.values()))
        if any(r['initial_snapshot']!=first['initial_snapshot'] for r in branches.values()):
            raise RuntimeError('Comparison branches have different initial states.')
        peaceful=branches.get('peaceful')
        if not peaceful or peaceful['status']!='completed':
            continue
        for method in ('fight','withdraw'):
            alternative=branches.get(method)
            if alternative and alternative['status']=='completed':
                samples[(first['encounter']['event'],method)].append((alternative,peaceful))
    return [{'event':event,'choice_vs_peaceful':method,'matched_starts':len(pairs),
             'on_time_gained':sum(a['outcome']=='delivered' and b['outcome']!='delivered' for a,b in pairs),
             'on_time_lost':sum(a['outcome']!='delivered' and b['outcome']=='delivered' for a,b in pairs),
             'median_extra_days':statistics.median(a['final']['day']-b['final']['day'] for a,b in pairs),
             'median_extra_recovery_days':statistics.median(a['totals']['recovery_days']-b['totals']['recovery_days'] for a,b in pairs),
             'median_cargo_difference':statistics.median(a['final']['cargo']-b['final']['cargo'] for a,b in pairs)}
            for (event,method),pairs in sorted(samples.items())]


def summarize(rows, source, repeatable):
    journeys = [r for r in rows if r['kind']=='journey']
    branches = [r for r in rows if r['kind']=='comparison']
    lines = ['# Full-expedition report', '', f"Source: `{source['commit']}`; working tree changed: `{source['working_tree_changes']}`.",
             f"Source/runtime fingerprint: `{source['source_sha256']}`.",
             f"Exact repeat run: **{'PASS' if repeatable else 'FAIL'}**. {len(journeys)} full journeys; {len(branches)} matched continuation runs.", '',
             '## Full-journey policies', '', '| Policy | Runs | Delivered | Late | Rescued / returned | Failed | Median ending day | Recovery days |',
             '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
    for name in POLICIES:
        group = [r for r in journeys if r['strategy']==name]
        if not group:
            continue
        complete = [r for r in group if r['status']=='completed']
        counts = collections.Counter(r['outcome'] for r in complete)
        ending = f"{statistics.median(r['final']['day'] for r in complete):g}" if complete else '—'
        lines.append(f"| {name} | {len(group)} | {counts['delivered']} | {counts['late']} | {counts['rescued']+counts['returned']} | {len(group)-len(complete)} | {ending} | {sum(r['totals']['recovery_days'] for r in complete)} |")
    pairs=paired_summary(rows)
    if pairs:
        lines += ['', '## Matched alternatives versus peaceful resolution', '',
                  '| Event | Alternative | Matched starts | On-time gained | On-time lost | Median extra days | Median extra recovery days | Median cargo difference |',
                  '| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |']
        for p in pairs:
            lines.append('| '+' | '.join(str(value) for value in p.values())+' |')
        lines += ['', 'Positive extra days mean later arrival. Cargo differences are percentage points. Gained/lost counts compare on-time delivery within each matched pair. Only pairs with both branches completed are included.']
    lines += ['', '## Reading the evidence', '',
              '- Full-journey policies also choose different routes and events. Their delivery rates do not isolate the cost of combat.',
              '- Matched branches clone the complete naturally reached encounter snapshot, including pending rolls and RNG streams. Only the current intervention changes; the subsequent policy is the same within each comparison.',
              '- Comparisons are selected from encounters these policies actually reach with battle available. Starts may repeat across policies; these are not independent trials or a random sample of every crew. comparison_points records when a peaceful option is unavailable.',
              '- Resource minima are sampled at command boundaries. Decreases/increases sum signed command deltas; they are not gross consumption inside a command. Gathering can spend meals and gain food in one action.',
              '- Recovery counts cover rest, treatment, repair and river waiting. Event delays and combat detours remain visible under days_by_command and individual steps.',
              '- Decision gates record entry into a mode needing input, including the starting mode. longest_travel_stretch counts consecutive travel-day commands. The headless bot does not measure human waiting, audio, usability, or the 20–35 minute playtime target.',
              '- runs.csv contains summaries; comparisons.csv contains immediate encounter deltas and downstream results. Each runs/*.json file contains initial/final diagnostic snapshots, every command and argument, before/after resources, deltas, messages, minima, gates and failure context.', '',
              '## Reproduce', '', '```powershell', './tools/expedition_report.ps1 -Seeds "1:40" -Compare', './tools/expedition_report.ps1 -Replay "reports/<folder>/runs/<id>.json"', '```', '',
              'Replay requires the same source/runtime fingerprint and checks the complete recorded result. Diagnostic JSON snapshots are not player-save files; reproduction regenerates the state through the real commands.', '']
    failures = [r for r in rows if r['status']!='completed']
    if failures:
        lines += ['## Failures', '']+[f"- `{r['id']}`: {r['status']} at action {r.get('failure',{}).get('action')}: {r.get('failure',{}).get('message','')}" for r in failures]
    return '\n'.join(lines)+'\n'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lua', type=Path, default=ROOT/'.tools/luajit-64.exe')
    parser.add_argument('--seeds', type=seeds, default=seeds('1:40'))
    parser.add_argument('--strategies', type=policies, default=list(POLICIES))
    parser.add_argument('--compare', action='store_true')
    parser.add_argument('--max-actions', type=bounded(1,10000), default=250)
    parser.add_argument('--stall-visits', type=bounded(2,100), default=3)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--replay', type=Path)
    args = parser.parse_args(argv)
    lua = args.lua.resolve()
    if not lua.is_file():
        parser.error('LuaJIT is missing; run tools/expedition_report.ps1 first.')
    source = provenance(lua)
    expected = None
    if args.replay:
        try:
            expected = json.loads(args.replay.read_text(encoding='utf-8'))
            if expected.get('schema')!=1 or not isinstance(expected.get('run'),dict):
                raise ValueError('Expected an expedition run report, schema 1.')
            expected['source']['source_sha256'];expected['run']['reproduce'];expected['options']['max_actions'];expected['options']['stall_visits'];expected['options']['compare']
        except (OSError, ValueError, KeyError, TypeError) as error:
            parser.error('Cannot read replay report: '+str(error))
        if expected['source']['source_sha256'] != source['source_sha256']:
            parser.error('Replay source/runtime fingerprint differs; use the recorded source and runtime.')
        spec = expected['run']['reproduce']
        if type(spec['seed']) is not int:
            parser.error('Replay seed must be an integer.')
        args.seeds = seeds(str(spec['seed']));args.strategies = policies(spec['strategy'])
        args.compare = bool(expected['options']['compare']) or 'encounter' in spec
        args.max_actions = bounded(1,10000)(str(expected['options']['max_actions']))
        args.stall_visits = bounded(2,100)(str(expected['options']['stall_visits']))
    now = dt.datetime.now(dt.timezone.utc)
    output = (args.output or ROOT/'reports'/now.strftime('expedition-%Y%m%d-%H%M%S-%f')).resolve()
    if output.exists():
        parser.error('Output folder already exists; choose a new folder to preserve its evidence.')
    output.mkdir(parents=True)
    (output/'runs').mkdir()
    options = {'seeds':args.seeds, 'policies':args.strategies, 'compare':args.compare,
               'max_actions':args.max_actions, 'stall_visits':args.stall_visits}
    manifest = {'schema':1, 'created_at':now.isoformat(), 'source':source, 'options':options, 'status':'running'}
    write_json(output/'manifest.json', manifest)
    started = time.monotonic()
    try:
        rows = execute(lua,args.seeds,args.strategies,args.max_actions,args.stall_visits,args.compare)
        repeated = execute(lua,args.seeds,args.strategies,args.max_actions,args.stall_visits,args.compare)
        if provenance(lua)['source_sha256']!=source['source_sha256']:
            raise RuntimeError('Source/runtime changed while reporting; rerun from a stable checkout.')
        repeatable = rows == repeated
        if expected:
            rows = [r for r in rows if r['id']==expected['run']['id']]
            if len(rows)!=1 or rows[0] != expected['run']:
                raise RuntimeError('Replay differs from the recorded commands or outcomes.')
        brief_source = {k:v for k,v in source.items() if k!='files'}
        for row in rows:
            write_json(output/'runs'/(row['id']+'.json'), {'schema':1,'source':brief_source,'options':options,'run':row})
        write_csv(output/'runs.csv', [csv_row(r) for r in rows])
        comparisons = []
        for row in rows:
            if row['kind']!='comparison':
                continue
            immediate = row.get('intervention_result',{}).get('delta',{})
            comparisons.append({'parent':row['parent'], 'encounter':row['encounter']['index'], 'event':row['encounter']['event'],
                'method':row['encounter']['method'], 'start_day':row['initial_snapshot']['run']['day'],
                'immediate_days':immediate.get('days',''), 'immediate_food':immediate.get('food',''), 'immediate_cargo':immediate.get('cargo',''),
                'immediate_energy':sum(c.get('energy',0) for c in immediate.get('crew',[])),
                'status':row['status'], 'outcome':row['outcome'], 'ending_day':row['final']['day'],
                'ending_cargo':row['final']['cargo'], 'downstream_recovery_days':sum(s['delta']['days'] for s in row['steps'] if s['index']>row.get('intervention_result',{}).get('action',row['actions']) and (s['command'] in ('rest','repair','treat') or s['command']=='river' and s['args'].get('method')=='wait'))})
        write_csv(output/'comparisons.csv',comparisons)
        write_csv(output/'paired-summary.csv',paired_summary(rows))
        (output/'summary.md').write_text(summarize(rows,source,repeatable),encoding='utf-8')
        manifest.update(status='complete' if repeatable and all(r['status']=='completed' for r in rows) else 'failed',
                        exact_repeat=repeatable, run_count=len(rows), execution_seconds=round(time.monotonic()-started,3),
                        replay_matches=True if expected else None)
        write_json(output/'manifest.json',manifest)
        print(f"Report: {output}\n{len(rows)} runs; exact repeat {'passed' if repeatable else 'FAILED'}; status {manifest['status']}")
        return 0 if manifest['status']=='complete' else 1
    except Exception as error:
        manifest.update(status='failed',error=str(error),execution_seconds=round(time.monotonic()-started,3))
        write_json(output/'manifest.json',manifest)
        print(f'Report failed: {error}\nEvidence: {output}',file=sys.stderr)
        return 1


if __name__=='__main__':
    sys.exit(main())
