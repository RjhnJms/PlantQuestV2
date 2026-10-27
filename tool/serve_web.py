"""Serves build/web for the browser preview, telling the browser never to
keep old copies, so a rebuild shows up on a normal reload.

Run:  python tool/serve_web.py   (then open http://localhost:8686)
"""

import functools
import http.server
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'build' / 'web'


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, must-revalidate')
        super().end_headers()


if __name__ == '__main__':
    handler = functools.partial(NoCacheHandler, directory=str(ROOT))
    http.server.ThreadingHTTPServer(('127.0.0.1', 8686), handler).serve_forever()
