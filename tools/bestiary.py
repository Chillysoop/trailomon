"""Validate the authoring ledger and render its read-only owner catalogue. Stdlib only."""
import argparse
import html
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
INDEX = ROOT / 'docs/bestiary/index.json'
PAGE = ROOT / 'reviews/creature-index.html'
EXISTING = ('brindlehorn', 'reedskipper', 'loamling', 'bellmoth', 'cindercoil', 'slatewhorl')
REQUIRED = {'index_id', 'region_id', 'design_status', 'species_id', 'name', 'game_status',
            'kit_status', 'art_status', 'role', 'body', 'habitat', 'diet', 'ecology', 'behavior',
            'encounter', 'recruitment', 'active', 'passive', 'emits', 'responds_to',
            'counterplay', 'tradeoff', 'integration', 'related_species'}


def runtime_roster():
    source = (ROOT / 'content/species.lua').read_text(encoding='utf-8')
    return dict(re.findall(r'^\s+(\w+)\s*=\s*\{name="([^"]+)"', source, re.MULTILINE))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate(data, roster=None):
    roster = runtime_roster() if roster is None else roster
    require(isinstance(data, dict) and data.get('schema') == 1, 'Unsupported ledger schema')
    require(type(data.get('minimum_species')) is int and data['minimum_species'] >= 300, 'Minimum is 300 species')
    require(isinstance(data.get('regions'), list) and data['regions'], 'Missing regions')
    regions, allocations = {}, {}
    for r in data['regions']:
        require(isinstance(r, dict) and set(r) == {'id', 'name', 'environment', 'first', 'last'}, 'Invalid region fields')
        require(all(isinstance(r[k], str) and r[k].strip() for k in ('id', 'name', 'environment')), 'Empty region text')
        require(r['id'] not in regions and type(r['first']) is int and type(r['last']) is int and 1 <= r['first'] <= r['last'] <= 999, 'Invalid region allocation')
        regions[r['id']] = r
        for n in range(r['first'], r['last'] + 1):
            require(n not in allocations, 'Overlapping region allocation')
            allocations[n] = r['id']
    require(set(allocations) == set(range(1, max(allocations) + 1)), 'Gaps in index allocation')
    require(len(allocations) >= data['minimum_species'], 'Not enough allocated slots')
    require(isinstance(data.get('verbs'), dict) and data['verbs'] and all(isinstance(v, str) and v.strip() for v in data['verbs'].values()), 'Missing behavior vocabulary')
    require(isinstance(data.get('entries'), list) and len(data['entries']) == len(allocations), 'Missing or extra index records')
    seen, species, names, implemented, samples = set(), {}, set(), set(), set()
    for e in data['entries']:
        require(isinstance(e, dict) and isinstance(e.get('index_id'), str), 'Invalid entry')
        require(re.fullmatch(r'TR-\d{3}', e['index_id']) is not None, 'Invalid index ID')
        n = int(e['index_id'][3:])
        require(n in allocations and n not in seen and e.get('region_id') in regions, 'Duplicate or unallocated ID/region')
        seen.add(n)
        if e.get('design_status') == 'reserved':
            require(set(e) == {'index_id', 'region_id', 'design_status'}, 'Reserved slots must not masquerade as species')
            require(e['region_id'] == allocations[n], 'Reserved allocation changed')
            continue
        require(e.get('design_status') == 'brief' and set(e) == REQUIRED, 'Unexpected or missing brief fields')
        require(isinstance(e['species_id'], str) and re.fullmatch('[a-z][a-z0-9_]*', e['species_id']) is not None, 'Invalid species slug')
        require(e['species_id'] not in species and isinstance(e['name'], str) and e['name'].casefold() not in names, 'Duplicate species identity')
        species[e['species_id']] = e
        names.add(e['name'].casefold())
        for field in ('name', 'role', 'body', 'habitat', 'diet', 'ecology', 'behavior', 'encounter', 'counterplay', 'tradeoff', 'integration'):
            require(isinstance(e[field], str) and e[field].strip(), f"{e['index_id']}: missing {field}")
        require(e['game_status'] in ('implemented', 'planned') and e['kit_status'] in ('sample', 'proposed') and e['art_status'] in ('existing', 'deferred'), 'Unsupported production status')
        require(e['recruitment'] in ('existing', 'planned_companion', 'observation_only'), 'Unsupported recruitment status')
        if e['game_status'] == 'implemented':
            implemented.add(e['species_id'])
            require(roster.get(e['species_id']) == e['name'] and e['recruitment'] == 'existing', 'False implemented claim')
        else:
            require(e['art_status'] == 'deferred' and e['kit_status'] == 'proposed' and e['recruitment'] != 'existing', 'Planned species claims existing assets/kit/recruitment')
        if e['kit_status'] == 'sample':
            samples.add(e['species_id'])
            require(e['game_status'] == 'implemented', 'Sample kit has no implemented species')
        for label in ('active', 'passive'):
            k = e[label]
            require(isinstance(k, dict) and set(k) == {'name', 'behavior', 'trigger', 'bound'} and all(isinstance(v, str) and v.strip() for v in k.values()), 'Kit requires behavior, trigger and bound')
        for label in ('emits', 'responds_to'):
            require(isinstance(e[label], list) and e[label] and all(isinstance(v, str) and v in data['verbs'] for v in e[label]) and len(e[label]) == len(set(e[label])), 'Unknown or duplicate behavior event')
        require(isinstance(e['related_species'], list) and all(isinstance(v, str) for v in e['related_species']), 'Invalid ecology references')
    require(implemented == set(roster), 'Implemented roster differs from game')
    for n, slug in enumerate(EXISTING, 1):
        require(slug in species and species[slug]['index_id'] == f'TR-{n:03}', 'Existing index identity changed')
    # Only actual companion entries, excluding the raider/caller enemy appearances.
    source = (ROOT / 'content/ambush.lua').read_text(encoding='utf-8')
    sample_species = {s for key, s in re.findall(r'(\w+)=\{species="([^"]+)"', source) if key not in ('raider', 'caller')}
    require(samples == sample_species, 'Sample kit claim differs from game')
    for e in species.values():
        require(all(slug in species and slug != e['species_id'] for slug in e['related_species']), 'Unknown/self ecology reference')
    return {'slots': len(seen), 'briefs': len(species), 'reserved': len(seen)-len(species), 'implemented': len(implemented), 'sample_kits': len(samples)}


