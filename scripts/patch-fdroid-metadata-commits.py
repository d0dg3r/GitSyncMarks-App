#!/usr/bin/env python3
"""Set F-Droid YAML build commit SHAs after a release commit.

- Submit file: replace the single `    commit:` under Builds.
- Dev metadata: replace only the *last* `    commit: <40 hex>` (latest build block).
"""
from __future__ import annotations

import re
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: patch-fdroid-metadata-commits.py <40-char-sha> <yaml>...", file=sys.stderr)
        sys.exit(2)
    sha = sys.argv[1].strip()
    if len(sha) != 40 or not re.match(r"^[0-9a-f]+$", sha):
        print("ERROR: expected lowercase 40-char hex commit sha", file=sys.stderr)
        sys.exit(1)

    for path_str in sys.argv[2:]:
        path = Path(path_str)
        text = path.read_text(encoding="utf-8")
        name = path.name

        if "fdroid-submit" in name:
            new_text, n = re.subn(
                r"^    commit:.*$",
                f"    commit: {sha}",
                text,
                count=1,
                flags=re.MULTILINE,
            )
            if n != 1:
                print(f"ERROR: expected one commit line in {path}", file=sys.stderr)
                sys.exit(1)
        else:
            matches = list(
                re.finditer(r"^    commit: [0-9a-f]{40}$", text, flags=re.MULTILINE)
            )
            if not matches:
                print(f"ERROR: no `    commit: <sha>` lines in {path}", file=sys.stderr)
                sys.exit(1)
            m = matches[-1]
            new_text = text[: m.start()] + f"    commit: {sha}" + text[m.end() :]

        path.write_text(new_text, encoding="utf-8")
        print(f"Patched {path}")


if __name__ == "__main__":
    main()
