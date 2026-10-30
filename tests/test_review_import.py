import json
from pathlib import Path
import tempfile
import unittest
from tools.import_hosted_review import import_rows


class HostedImportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def rows(self):
        data = {"page":"plan-1","title":"Plan","general":"Phone notes","answers":{"P1":{"vote":"yes","note":"Keep it calm","at":"2026-10-30T22:00:00Z"}},"finished":True,"finished_at":"2026-10-30T22:00:00Z","updated_at":"2026-10-30T22:00:00Z","revision":2}
        raw = json.dumps(data)
        chunks = [raw[:100], raw[100:]]
        return [{"page":"plan-1","revision":2,"part":i,"parts":2,"payload_chunk":chunk} for i,chunk in enumerate(chunks)]

    def test_complete_submission_and_idempotency(self):
        self.assertEqual(import_rows(list(reversed(self.rows())), self.root)["imported"], ["plan-1"])
        file = self.root / "responses/plan-1.json"
        self.assertEqual(json.loads(file.read_text())["answers"]["P1"]["vote"], "yes")
        flag = self.root / "responses/plan-1.finished"
        self.assertTrue(flag.exists())
        flag.unlink()
        self.assertEqual(import_rows(self.rows(), self.root)["imported"], [])
        self.assertFalse(flag.exists())

    def test_partial_or_mixed_rows_cannot_overwrite_answers(self):
        with self.assertRaises(ValueError):
            import_rows(self.rows()[:1], self.root)
        rows = self.rows(); rows[1]["revision"] = 3
        with self.assertRaises(ValueError):
            import_rows(rows, self.root)
        self.assertFalse((self.root / "responses/plan-1.json").exists())

    def test_newer_local_answers_are_preserved(self):
        import_rows(self.rows(), self.root)
        (self.root / "responses/.hosted-received.json").unlink()
        file = self.root / "responses/plan-1.json"
        data = json.loads(file.read_text()); data["updated_at"] = "2026-10-31T22:00:00Z"; data["general"] = "Newer local note"
        file.write_text(json.dumps(data))
        self.assertEqual(import_rows(self.rows(), self.root)["newer_local_answers"], ["plan-1"])
        self.assertEqual(json.loads(file.read_text())["general"], "Newer local note")