def render(data):
    counts = validate(data)
    esc = html.escape
    regions = {r['id']: r for r in data['regions']}
    briefs = [e for e in data['entries'] if e['design_status'] == 'brief']
    lookup = {e['species_id']: e for e in briefs}
    sections = []
    for e in briefs:
        status = ('Existing species / S28 companion kit' if e['kit_status'] == 'sample' else
                  ('Existing species / proposed repeatable kit' if e['game_status'] == 'implemented' else 'New species brief / not in game'))
        rows = [('Body', e['body']), ('Habitat', e['habitat']), ('Diet', e['diet']), ('Why it lives this way', e['ecology']),
                ('Watch for', e['behavior']), ('Encounter', e['encounter'])]
        fields = ''.join(f'<dt>{esc(k)}</dt><dd>{esc(v)}</dd>' for k,v in rows)
        kits = ''.join(f'<h3>{esc(kind.title())}: {esc(e[kind]["name"])}</h3><p>{esc(e[kind]["behavior"])}</p><p class="muted"><strong>Trigger:</strong> {esc(e[kind]["trigger"])} <strong>Bound:</strong> {esc(e[kind]["bound"])}</p>' for kind in ('active','passive'))
        relatives = ', '.join(f'<a href="#{esc(lookup[s]["index_id"])}">{esc(lookup[s]["name"])}</a>' for s in e['related_species']) or 'No named link in this first brief.'
        text = json.dumps(e, ensure_ascii=False).casefold()
        sections.append(f'''<details class="species" id="{esc(e['index_id'])}" data-region="{esc(e['region_id'])}" data-status="{esc(e['game_status'])}" data-search="{esc(text, quote=True)}">
<summary><span class="code">{esc(e['index_id'])}</span> {esc(e['name'])}<span class="status">{esc(status)}</span></summary>
<div class="entry"><p class="role">{esc(e['role'])}</p><dl>{fields}</dl>{kits}
<p><strong>Counterplay:</strong> {esc(e['counterplay'])}</p><p><strong>Tradeoff:</strong> {esc(e['tradeoff'])}</p>
<p class="muted">Does: {esc(', '.join(e['emits']))}. Responds to: {esc(', '.join(e['responds_to']))}. These are actions, not classes.</p>
<p><strong>Ecological links:</strong> {relatives}</p><p><strong>Production:</strong> {esc(e['integration'])}</p>
<p class="muted">Recruitment: {esc(e['recruitment'].replace('_',' '))}. Art: {esc(e['art_status'])}. Region: {esc(regions[e['region_id']]['name'])}.</p></div></details>''')
    options = ''.join(f'<option value="{esc(r["id"])}">{esc(r["name"])}</option>' for r in data['regions'])
    allocations = ''.join(f'<li><strong>{esc(r["name"])}</strong> / TR-{r["first"]:03}–TR-{r["last"]:03}<br>{esc(r["environment"])}</li>' for r in data['regions'])
    page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Trailomon — Creature field ledger</title><link rel="icon" href="data:,"><link rel="stylesheet" href="review.css">
