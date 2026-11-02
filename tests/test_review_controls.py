"""Every interactive owner page must satisfy the shared review.js DOM contract."""
from html.parser import HTMLParser
from pathlib import Path
import unittest


class Controls(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.interactive = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.interactive |= "idea" in attrs.get("class", "").split()
        if "id" in attrs:
            self.ids.add(attrs["id"])


class ReviewControlsTests(unittest.TestCase):
    def test_authored_pages_supply_every_required_control(self):
        for page in (Path(__file__).resolve().parents[1] / "reviews").glob("*.html"):
            parsed = Controls()
            parsed.feed(page.read_text(encoding="utf-8"))
            if parsed.interactive:
                with self.subTest(page=page.name):
                    self.assertLessEqual({"general", "tally", "allTop", "finish", "export", "status"}, parsed.ids)
