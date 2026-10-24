#!/usr/bin/env python3
"""Inspect a local release directory without displaying SDK configuration values."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--pack', type=Path, default=root.parent / 'backend/public/m12/index.pck')
parser.add_argument('--manifest', type=Path, default=root / 'docs/reports/M12_PackManifest.txt')
args = parser.parse_args()
pack = args.pack
data = pack.read_bytes()
magic, version = struct.unpack_from('<II', data)
if magic != 0x43504447 or version != 4:
    raise SystemExit('Expected Godot PCK v4')
base = struct.unpack_from('<Q', data, 24)[0]
cursor = struct.unpack_from('<Q', data, 32)[0]
count = struct.unpack_from('<I', data, cursor)[0]
cursor += 4
paths, unwanted, assertions, sdk_fields = [], [], [], []
for _ in range(count):
    length = struct.unpack_from('<I', data, cursor)[0]
    cursor += 4
    path = data[cursor:cursor + length].rstrip(b'\0').decode()
    cursor += length
    offset, size = struct.unpack_from('<QQ', data, cursor)
    cursor += 36
    paths.append(path)
    if any(value in path for value in ['scripts/development/', 'resources/development/',
            'preview_', 'local_preview', 'peer_result_sink', 'godot_mcp_toolkit/',
            'docs/', 'devpost/', 'tools/', '.psd', '.blend', '.DS_Store', '.env']):
        unwanted.append(path)
    source = data[base + offset:base + offset + size]
    if path == 'addons/GD-Sync/keys.cfg':
        sdk_fields = re.findall(r'(?m)^(publicKey|privateKey)\s*=', source.decode())
    if path.endswith('.gd') and re.search(rb'\bassert\s*\(', source):
        assertions.append(path)
    if b'mongodb+srv://' in source or re.search(rb'anon_[A-Za-z0-9_-]{43}', source):
        raise SystemExit('Unexpected server/account credential pattern; values withheld.')
required = ['scripts/api/http_api.gd', 'scripts/api/backend_result_sink.gd',
            'scripts/api/live_profile_provider.gd', 'scripts/api/history_wire.gd',
            'scripts/api/player_profile.gd', 'scripts/networking/gdsync_match_session.gd']
missing = [value for value in required if value not in paths]
summary = {'entries': count, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(),
           'unwanted': unwanted, 'missing': missing, 'assertionScripts': assertions,
           'sdkFieldsPresent': sdk_fields, 'files': sorted(p.name for p in pack.parent.iterdir())}
print(json.dumps(summary, indent=2))
if unwanted or missing or assertions:
    raise SystemExit('Release package needs repair.')
manifest = args.manifest
manifest.write_text('\n'.join(paths) + '\n' + json.dumps(summary, indent=2) + '\n')