<style>body{padding-bottom:48px}main{max-width:900px}.filters{display:flex;gap:16px;flex-wrap:wrap;margin:28px 0 12px}.filters>div{flex:1;min-width:180px}input,select{width:100%;min-height:44px;padding:9px;border:1px solid var(--rule);background:var(--paper);color:var(--ink);font:inherit}.species{border-top:1px solid var(--rule);padding:16px 0;scroll-margin-top:16px}.species summary{cursor:pointer;font-size:20px;font-weight:650;min-height:44px}.status{display:block;font-size:13px;font-weight:400;color:var(--muted);margin-left:20px}.entry{padding-left:20px}dt{font-weight:700;margin-top:14px}dd{margin:3px 0 0}.entry h3{font-size:17px;margin-top:22px}.muted{color:var(--muted)}.allocation li{margin:15px 0}[hidden]{display:none!important}.count{font-variant-numeric:tabular-nums}@media(max-width:480px){.entry{padding-left:0}.filters{gap:8px}.filters>div{min-width:100%}}</style></head><body><main>
<p class="eyebrow">Trailomon / Authoring ledger / November 1, 2026</p><h1>A country full of creatures.</h1>
<p class="lede">A first set of biology-led identities for the approved ability-first direction. No universal type chart. No creature-created terrain effects.</p>
<p class="notice count">COUNTS</p><p>These are first design briefs, not 24 playable kits. The final target remains at least 300 distinct implemented species. Farther regions are planned; the current game still follows the Fernwake–Lantern route. Art remains deferred.</p>
<p><strong>Decisions recorded:</strong> B1/B2/B4/B5/B6/B7/B8 approved. B3 rejected. This is a read-only deliverable; no repeat vote is needed.</p>
<div class="filters"><div><label for="search">Find a name, behavior or diet</label><input id="search" type="search" placeholder="Try: predator, shield, eggs"></div><div><label for="region">Region</label><select id="region"><option value="">All regions</option>OPTIONS</select></div><div><label for="production">Production</label><select id="production"><option value="">All briefs</option><option value="implemented">Existing species</option><option value="planned">New species briefs</option></select></div></div>
<p id="shown" class="muted" aria-live="polite"></p><p id="empty" hidden>No matching briefs. <button id="reset" type="button">Clear filters</button></p>
SECTIONS
<details class="allocation"><summary>Where the remaining index entries belong</summary><p>276 slots currently have no authored species. Reservations are capacity planning and do not count as creatures. Index IDs remain stable even if a later design moves to another region.</p><ul>ALLOCATIONS</ul><p>Next authoring batches contain 20–30 distinct species at a time. Implement regional subsets after their combat and encounter mechanics work. Recolors and empty slots never inflate the roster.</p></details>
</main><script>
(() => { const $=id=>document.getElementById(id), entries=[...document.querySelectorAll('.species')];
function filter(){const q=$('search').value.trim().toLowerCase(),r=$('region').value,p=$('production').value;let n=0;entries.forEach(e=>{e.hidden=!!((q&&!e.dataset.search.includes(q))||(r&&e.dataset.region!==r)||(p&&e.dataset.status!==p));if(!e.hidden)n++;});$('shown').textContent=n+' of '+entries.length+' briefs';$('empty').hidden=n!==0;}
function reset(){$('search').value='';$('region').value='';$('production').value='';filter();}
function anchor(){const e=document.getElementById(location.hash.slice(1));if(e&&e.classList.contains('species')){reset();e.open=true;e.scrollIntoView();}}
['search','region','production'].forEach(id=>$(id).addEventListener('input',filter));$('reset').onclick=reset;window.addEventListener('hashchange',anchor);filter();anchor();})();
</script></body></html>'''
    return (page.replace('COUNTS', f"<strong>{counts['briefs']} briefs</strong> / {counts['implemented']} species in game / {counts['sample_kits']} S28 companion kits / {counts['reserved']} unfilled slots")
            .replace('OPTIONS', options).replace('SECTIONS', '\n'.join(sections)).replace('ALLOCATIONS', allocations)
            .replace('276 slots', f"{counts['reserved']} slots"))


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args=parser.parse_args()
    data=json.loads(INDEX.read_text(encoding='utf-8'))
    counts=validate(data)
    output=render(data)
    if args.check:
        require(PAGE.exists() and PAGE.read_text(encoding='utf-8') == output, 'Generated ledger is stale; run python tools/bestiary.py')
    else:
        PAGE.write_text(output, encoding='utf-8')
    print(json.dumps(counts))


if __name__ == '__main__':
    main()
