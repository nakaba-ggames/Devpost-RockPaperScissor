#!/usr/bin/env python3
"""List the Godot 4.7 PCK directory without printing packaged credentials."""
from pathlib import Path
import hashlib
import re
import struct

root = Path(__file__).resolve().parents[1]
pack = root.parent / 'backend/public/index.pck'
data = pack.read_bytes()
magic, version = struct.unpack_from('<II', data)
if magic != 0x43504447 or version != 4:
    raise SystemExit('Expected a Godot 4.7 PCK v4')
base = struct.unpack_from('<Q', data, 24)[0]
cursor = struct.unpack_from('<Q', data, 32)[0]
count = struct.unpack_from('<I', data, cursor)[0]
cursor += 4
paths = []
assertions = []
for _ in range(count):
    length = struct.unpack_from('<I', data, cursor)[0]
    cursor += 4
    path = data[cursor:cursor + length].rstrip(b'\0').decode()
    cursor += length
    offset, size = struct.unpack_from('<QQ', data, cursor)
    cursor += 36
    paths.append(path)
    if path.endswith('.gd'):
        source = data[base + offset:base + offset + size].decode('utf-8')
        if re.search(r'\bassert\s*\(', source):
            assertions.append(path)
for path in paths:
    print(path)
print(f'Files: {count}; bytes: {len(data)}; SHA-256: {hashlib.sha256(data).hexdigest()}')
print(f'Shipped scripts containing assertions: {assertions}')
for path in paths:
    if any(part in path for part in ['godot_mcp_toolkit/', 'docs/', 'devpost/', 'tools/', '.psd', '.DS_Store']):
        raise SystemExit('Unexpected development/source asset: ' + path)
if assertions:
    raise SystemExit('Review assertion-bearing scripts before release')
