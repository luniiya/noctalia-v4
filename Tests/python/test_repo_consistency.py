"""Repository consistency checks (run with: python3 -m unittest discover -s Tests/python)."""

import json
import pathlib
import re
import subprocess
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
EN = ROOT / "Assets" / "Translations" / "en.json"
TR_CALL = re.compile(r'I18n\.tr[pu]?\(\s*"([^"]+)"')


def qml_files():
    for path in ROOT.rglob("*.qml"):
        if "Tests" not in path.relative_to(ROOT).parts:
            yield path


def lookup(tree, key):
    node = tree
    for part in key.split("."):
        if not isinstance(node, dict) or part not in node:
            return None
        node = node[part]
    return node


class TranslationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.en = json.loads(EN.read_text(encoding="utf-8"))

    def test_translation_files_are_valid_json(self):
        for path in sorted((ROOT / "Assets" / "Translations").glob("*.json")):
            with self.subTest(file=path.name):
                json.loads(path.read_text(encoding="utf-8"))

    def test_literal_keys_exist_in_english(self):
        missing = []
        for path in qml_files():
            for key in TR_CALL.findall(path.read_text(encoding="utf-8")):
                # Keys ending in "." are prefixes concatenated at runtime
                if key.endswith("."):
                    continue
                if not isinstance(lookup(self.en, key), str):
                    missing.append(f"{path.relative_to(ROOT)}: {key}")
        self.assertEqual(missing, [], "translation keys missing from en.json")

    def test_notch_strings_present(self):
        self.assertEqual(lookup(self.en, "options.bar.type-notch"), "Notch")
        self.assertIsNotNone(lookup(self.en, "panels.bar.appearance-notch-gap-label"))
        self.assertIsNotNone(lookup(self.en, "panels.bar.appearance-notch-gap-description"))


class SettingsSearchIndexTests(unittest.TestCase):
    def test_index_is_up_to_date(self):
        index = ROOT / "Assets" / "settings-search-index.json"
        before = index.read_bytes()
        try:
            subprocess.run([sys.executable, str(ROOT / "Scripts" / "dev" / "build-settings-search-index.py")],
                           cwd=ROOT, check=True, capture_output=True)
            after = index.read_bytes()
        finally:
            index.write_bytes(before)
        self.assertEqual(before, after, "run Scripts/dev/build-settings-search-index.py and commit the result")

    def test_index_keys_exist_in_english(self):
        en = json.loads(EN.read_text(encoding="utf-8"))
        entries = json.loads((ROOT / "Assets" / "settings-search-index.json").read_text(encoding="utf-8"))
        for entry in entries:
            for field in ("labelKey", "descriptionKey"):
                key = entry.get(field)
                if key:
                    with self.subTest(key=key):
                        self.assertIsInstance(lookup(en, key), str)


class SettingsSchemaTests(unittest.TestCase):
    def test_bar_type_options_match_settings_comment(self):
        settings = (ROOT / "Commons" / "Settings.qml").read_text(encoding="utf-8")
        tab = (ROOT / "Modules" / "Panels" / "Settings" / "Tabs" / "Bar" / "AppearanceSubTab.qml").read_text(encoding="utf-8")
        comment = re.search(r'property string barType: "\w+" // (.*)', settings).group(1)
        documented = set(re.findall(r'"(\w+)"', comment))
        offered = set(re.findall(r'"key": "(\w+)",\s*"name": I18n\.tr\("options\.bar\.type-', tab))
        self.assertEqual(documented, offered)
        self.assertIn("notch", offered)

    def test_notch_gap_default(self):
        settings = (ROOT / "Commons" / "Settings.qml").read_text(encoding="utf-8")
        self.assertRegex(settings, r"property int notchGap: \d+")


if __name__ == "__main__":
    unittest.main()
