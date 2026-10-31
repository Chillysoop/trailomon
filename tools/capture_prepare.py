"""Mirror only game/test inputs into an isolated, incremental capture project."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / ".tools" / "capture-project"
FOLDERS = ("assets", "content", "simulation", "services", "ui", "presentation", "input", "main", "tests")


def prepare():
    PROJECT.mkdir(parents=True, exist_ok=True)
    files = [ROOT / "game.project"]
    for folder in FOLDERS:
        files += [p for p in (ROOT / folder).rglob("*") if p.is_file()
                  and "__pycache__" not in p.parts and p.suffix not in {".pyc"}]
    hashes = {}
    for source in files:
        name = source.relative_to(ROOT).as_posix()
        target = PROJECT / name
        data = source.read_bytes()
        hashes[name] = hashlib.sha256(data).hexdigest()
        if not target.exists() or target.read_bytes() != data:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
    manifest = PROJECT / ".capture-source.json"
    if manifest.exists():
        previous = json.loads(manifest.read_text(encoding="utf-8"))
        for name in previous["inputs"].keys() - hashes.keys():
            target = (PROJECT / name).resolve()
            if not target.is_relative_to(PROJECT.resolve()):
                raise ValueError("Stale source path escapes capture project")
            if target.is_file():
                target.unlink()
    fingerprint = hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()
    data = {"source_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip(),
            "working_tree_changes": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT)),
            "inputs_sha256": fingerprint, "inputs": hashes}
    manifest.write_text(json.dumps(data, indent=2)+"\n", encoding="utf-8")
    print(PROJECT)


if __name__ == "__main__":
    prepare()
