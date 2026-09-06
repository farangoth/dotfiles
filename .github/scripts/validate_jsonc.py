#!/usr/bin/env python3
"""Sanity-check that a JSONC file (JSON + // comments + trailing commas) is
well-formed, without pulling in an extra dependency for full JSONC parsing."""

import json
import re
import sys


def validate(path: str) -> None:
    with open(path) as f:
        content = f.read()

    content = re.sub(r"(?m)^\s*//.*$", "", content)
    content = re.sub(r"//.*", "", content)
    content = re.sub(r",(\s*[}\]])", r"\1", content)

    json.loads(content)
    print(f"{path}: valid JSONC")


if __name__ == "__main__":
    for path in sys.argv[1:]:
        validate(path)
