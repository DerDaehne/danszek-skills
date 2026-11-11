#!/usr/bin/env python3
"""Inline design-system files into a page byte-identically, or verify that a page holds them.

Usage:
  inline.py build TEMPLATE OUTPUT NAME=FILE [NAME=FILE ...]
      Replaces the placeholder /*@inline:NAME@*/ in TEMPLATE with the exact bytes
      of FILE (each placeholder must occur exactly once), writes OUTPUT, then verifies it.
  inline.py verify PAGE FILE [FILE ...]
      Checks that PAGE contains the exact bytes of every FILE.

Exit codes: 0 every file is inlined unchanged, 1 a check failed, 2 usage error.
Only the standard library is used; replacement is literal (no regex, no $-expansion).
"""
import sys
from pathlib import Path

PLACEHOLDER = b"/*@inline:%s@*/"


def fail(message, code=1):
    print(f"error: {message}", file=sys.stderr)
    sys.exit(code)


def first_missing_line(page, content):
    for number, line in enumerate(content.splitlines(), start=1):
        if line.strip() and line not in page:
            return number, line.decode("utf-8", "replace").strip()
    return None


def verify(page_path, sources):
    page = Path(page_path).read_bytes()
    missing = 0
    for source in sources:
        content = Path(source).read_bytes()
        if not content.strip():
            missing += 1
            print(f"MISSING {source}: the file is empty, so containing it proves nothing", file=sys.stderr)
            continue
        if content in page:
            print(f"ok {source} ({len(content)} bytes)")
            continue
        missing += 1
        hint = first_missing_line(page, content)
        where = f": line {hint[0]} not found: {hint[1][:80]}" if hint else ": every line is there, but not as one block"
        print(f"MISSING {source}{where}", file=sys.stderr)
    return missing == 0


def parse_pairs(pairs):
    parsed = []
    for pair in pairs:
        name, sep, source = pair.partition("=")
        if not sep or not name or not source:
            fail(f"expected NAME=FILE, got {pair!r}", 2)
        parsed.append((name.encode(), source))
    return parsed


def build(template_path, output_path, pairs):
    page = Path(template_path).read_bytes()
    sources = []
    for name, source in parse_pairs(pairs):
        content = Path(source).read_bytes()
        if b"</style" in content.lower():
            fail(f"{source} contains '</style', which would end the style element early")
        placeholder = PLACEHOLDER % name
        count = page.count(placeholder)
        if count != 1:
            fail(f"placeholder {placeholder.decode()} occurs {count} times in {template_path}, expected once")
        page = content.join(page.split(placeholder))
        sources.append(source)
    if b"/*@inline:" in page:
        fail("the page still holds an /*@inline:...@*/ placeholder that no NAME=FILE filled")
    Path(output_path).write_bytes(page)
    print(f"wrote {output_path}")
    return verify(output_path, sources)


def main(argv):
    if len(argv) >= 4 and argv[0] == "build":
        ok = build(argv[1], argv[2], argv[3:])
    elif len(argv) >= 3 and argv[0] == "verify":
        ok = verify(argv[1], argv[2:])
    else:
        print(__doc__, file=sys.stderr)
        return 2
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
