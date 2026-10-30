#!/usr/bin/env python3
"""Mirror complete Sites submission rows from stdin into the portable answer bridge.

Read the deployed review_submissions table through Sites (all pages, no truncated
values), then pipe {"rows": [...]} here. No hosting credentials are needed or saved.
"""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))
from tools.review_server import atomic_write, validate, PAGE


def import_rows(rows, root=ROOT / "reviews"):
    out = Path(root) / "responses"
    seen_file = out / ".hosted-received.json"
    seen = json.loads(seen_file.read_text(encoding="utf-8")) if seen_file.exists() else {}
    groups = {}
    for row in rows:
        page = row.get("page", "")
        if not isinstance(page, str) or not PAGE.fullmatch(page):
            raise ValueError("Invalid submitted page")
        groups.setdefault(page, []).append(row)
    imported, conflicts = [], []
    for page, parts in groups.items():
        parts.sort(key=lambda p: p["part"])
        revision, total = parts[0]["revision"], parts[0]["parts"]
        if type(total) is not int or total < 1 or len(parts) != total:
            raise ValueError("Incomplete submission; read every table page before importing")
        if any(p["part"] != i or p["parts"] != total or p["revision"] != revision for i, p in enumerate(parts)):
            raise ValueError("Mixed submission revisions; read the table again")
        data = json.loads("".join(p["payload_chunk"] for p in parts))
        validate(data, page)
        if data.get("page") != page or not data.get("finished") or data.get("revision") != revision:
            raise ValueError("Invalid completed submission")
        key = str(revision) + ":" + data.get("finished_at", "")
        if seen.get(page) == key:
            continue
        file = out / (page + ".json")
        local = json.loads(file.read_text(encoding="utf-8")) if file.exists() else {}
        if (local.get("updated_at") or "") > (data.get("updated_at") or ""):
            conflicts.append(page)
            continue  # Preserve the newer local answers; the hosted copy remains online.
        atomic_write(file, data)
        atomic_write(out / (page + ".finished"), data)
        seen[page] = key
        atomic_write(seen_file, seen)
        imported.append(page)
    return {"imported": imported, "newer_local_answers": conflicts}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT / "reviews")
    args = parser.parse_args()
    data = json.load(sys.stdin)
    if data.get("model_projection", {}).get("truncated"):
        raise ValueError("Refusing truncated rows")
    print(json.dumps(import_rows(data["rows"], args.root)))


if __name__ == "__main__":
    main()
