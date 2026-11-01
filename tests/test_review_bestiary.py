import copy
import json
import unittest
from tools import bestiary


class BestiaryTests(unittest.TestCase):
    def setUp(self):
        self.data=json.loads(bestiary.INDEX.read_text(encoding='utf-8'))

    def test_current_ledger_counts_and_generated_page(self):
        self.assertEqual(bestiary.validate(self.data), {'slots':300,'briefs':24,'reserved':276,'implemented':6,'sample_kits':3})
        self.assertEqual(bestiary.render(self.data), bestiary.PAGE.read_text(encoding='utf-8'))

    def test_reserved_slots_and_duplicate_ids_cannot_inflate_roster(self):
        for change in (lambda d:d['entries'][6].update(name='Empty fake'), lambda d:d['entries'][6].update(index_id='TR-001'), lambda d:d.update(minimum_species=299)):
            with self.subTest(change=change):
                data=copy.deepcopy(self.data);change(data)
                with self.assertRaises(ValueError): bestiary.validate(data)

    def test_runtime_claims_and_permanent_ids_are_checked(self):
        for change in (lambda d:d['entries'][60].update(game_status='implemented'), lambda d:d['entries'][0].update(kit_status='proposed'), lambda d:d['entries'][0].update(species_id='renamed')):
            data=copy.deepcopy(self.data);change(data)
            with self.assertRaises(ValueError): bestiary.validate(data)

    def test_briefs_require_counterplay_bounds_and_known_links(self):
        for change in (lambda e:e.update(counterplay=''), lambda e:e['active'].pop('bound'), lambda e:e.update(emits=['unknown']), lambda e:e.update(related_species=['missing'])):
            data=copy.deepcopy(self.data);change(data['entries'][60])
            with self.assertRaises(ValueError): bestiary.validate(data)

    def test_type_and_terrain_fields_cannot_sneak_into_the_schema(self):
        for field in ('types','class','terrain_effect'):
            data=copy.deepcopy(self.data);data['entries'][60][field]='unapproved'
            with self.assertRaises(ValueError): bestiary.validate(data)

    def test_html_escapes_authored_content_and_has_stable_anchors(self):
        data=copy.deepcopy(self.data);data['entries'][60]['body']='<script>alert("bad")</script>'
        page=bestiary.render(data)
        self.assertNotIn('<script>alert',page)
        self.assertIn('&lt;script&gt;',page)
        self.assertIn('id="TR-062"',page)
        self.assertIn('href="#TR-182"',page)
        self.assertNotIn('id="finish"',page)


if __name__ == '__main__':
    unittest.main()
