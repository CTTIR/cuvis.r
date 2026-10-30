"""Compile real wrapper sources against a supplied vendor header and test double.

Usage: python3 tools/test-native.py /path/to/cuvis.h
Requires R, its C compiler, and a separately obtained CUVIS SDK header.
No vendor binary, calibration or measurement is used or qualified here.
"""
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
header = Path(sys.argv[1]).resolve()
fixture = (ROOT / 'tools/native/fixture.c').read_text()
# Stub only unexercised vendor entry points. Unexpected calls abort rather than
# inventing success; the supplied header remains the declaration authority.
text = re.sub(r'/\*.*?\*/', '', header.read_text(), flags=re.S)
prototypes = re.findall(r'SDK_CAPI\s+[^;{}]+;', text)
source = '\n'.join(p.read_text() for p in (ROOT / 'src').glob('*.c'))
needed = set(re.findall(r'\b(cuvis_\w+)\s*\(', source))
fallbacks = []
for prototype in prototypes:
    match = re.search(r'\b(cuvis_\w+)\s*\(', prototype)
    if not match:
        continue
    name = match[1]
    if name in needed and not re.search(r'\b' + name + r'\s*\(', fixture):
        fallbacks.append(prototype[:-1] + ' { abort(); }')
with tempfile.TemporaryDirectory(prefix='cuvis-native-') as temp:
    build = Path(temp)
    for path in (ROOT / 'src').glob('*.[ch]'):
        shutil.copy(path, build)
    shutil.copy(header, build / 'cuvis.h')
    (build / 'fixture.c').write_text(fixture + '\n' + '\n'.join(fallbacks))
    sources = [p.name for p in sorted(build.glob('*.c'))]
    subprocess.run(['R', 'CMD', 'SHLIB', '-o', 'cuvis.r.so', *sources],
                   cwd=build, check=True, env=dict(os.environ, PKG_CPPFLAGS='-I.'))
    subprocess.run(['Rscript', '--vanilla', str(ROOT / 'tools/native/check.R'),
                    str(build / 'cuvis.r.so'), str(ROOT)], cwd=build, check=True)
