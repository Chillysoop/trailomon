"""Windows launcher selection, without opening games or accessing player saves."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'tools' / 'play.ps1'


@unittest.skipUnless(os.name == 'nt', 'Windows desktop launcher')
class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='trailomon launcher ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / '.tools').mkdir()
        self.old = self.bundle('Windows-old', '2026-11-01T00:00:00Z')
        self.new = self.bundle('Windows-new', '2026-11-03T00:00:00Z')

    def bundle(self, name, date):
        p = self.root / 'dist' / name / 'Trailomon'
        p.mkdir(parents=True)
        for file in ('Trailomon.exe', 'game.arcd', 'game.arci', 'game.dmanifest', 'game.projectc'):
            (p / file).write_bytes(b'fixture')
        (p / 'build-info.json').write_text(json.dumps({'game': 'Trailomon', 'platform': 'windows-x86_64', 'built_at': date}), encoding='utf-8')
        return p

    def pointer(self, path):
        (self.root / '.tools' / 'latest-bundle.txt').write_text(str(path) + '\n', encoding='utf-8-sig')

    def resolve(self):
        return subprocess.run(['powershell.exe', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', str(SCRIPT), '-ResolveOnly', '-ProjectRoot', str(self.root)], capture_output=True, text=True)

    def assert_target(self, result, bundle):
        self.assertEqual(result.returncode, 0, result.stderr)
        # Windows may expand RUNNER~1 to runneradmin; compare the actual file.
        self.assertTrue(Path(result.stdout.strip()).samefile(bundle / 'Trailomon.exe'))

    def test_same_launcher_follows_changed_completed_build_pointer(self):
        for bundle in (self.old, self.new):
            self.pointer(bundle)
            result = self.resolve()
            self.assert_target(result, bundle)

    def test_missing_or_stale_pointer_finds_newest_complete_bundle(self):
        for pointer in (None, self.root / 'deleted'):
            if pointer:
                self.pointer(pointer)
            self.assert_target(self.resolve(), self.new)

    def test_incomplete_and_external_bundles_are_not_launched(self):
        (self.new / 'game.arcd').unlink()
        self.pointer(self.new)
        self.assert_target(self.resolve(), self.old)
        self.pointer(self.root.parent)
        self.assert_target(self.resolve(), self.old)

    def test_missing_game_has_clear_failure(self):
        for folder in (self.old, self.new):
            (folder / 'Trailomon.exe').unlink()
        result = self.resolve()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('No complete Trailomon build', result.stderr)


if __name__ == '__main__':
    unittest.main()
