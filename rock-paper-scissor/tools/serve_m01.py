#!/usr/bin/env python3
"""Local static M01 preview. No API or backend persistence."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

if __name__ == '__main__':
    public = Path(__file__).resolve().parents[2] / 'backend' / 'public'
    handler = partial(SimpleHTTPRequestHandler, directory=str(public))
    print('M01 static release preview: http://localhost:3000/ (Ctrl+C to stop)', flush=True)
    ThreadingHTTPServer(('127.0.0.1', 3000), handler).serve_forever()
