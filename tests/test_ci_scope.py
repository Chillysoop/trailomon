import unittest
from tools.ci_scope import scope


class ScopeTests(unittest.TestCase):
    def test_notes_and_evidence_do_not_build_the_game(self):
        self.assertEqual(scope(["docs/memory/delivery.md", "reviews/evidence/result.png"]), "docs")

    def test_review_changes_keep_review_checks(self):
        self.assertEqual(scope(["reviews/review.js", "tools/hosted_review/route.ts", "docs/PLAN.md"]), "review")

    def test_mixed_game_and_review_changes_keep_all_checks(self):
        self.assertEqual(scope(["reviews/next.html", "simulation/combat.lua"]), "all")

    def test_unknown_paths_and_tooling_keep_all_checks(self):
        for name in [".github/workflows/verify.yml", "tools/test.ps1", "tests/run.lua", "assets/new.png", "docs/executable.lua", "new-system.json"]:
            self.assertEqual(scope([name]), "all", name)

    def test_empty_diff_is_conservative(self):
        self.assertEqual(scope([]), "all")
        self.assertEqual(scope([""]), "all")
