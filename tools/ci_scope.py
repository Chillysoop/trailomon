"""Choose cheap checks for documents/reviews; unknown changes keep full coverage."""
import os
from pathlib import PurePosixPath
import subprocess


def scope(paths):
    def documentation(name):
        p = PurePosixPath(name)
        return (name in {"AGENTS.md", "CLAUDE.md", "README.md", "reviews/hosted-site.json"}
                or (name.startswith("docs/") and p.suffix == ".md")
                or (name.startswith("reviews/evidence/") and p.suffix == ".png"))

    paths = list(paths)
    if not paths:
        return "all"
    changed = [name for name in paths if not documentation(name)]
    if not changed:
        return "docs"
    if all(name.startswith(("reviews/", "tools/hosted_review/"))
           or name in {"tools/review_server.py", "tools/import_hosted_review.py",
                       "tools/sync_hosted_review.py", "tools/start_review.ps1",
                       "tools/test_review_browser.cjs", "tools/test_hosted_review.cjs"}
           or (name.startswith("tests/test_review") and name.endswith(".py"))
           for name in changed):
        return "review"
    return "all"


if __name__ == "__main__":
    base, head = os.environ.get("BASE_SHA"), os.environ.get("HEAD_SHA")
    # Manual runs and any uncertain diff keep every check.
    selected = "all"
    if base and head:
        try:
            raw = subprocess.check_output(["git", "diff", "--name-only", "-z", base, head])
            selected = scope(raw.decode("utf-8").rstrip("\0").split("\0"))
        except (subprocess.CalledProcessError, UnicodeError):
            pass
    print(f"Verification scope: {selected}")
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
            output.write(f"scope={selected}\n")
