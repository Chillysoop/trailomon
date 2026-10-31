import csv
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('expedition_report', ROOT/'tools/expedition_report.py')
reporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reporter)


class ReportTests(unittest.TestCase):
    def setUp(self):
        parent = (ROOT/'.tools').resolve()
        parent.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='report-tests-', dir=parent)
        self.root = Path(self.temp.name).resolve()
        self.assertTrue(self.root.is_relative_to(parent))
        self.addCleanup(self.temp.cleanup)

    def run_cli(self, name, *arguments, expected=0):
        folder = self.root/name
        result = subprocess.run([sys.executable, str(ROOT/'tools/expedition_report.py'),
            '--output',str(folder),*arguments],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',timeout=60)
        self.assertEqual(result.returncode,expected,result.stdout+result.stderr)
        return folder

    def test_input_bounds(self):
        self.assertEqual(reporter.source_digest(b'one\r\ntwo\r\n'),reporter.source_digest(b'one\ntwo\n'))
        self.assertEqual(reporter.seeds('3,1:2,3'),[1,2,3])
        for value in ('-1','2:1','1:999999','1:2:3','x','2147483647'):
            with self.assertRaises(reporter.argparse.ArgumentTypeError):
                reporter.seeds(value)
        with self.assertRaises(reporter.argparse.ArgumentTypeError):
            reporter.policies('fighter,unknown')

    def test_reports_replay_and_matched_initial_states(self):
        folder = self.run_cli('report with spaces','--seeds','1','--compare')
        manifest=json.loads((folder/'manifest.json').read_text())
        self.assertEqual(manifest['status'],'complete');self.assertTrue(manifest['exact_repeat'])
        rows=[json.loads(p.read_text()) for p in sorted((folder/'runs').glob('*.json'))]
        self.assertEqual(len([r for r in rows if r['run']['kind']=='journey']),3)
        groups={}
        for data in rows:
            r=data['run']
            self.assertEqual(r['status'],'completed')
            self.assertEqual(len(r['steps']),r['actions'])
            if r['kind']=='comparison':
                groups.setdefault((r['parent'],r['encounter']['index']),[]).append(r)
        self.assertTrue(groups)
        for group in groups.values():
            self.assertEqual({r['encounter']['method'] for r in group},{'fight','peaceful','withdraw'})
            self.assertTrue(all(r['initial_snapshot']==group[0]['initial_snapshot'] for r in group))
        with (folder/'runs.csv').open(newline='') as stream:
            self.assertEqual(len(list(csv.DictReader(stream))),len(rows))
        self.assertTrue((folder/'comparisons.csv').is_file())
        self.assertTrue((folder/'paired-summary.csv').is_file())
        pairs=reporter.paired_summary([r['run'] for r in rows])
        self.assertTrue(all(p['matched_starts']>0 and p['on_time_gained']+p['on_time_lost']<=p['matched_starts'] for p in pairs))
        self.assertIn('not gross consumption',(folder/'summary.md').read_text())
        for index,name in enumerate(('seed-1-careful.json','seed-1-fighter-encounter-1-withdraw.json')):
            replay=self.run_cli('replay-'+str(index),'--replay',str(folder/'runs'/name))
            self.assertTrue(json.loads((replay/'manifest.json').read_text())['replay_matches'])

    def test_failures_keep_evidence_and_do_not_overwrite(self):
        folder=self.run_cli('limited','--seeds','1','--strategies','careful','--max-actions','1',expected=1)
        run=json.loads((folder/'runs/seed-1-careful.json').read_text())['run']
        self.assertEqual(run['status'],'action_limit');self.assertEqual(run['failure']['action'],1)
        prior=(folder/'manifest.json').read_bytes()
        self.run_cli('limited','--seeds','1',expected=2)
        self.assertEqual((folder/'manifest.json').read_bytes(),prior)

    def test_replay_detects_changed_evidence_and_source(self):
        folder=self.run_cli('original','--seeds','1','--strategies','careful')
        path=folder/'runs/seed-1-careful.json';data=json.loads(path.read_text())
        data['run']['steps'][0]['command']='tampered'
        path.write_text(json.dumps(data))
        failed=self.run_cli('changed-trace','--replay',str(path),expected=1)
        self.assertIn('Replay differs',json.loads((failed/'manifest.json').read_text())['error'])
        data['source']['source_sha256']='different';path.write_text(json.dumps(data))
        self.run_cli('changed-source','--replay',str(path),expected=2)

    def test_paired_summary_uses_matching_starts_and_signed_differences(self):
        rows=[]
        for index,days in enumerate(((25,26),(28,26))):
            for method,day in zip(('fight','peaceful'),days):
                rows.append({'kind':'comparison','parent':'sample','encounter':{'index':index,'method':method,'event':'scavengers'},
                    'initial_snapshot':{'day':1},'status':'completed','outcome':'delivered' if day<=26 else 'late',
                    'final':{'day':day,'cargo':80 if method=='fight' else 90},'totals':{'recovery_days':1 if method=='fight' else 0}})
        summary=reporter.paired_summary(rows)[0]
        self.assertEqual(summary['matched_starts'],2)
        self.assertEqual(summary['on_time_gained'],0);self.assertEqual(summary['on_time_lost'],1)
        self.assertEqual(summary['median_extra_days'],0.5)
        self.assertEqual(summary['median_extra_recovery_days'],1)
        self.assertEqual(summary['median_cargo_difference'],-10)
        rows[0]['initial_snapshot']={'day':2}
        with self.assertRaises(RuntimeError):
            reporter.paired_summary(rows)


if __name__=='__main__':
    unittest.main()
