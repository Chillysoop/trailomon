"""Development-only Sprite Fusion client. Credentials come only from the environment.

Usage: python tools/sprite_fusion.py requests.json
The request file is a list of {name, operation, prompt, size, inputs?} records.
All output identities are preserved; the first output is the initial sprite choice.
"""
import json
import os
from pathlib import Path
import sys
import urllib.request
import urllib.error

BASE = "https://www.spritefusion.com/api/v1"


def api(path, payload=None):
    key = os.environ.get("SPRITE_FUSION_API_KEY")
    if not key:
        raise SystemExit("Set SPRITE_FUSION_API_KEY for development art requests.")
    req = urllib.request.Request(BASE + path,
        data=None if payload is None else json.dumps(payload).encode(),
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
    try:
        return urllib.request.urlopen(req, timeout=360)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"Sprite Fusion {error.code}: {error.read().decode()}")


def download(asset, target):
    req = urllib.request.Request(asset["assetUrl"],
        headers={"User-Agent": "Mozilla/5.0", "Referer": "https://www.spritefusion.com/"})
    with urllib.request.urlopen(req, timeout=60) as response:
        target.write_bytes(response.read())


def run(request):
    name = request["name"]
    folder = Path("assets/sprites")
    folder.mkdir(parents=True, exist_ok=True)
    manifest = folder / (name + ".json")
    if manifest.exists():
        print(f"Skipping existing record: {name}", flush=True)
        return
    payload = {k: v for k, v in request.items() if k != "name"}
    record = {"name": name, "request": payload, "outputs": []}
    with api("/generate", payload) as response:
        for line in response:
            text = line.decode().strip()
            if not text.startswith("data:"):
                continue
            event = json.loads(text[5:])
            if event["type"] == "started":
                record["request_id"] = event["request_id"]
            elif event["type"] == "output":
                record["outputs"].append({"index": event["index"], "asset": event["asset"]})
            elif event["type"] == "completed":
                record["status"] = event["status"]
            manifest.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
            print(name, event["type"], event.get("status", ""), flush=True)
    temporary = Path(".tools/art-candidates") / name
    temporary.mkdir(parents=True, exist_ok=True)
    for output in record["outputs"]:
        download(output["asset"], temporary / (str(output["index"]) + ".png"))
    if record["outputs"]:
        chosen = min(record["outputs"], key=lambda item: item["index"])
        (folder / (name + ".png")).write_bytes((temporary / (str(chosen["index"]) + ".png")).read_bytes())
        record["selected_index"] = chosen["index"]
        record["local_path"] = (folder / (name + ".png")).as_posix()
        manifest.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    for request in json.loads(Path(sys.argv[1]).read_text(encoding="utf-8")):
        run(request)
