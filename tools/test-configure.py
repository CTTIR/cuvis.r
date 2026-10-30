"""Exercise SDK discovery without installing or executing vendor libraries."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ConfigureTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'tools').mkdir()
        (self.root / 'src').mkdir()
        shutil.copy(ROOT / 'tools/configure-sdk.sh', self.root / 'tools')
        for name in ('configure', 'configure.win'):
            shutil.copy(ROOT / name, self.root)

    def run_configure(self, sdk, windows=False, stub='0'):
        env = dict(os.environ, CUVIS_SDK=str(sdk), CUVIS='', CUVIS_STUB=stub)
        return subprocess.run(['sh', 'configure.win' if windows else 'configure'],
                              cwd=self.root, env=env, text=True, capture_output=True)

    def sdk(self, name='sdk', library='lib/libcuvis.so'):
        root = self.root / name
        (root / 'include').mkdir(parents=True)
        (root / 'include/cuvis.h').write_text('/* discovery fixture */')
        if library:
            (root / library).parent.mkdir(parents=True, exist_ok=True)
            (root / library).touch()
        return root

    def test_explicit_missing_and_header_only_fail(self):
        for sdk in (self.root / 'missing', self.sdk(library=None)):
            result = self.run_configure(sdk)
            self.assertNotEqual(result.returncode, 0, result.stdout)
            self.assertFalse((self.root / 'src/Makevars').exists())

    def test_force_stub_ignores_broken_sdk(self):
        result = self.run_configure(self.root / 'missing', stub='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('-DCUVIS_STUB', (self.root / 'src/Makevars').read_text())

    def test_unix_spaces_ampersands_and_multiarch(self):
        sdk = self.sdk("sdk & user's files", 'lib/x86_64-linux-gnu/libcuvis.so')
        result = self.run_configure(sdk)
        self.assertEqual(result.returncode, 0, result.stderr)
        flags = (self.root / 'src/Makevars').read_text()
        self.assertIn(str(sdk / 'include'), flags)
        self.assertIn(str(sdk / 'lib/x86_64-linux-gnu/libcuvis.so'), flags)

    def test_windows_import_library(self):
        sdk = self.sdk('Windows SDK', 'bin/cuvis.lib')
        result = self.run_configure(sdk, windows=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('bin/cuvis.lib', (self.root / 'src/Makevars.win').read_text())

    def test_make_expansion_paths_rejected_without_overwriting_configuration(self):
        output = self.root / 'src/Makevars'
        output.write_text('preserve existing configuration\n')
        for name in ('sdk$dollar', 'sdk#comment', 'sdk"quote', 'sdk`command'):
            result = self.run_configure(self.sdk(name))
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_text(), 'preserve existing configuration\n')


if __name__ == '__main__':
    unittest.main()
