#!/usr/bin/env python3
"""Local review pages and answer-file bridge. Python standard library only.

  py tools/review_server.py
  py tools/review_server.py --wait plan-1 --timeout 540
  py -m unittest discover -s tests -p "test_review*.py"
"""
import argparse
import datetime as dt
import html
import http.server
import json
import os
from pathlib import Path
import re
import threading
import time
from urllib.parse import unquote, urlsplit
import uuid

ROOT = Path(__file__).resolve().parent.parent / "reviews"
PAGE = re.compile(r"[a-z0-9][a-z0-9_-]{0,79}\Z")
CODE = re.compile(r"[A-Z][A-Z0-9_-]{0,39}\Z")
MAX_BODY = 256 * 1024


def utc_now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="milliseconds")


def atomic_write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + "." + uuid.uuid4().hex + ".tmp")
    try:
        tmp.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        os.replace(tmp, path)
    finally:
        tmp.unlink(missing_ok=True)


def validate(data, page):
    if not isinstance(data, dict):
        raise ValueError("Answers must be an object")
    for key in ("title", "general", "general_at", "updated_at", "finished_at"):
        if key in data and (not isinstance(data[key], str) or len(data[key]) > 20000):
            raise ValueError("Invalid " + key)
    if not isinstance(data.get("finished", False), bool):
        raise ValueError("Invalid finished state")
    revision = data.get("revision", 0)
    if type(revision) is not int or revision < 0:
        raise ValueError("Invalid revision")
    answers = data.get("answers", {})
    if not isinstance(answers, dict) or len(answers) > 100:
        raise ValueError("Invalid answers")
    clean = {}
    for code, answer in answers.items():
        if not CODE.fullmatch(code) or not isinstance(answer, dict):
            raise ValueError("Invalid idea code or answer")
        if answer.get("vote", "") not in ("", "yes", "no"):
            raise ValueError("Vote must be yes, no, or empty")
        if any(not isinstance(answer.get(k, ""), str) or len(answer.get(k, "")) > 20000 for k in ("note", "at")):
            raise ValueError("Invalid note or answer timestamp")
        clean[code] = {k: answer.get(k, "") for k in ("vote", "note", "at")}
    result = {k: data.get(k, "") for k in ("title", "general", "general_at", "updated_at", "finished_at")}
    result.update(page=page, answers=clean, finished=data.get("finished", False), revision=revision)
    return result


