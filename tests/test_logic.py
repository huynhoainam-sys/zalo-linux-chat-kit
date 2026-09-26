import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BackupTests(unittest.TestCase):
    def test_config_zalodata_is_backed_up_privately_and_without_collision(self):
        with tempfile.TemporaryDirectory() as home:
            media = Path(home, '.config', 'ZaloData', 'cal', 'main.meta')
            media.parent.mkdir(parents=True)
            media.write_text('sample')
            env = dict(os.environ, HOME=home, XDG_CONFIG_HOME=str(Path(home, '.config')),
                       XDG_DATA_HOME=str(Path(home, '.local', 'share')))
            for _ in range(2):
                subprocess.run(['bash', str(ROOT / 'backup-zalo-linux.sh')], env=env, check=True, capture_output=True)
            backups = sorted(Path(home, 'zalo-linux-backups').glob('*.tar.gz'))
            self.assertEqual(len(backups), 2)
            for archive in backups:
                self.assertEqual(archive.stat().st_mode & 0o777, 0o600)
                self.assertEqual(Path(str(archive) + '.sha256').stat().st_mode & 0o777, 0o600)
                with tarfile.open(archive) as tar:
                    self.assertTrue(any(name.endswith('/.config/ZaloData/cal/main.meta') for name in tar.getnames()))


class InstallerMetadataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        script = (ROOT / 'install-zalo-linux.sh').read_text()
        cls.selector = re.search(r"<<'PY'\n(.*?)\nPY", script, re.S).group(1)

    def select(self, names, variant):
        with tempfile.TemporaryDirectory() as directory:
            meta = Path(directory, 'release.json')
            meta.write_text(json.dumps({'tag_name': '26.9.10', 'assets': [
                {'name': name, 'browser_download_url': 'https://example.invalid/' + name, 'digest': 'sha256:abc'}
                for name in names
            ]}))
            return subprocess.run([sys.executable, '-c', self.selector, str(meta), variant], capture_output=True, text=True)

    def test_both_variants_select_zadark_regardless_of_asset_order(self):
        names = [
            'Zalo-26.9.10-Original-Full-x86_64.AppImage',
            'Zalo-26.9.10+ZaDark-26.2.1-Full-x86_64.AppImage',
            'Zalo-26.9.10-Original-x86_64.AppImage',
            'Zalo-26.9.10+ZaDark-26.2.1-x86_64.AppImage',
        ]
        for variant in ('chat', 'full'):
            with self.subTest(variant=variant):
                result = self.select(names, variant)
                self.assertEqual(result.returncode, 0, result.stderr)
                chosen = result.stdout.splitlines()[1]
                self.assertIn('+ZaDark-', chosen)
                self.assertEqual('-Full-' in chosen, variant == 'full')

    def test_missing_matching_asset_fails_instead_of_switching_variant(self):
        result = self.select(['Zalo-26.9.10-Original-x86_64.AppImage'], 'chat')
        self.assertNotEqual(result.returncode, 0)


if __name__ == '__main__':
    unittest.main()
