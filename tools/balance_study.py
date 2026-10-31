"""Run the bounded S5 comparison with the existing Lua report runner (three workers)."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import datetime as dt
import json
from pathlib import Path
import subprocess
import time
from expedition_report import provenance, source_digest, digest, encoded, write_json

ROOT = Path(__file__).resolve().parent.parent

def source(lua):
    data = provenance(lua)
    for name in ('tools/balance_study.lua', 'tools/balance_study.py'):
        data['files'][name] = source_digest((ROOT/name).read_bytes())
    data['source_sha256'] = digest(encoded(data['files']))
    return data

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seeds', type=int, default=12)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if not 1 <= args.seeds <= 40:
        parser.error('Use 1 through 40 seeds')
    folder = args.output.resolve(); folder.mkdir(parents=True, exist_ok=False)
    lua = ROOT/'.tools/luajit-64.exe'
    before = source(lua); start = time.perf_counter()
    def worker(shard):
        path = folder/f'part-{shard}.json'
        result = subprocess.run([str(lua), 'tools/balance_study.lua', str(path), str(args.seeds), str(shard)], cwd=ROOT, capture_output=True, text=True)
        (folder/f'part-{shard}.log').write_text(result.stderr+result.stdout, encoding='utf-8')
        if result.returncode:
            raise RuntimeError(f'Study shard {shard} failed; see {folder}')
        return json.loads(path.read_text(encoding='utf-8'))
    with ThreadPoolExecutor(max_workers=3) as pool:
        parts = list(pool.map(worker, (1, 2, 3)))
    assert source(lua)['source_sha256'] == before['source_sha256'], 'Study inputs changed while running'
    combined = {key: parts[0][key] for key in ('schema','policy','cohort','seeds','crews','configs','repeated_exactly')}
    for key in ('rows','paired','samples'): combined[key] = [row for part in parts for row in part[key]]
    combined['runs'] = len(combined['rows']); combined['matched_starts'] = len(combined['paired'])
    combined['executions'] = sum(p['executions'] for p in parts)
    write_json(folder/'results.json', combined)
    write_json(folder/'manifest.json', {'source':before,'seeds':args.seeds,'workers':3,'completed':True,'repeated_exactly':True,'seconds':time.perf_counter()-start,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'result_sha256':digest((folder/'results.json').read_bytes())})
    print(json.dumps({k:combined[k] for k in ('runs','matched_starts','executions','repeated_exactly')}))

if __name__ == '__main__': main()