class ReviewServer(http.server.ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address, root=ROOT):
        self.root = Path(root).resolve()
        self.root.mkdir(parents=True, exist_ok=True)
        self.out = self.root / "responses"
        self.save_lock = threading.Lock()
        super().__init__(address, Handler)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(args[2].root), **kwargs)

    def allowed(self):
        try:
            host = urlsplit("http://" + self.headers.get("Host", ""))
            if host.hostname not in ("localhost", "127.0.0.1") or host.port != self.server.server_port:
                return False
            origin = self.headers.get("Origin")
            return origin is None or origin in (
                f"http://localhost:{self.server.server_port}", f"http://127.0.0.1:{self.server.server_port}")
        except ValueError:
            return False

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Frame-Options", "DENY")
        super().end_headers()

    def reply(self, status, value):
        body = json.dumps(value, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def page_name(self):
        path = unquote(urlsplit(self.path).path)
        prefix = "/api/responses/"
        name = path[len(prefix):] if path.startswith(prefix) else ""
        return name if PAGE.fullmatch(name) else None

    def do_GET(self):
        if not self.allowed():
            return self.reply(403, {"error": "Use the local review-server address"})
        path = unquote(urlsplit(self.path).path)
        if path == "/api/health":
            return self.reply(200, {"service": "trailomon-review", "root": str(self.server.root), "version": 1})
        if path.startswith("/api/responses/"):
            name = self.page_name()
            if not name:
                return self.reply(400, {"error": "Invalid page id"})
            file = self.server.out / (name + ".json")
            try:
                return self.reply(200, json.loads(file.read_text(encoding="utf-8")) if file.exists() else {})
            except (OSError, ValueError):
                return self.reply(500, {"error": "Saved answers cannot be read; the file was preserved"})
        target = Path(self.translate_path(self.path)).resolve()
        if not target.is_relative_to(self.server.root) or target.is_relative_to(self.server.out) or path.startswith("/api/"):
            return self.reply(404, {"error": "Not found"})
        super().do_GET()

    def do_POST(self):
        if not self.allowed():
            return self.reply(403, {"error": "Only the local review page can save answers"})
        name = self.page_name()
        if not name:
            return self.reply(404, {"error": "Invalid response endpoint"})
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if not 0 < length <= MAX_BODY:
                return self.reply(413, {"error": "Invalid answer size"})
            if self.headers.get_content_type() != "application/json":
                return self.reply(415, {"error": "Expected JSON"})
            data = validate(json.loads(self.rfile.read(length)), name)
        except (ValueError, UnicodeError, TypeError):
            return self.reply(400, {"error": "Invalid answers; existing answers were preserved"})
        try:
            with self.server.save_lock:
                file = self.server.out / (name + ".json")
                current = json.loads(file.read_text(encoding="utf-8")) if file.exists() else {}
                if data["revision"] != current.get("revision", 0):
                    return self.reply(409, {"error": "Newer answers exist", "current": current})
                data["revision"] += 1
                data["saved_at"] = utc_now()
                if data["finished"] and not data["finished_at"]:
                    data["finished_at"] = data["saved_at"]
                atomic_write(file, data)
                if data["finished"]:
                    # The flag holds an immutable submission: a subsequent draft
                    # cannot alter what an already-running waiter receives.
                    atomic_write(self.server.out / (name + ".finished"), data)
            return self.reply(200, {"ok": True, "revision": data["revision"], "saved_at": data["saved_at"]})
        except (OSError, ValueError):
            return self.reply(500, {"error": "Could not save; keep this page open or export the answers"})

    def do_OPTIONS(self):
        self.reply(204 if self.allowed() else 403, {})

    def list_directory(self, path):
        if Path(path).resolve() != self.server.root:
            self.send_error(404)
            return None
        links = "".join(f'<li><a href="/{html.escape(p.name)}">{html.escape(p.stem)}</a></li>'
                        for p in sorted(self.server.root.glob("*.html")) if not p.name.startswith("_"))
        body = (f'<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1">'
                f'<title>Trailomon reviews</title><h1>Trailomon reviews</h1><ul>{links}</ul>').encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        return None

    def log_message(self, *args):
        pass


def wait(page=None, timeout=0, root=ROOT, interval=1):
    if page is not None and not PAGE.fullmatch(page):
        raise ValueError("Invalid page id")
    out = Path(root) / "responses"
    start = time.monotonic()
    while timeout <= 0 or time.monotonic() - start < timeout:
        for flag in sorted(out.glob((page or "*") + ".finished")) if out.exists() else []:
            claimed = flag.with_name(flag.name + "." + uuid.uuid4().hex + ".consuming")
            try:
                # Rename claims exactly one flag even if two agents wait.
                flag.rename(claimed)
            except FileNotFoundError:
                continue
            try:
                try:
                    data = json.loads(claimed.read_text(encoding="utf-8"))
                except ValueError:
                    data = json.loads((out / (flag.stem + ".json")).read_text(encoding="utf-8"))
                print(json.dumps(data, ensure_ascii=False, indent=2), flush=True)
            except (OSError, ValueError):
                if not flag.exists():
                    claimed.rename(flag)
                raise
            claimed.unlink(missing_ok=True)
            return 0
        time.sleep(interval)
    print("timeout: no page finished yet", flush=True)
    return 2


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wait", nargs="?", const="*", metavar="PAGE")
    parser.add_argument("--timeout", type=float, default=0)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--root", type=Path, default=ROOT, help="Separate root for isolated test fixtures")
    args = parser.parse_args()
    if args.wait is not None:
        return wait(None if args.wait == "*" else args.wait, args.timeout, args.root)
    try:
        server = ReviewServer(("127.0.0.1", args.port), args.root)
    except OSError as error:
        print(f"Cannot start on port {args.port}: {error}. Verify /api/health before reusing a running service.", flush=True)
        return 1
    print(f"Review pages: http://localhost:{server.server_port}/  answers -> {server.out}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
