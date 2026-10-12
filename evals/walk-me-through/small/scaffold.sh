#!/usr/bin/env bash
set -e
cat > utils.py <<'P'
import re


def slugify(text):
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
P
