import json
import hashlib
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


class LoginRecoveryTests(unittest.TestCase):
    def test_quarantines_old_database_without_deleting_and_can_restore(self):
        with tempfile.TemporaryDirectory() as home:
            config = Path(home, '.config folder')
            original = config / 'ZaloData' / 'cal' / 'main.meta'
            original.parent.mkdir(parents=True)
            original.write_bytes(b'precious chat history')
            env = dict(os.environ, HOME=home, XDG_CONFIG_HOME=str(config))
            script = str(ROOT / 'zalo-login-recover.sh')

            preview = subprocess.run(['bash', script, '--dry-run'], env=env,
                                     capture_output=True, text=True)
            self.assertEqual(preview.returncode, 0, preview.stderr)
            self.assertTrue(original.exists())

            moved = subprocess.run(['bash', script], env=env,
                                   capture_output=True, text=True)
            self.assertEqual(moved.returncode, 0, moved.stderr)
            self.assertFalse(original.exists())
            backups = list(config.glob('ZaloData.login-backup-*'))
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / 'ZaloData/cal/main.meta').read_bytes(),
                             b'precious chat history')
            self.assertEqual(backups[0].stat().st_mode & 0o777, 0o700)

            fresh = config / 'ZaloData' / 'fresh.db'
            fresh.parent.mkdir()
            fresh.write_text('new login data')
            refused = subprocess.run(['bash', script, '--restore', str(backups[0])],
                                     env=env, capture_output=True, text=True)
            self.assertNotEqual(refused.returncode, 0)
            self.assertTrue(fresh.exists(), 'Must not overwrite new Zalo data')
            fresh.unlink()
            fresh.parent.rmdir()
            restored = subprocess.run(['bash', script, '--restore', str(backups[0])],
                                      env=env, capture_output=True, text=True)
            self.assertEqual(restored.returncode, 0, restored.stderr)
            self.assertEqual(original.read_bytes(), b'precious chat history')

    def test_refuses_when_application_is_running(self):
        with tempfile.TemporaryDirectory() as home:
            config = Path(home, '.config')
            data = config / 'ZaloData'
            data.mkdir(parents=True)
            fakebin = Path(home, 'bin')
            fakebin.mkdir()
            fake_pgrep = fakebin / 'pgrep'
            fake_pgrep.write_text('#!/bin/sh\nexit 0\n')
            fake_pgrep.chmod(0o755)
            env = dict(os.environ, HOME=home, XDG_CONFIG_HOME=str(config),
                       PATH=str(fakebin) + os.pathsep + os.environ['PATH'])
            result = subprocess.run(['bash', str(ROOT / 'zalo-login-recover.sh')],
                                    env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertTrue(data.exists())
            self.assertIn('Đóng', result.stderr)


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

    def test_terminal_branding_ansi_progress_and_no_color(self):
        with tempfile.TemporaryDirectory() as folder:
            fakebin = Path(folder, 'bin')
            fakebin.mkdir()
            uname = fakebin / 'uname'
            uname.write_text('#!/bin/sh\nprintf aarch64\n')
            uname.chmod(0o755)
            env = dict(os.environ, PATH=str(fakebin) + os.pathsep + os.environ['PATH'],
                       FORCE_COLOR='1', TERM='xterm')
            env.pop('NO_COLOR', None)
            script = str(ROOT / 'install-zalo-linux.sh')
            colorful = subprocess.run(['bash', script], env=env, capture_output=True, text=True)
            self.assertNotEqual(colorful.returncode, 0, 'Fixture architecture must stop before install')
            self.assertIn('NAMHH', colorful.stdout)
            self.assertIn('huynhoainam@gmail.com', colorful.stdout)
            self.assertIn('[01/06]', colorful.stdout)
            self.assertIn('\x1b[', colorful.stdout)
            env['NO_COLOR'] = '1'
            plain = subprocess.run(['bash', script], env=env, capture_output=True, text=True)
            self.assertNotIn('\x1b[', plain.stdout + plain.stderr)


class LauncherTests(unittest.TestCase):
    def test_gnome_wayland_uses_ibus_and_xwayland_with_safe_overrides(self):
        with tempfile.TemporaryDirectory() as home:
            share = Path(home, 'share')
            app = share / 'zalo-linux' / 'Zalo-x86_64.AppImage'
            app.parent.mkdir(parents=True)
            app.write_text('#!/usr/bin/env bash\nprintf "GTK=%s XMOD=%s ARGS=%s\\n" "$GTK_IM_MODULE" "$XMODIFIERS" "$*"\n')
            app.chmod(0o755)
            env = dict(os.environ, HOME=home, XDG_DATA_HOME=str(share),
                       XDG_CURRENT_DESKTOP='ubuntu:GNOME', XDG_SESSION_TYPE='wayland',
                       DISPLAY=':0')
            launch = str(ROOT / 'zalo-launcher.sh')
            result = subprocess.run(['bash', launch, '--test'], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('GTK=ibus', result.stdout)
            self.assertIn('XMOD=@im=ibus', result.stdout)
            self.assertIn('--ozone-platform=x11', result.stdout)
            self.assertIn('--no-sandbox', result.stdout)

            env['ZALO_OZONE_PLATFORM'] = 'auto'
            env['ZALO_SANDBOX'] = '1'
            result = subprocess.run(['bash', launch], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('--ozone-platform=', result.stdout)
            self.assertNotIn('--no-sandbox', result.stdout)

    def test_launcher_fails_when_appimage_is_missing(self):
        with tempfile.TemporaryDirectory() as home:
            env = dict(os.environ, HOME=home, XDG_DATA_HOME=str(Path(home, 'share')))
            result = subprocess.run(['bash', str(ROOT / 'zalo-launcher.sh')], env=env,
                                    capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('AppImage', result.stderr)


class MirrorDownloadTests(unittest.TestCase):
    def test_retries_only_verified_mirror_after_github_403(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            payload = root / 'official.bin'
            payload.write_bytes(b'\x7fELF verified upstream appimage fixture')
            sha = hashlib.sha256(payload.read_bytes()).hexdigest()
            fakebin = root / 'bin'
            fakebin.mkdir()
            curl = fakebin / 'curl'
            curl.write_text('''#!/usr/bin/env bash
set -e
url=''; target=''
while (($#)); do
  case "$1" in
    -o) target="$2"; shift 2 ;;
    https://*) url="$1"; shift ;;
    *) shift ;;
  esac
done
[[ "$url" == https://gh-proxy.com/* ]] || exit 22
cp "$MOCK_PAYLOAD" "$target"
''')
            curl.chmod(0o755)
            target = root / 'download.AppImage'
            env = dict(os.environ, PATH=str(fakebin) + os.pathsep + os.environ['PATH'],
                       MOCK_PAYLOAD=str(payload))
            command = 'source "$1"; download_zalo_appimage "$2" "$3" "$4"'
            run = subprocess.run(['bash', '-c', command, 'test', str(ROOT / 'zalo-download.sh'),
                                  'https://github.com/example/release.AppImage', str(target),
                                  'sha256:' + sha], env=env, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertEqual(target.read_bytes(), payload.read_bytes())
            self.assertIn('SHA-256: OK', run.stdout)

            wrong = subprocess.run(['bash', '-c', command, 'test', str(ROOT / 'zalo-download.sh'),
                                    'https://github.com/example/release.AppImage', str(target),
                                    'sha256:' + '0' * 64], env=env, capture_output=True, text=True)
            self.assertNotEqual(wrong.returncode, 0)
            self.assertFalse(target.exists())

    def test_unknown_digest_disables_third_party_mirrors(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / 'download.AppImage'
            env = dict(os.environ, ZALO_MIRROR_URL='https://example.invalid/file.AppImage')
            script = 'source "$1"; download_zalo_appimage "$2" "$3" "$4"'
            result = subprocess.run(['bash', '-c', script, 'test', str(ROOT / 'zalo-download.sh'),
                                     'https://127.0.0.1:1/no-file', str(target), '-'],
                                    env=env, capture_output=True, text=True, timeout=12)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('không dùng nguồn mirror', result.stderr)


if __name__ == '__main__':
    unittest.main()
