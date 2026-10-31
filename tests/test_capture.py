"""The capture mirror must isolate production files and retain native caches."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools import capture_prepare as capture


class CaptureProjectTests(unittest.TestCase):
    def setUp(self):
        scratch = capture.ROOT / ".tools"
        scratch.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=scratch)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.project = self.root / ".tools" / "capture-project"
        (self.root / "game.project").write_text("[project]\ntitle = Player\n")
        (self.root / ".defignore").write_text("/.tools\n")
        (self.root / "ui").mkdir()
        (self.root / "ui" / "screens.lua").write_text("return {}")
        for name, value in [("ROOT", self.root), ("PROJECT", self.project)]:
            patcher = patch.object(capture, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)
        patcher = patch.object(capture.subprocess, "check_output", return_value=b"test-revision")
        patcher.start()
        self.addCleanup(patcher.stop)

    def prepare(self):
        with contextlib.redirect_stdout(io.StringIO()):
            capture.prepare()

    def test_mirror_preserves_player_inputs_and_unchanged_files(self):
        self.prepare()
        player = self.root / "game.project"
        mirror = self.project / "game.project"
        before = mirror.stat().st_mtime_ns
        self.prepare()
        self.assertEqual(before, mirror.stat().st_mtime_ns)
        mirror.write_text("test-only override")
        self.assertEqual(player.read_text(), "[project]\ntitle = Player\n")
        self.prepare()
        self.assertEqual(mirror.read_bytes(), player.read_bytes())
        self.assertEqual((self.project / ".defignore").read_text(), "/.tools\n")

    def test_removed_inputs_are_removed_but_build_cache_is_retained(self):
        self.prepare()
        cache = self.project / "build" / "engine"
        cache.parent.mkdir()
        cache.write_bytes(b"cached")
        (self.root / "ui" / "screens.lua").unlink()
        self.prepare()
        self.assertFalse((self.project / "ui" / "screens.lua").exists())
        self.assertEqual(cache.read_bytes(), b"cached")

    def test_stale_manifest_cannot_delete_outside_project(self):
        self.prepare()
        manifest = self.project / ".capture-source.json"
        data = json.loads(manifest.read_text())
        data["inputs"]["../../game.project"] = "stale"
        manifest.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, "escapes capture project"):
            self.prepare()
        self.assertTrue((self.root / "game.project").exists())
