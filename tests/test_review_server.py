"""Review bridge integration tests. All responses live in a temporary directory."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from tools.review_server import ReviewServer, wait


class ReviewBridgeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / "sample.html").write_text("<h1>Sample</h1>", encoding="utf-8")
        self.server = ReviewServer(("127.0.0.1", 0), self.root)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = f"http://127.0.0.1:{self.server.server_port}"

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp.cleanup()

    def request(self, path="/api/responses/sample", data=None, headers=None):
        raw = json.dumps(data).encode() if data is not None else None
        request = Request(self.url + path, data=raw, headers={"Content-Type": "application/json", **(headers or {})})
        try:
            with urlopen(request, timeout=3) as response:
                return response.status, response.read()
        except HTTPError as error:
            with error:
                return error.code, error.read()

    def answers(self, **overrides):
        return {"title": "Sample", "general": "A quieter road", "answers": {
            "P1": {"vote": "yes", "note": "Keep the wagon visible", "at": "2026-10-30T12:00:00Z"},
            "P2": {"vote": "no", "note": "Too large", "at": "2026-10-30T12:00:00Z"},
            "P3": {"vote": "", "note": "Consider a smaller version", "at": "2026-10-30T12:00:00Z"}},
            "finished": False, **overrides}

    def test_health_and_static_page(self):
        status, raw = self.request("/api/health")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(raw)["root"], str(self.root.resolve()))
        self.assertEqual(self.request("/sample.html")[0], 200)

    def test_autosave_preserves_votes_and_note_only_answers(self):
        self.assertEqual(self.request(data=self.answers())[0], 200)
        data = json.loads(self.request()[1])
        self.assertEqual(data["answers"]["P2"]["vote"], "no")
        self.assertEqual(data["answers"]["P3"]["note"], "Consider a smaller version")
        self.assertFalse((self.root / "responses/sample.finished").exists())

    def test_finish_wakes_waiter_and_consumes_only_the_flag(self):
        self.request(data=self.answers(finished=True))
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.assertEqual(wait("sample", 1, self.root, .01), 0)
        self.assertTrue(json.loads(output.getvalue())["finished"])
        self.assertTrue((self.root / "responses/sample.json").exists())
        self.assertFalse((self.root / "responses/sample.finished").exists())

    def test_new_draft_does_not_replace_finished_snapshot(self):
        self.request(data=self.answers(finished=True))
        self.request(data=self.answers(general="Unsubmitted new draft", revision=1))
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.assertEqual(wait("sample", 1, self.root, .01), 0)
        self.assertEqual(json.loads(output.getvalue())["general"], "A quieter road")
        self.assertEqual(json.loads(self.request()[1])["general"], "Unsubmitted new draft")

    def test_stale_write_returns_current_answers(self):
        self.request(data=self.answers())
        status, raw = self.request(data=self.answers(general="stale tab"))
        self.assertEqual(status, 409)
        self.assertEqual(json.loads(raw)["current"]["general"], "A quieter road")

    def test_invalid_data_and_untrusted_origins_do_not_write(self):
        for data in ([], {"answers": {"P1": {"vote": "maybe"}}}, {"revision": True}):
            self.assertEqual(self.request(data=data)[0], 400)
        self.assertEqual(self.request(data=self.answers(), headers={"Origin": "https://example.com"})[0], 403)
        self.assertEqual(self.request(data=self.answers(), headers={"Host": "example.com"})[0], 403)
        self.assertFalse((self.root / "responses/sample.json").exists())

    def test_response_path_is_not_a_filesystem_path(self):
        self.assertEqual(self.request("/api/responses/..%2Fescape", self.answers())[0], 404)
        self.request(data=self.answers())
        self.assertEqual(self.request("/responses/sample.json")[0], 404)
        self.assertEqual(self.request("/responses/")[0], 404)

    def test_timeout_and_repeat_submission(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(wait("sample", .03, self.root, .01), 2)
        for revision in (0, 1):
            self.assertEqual(self.request(data=self.answers(finished=True, revision=revision))[0], 200)
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(wait(None, 1, self.root, .01), 0)


if __name__ == "__main__":
    unittest.main()
