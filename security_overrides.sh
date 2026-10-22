#!/bin/bash
# Usage: security_overrides.sh [python]  (default: python3)
PYTHON=${1:-python3}
# eth-brownie pins certifi/aiohttp/urllib3 exactly, so pip keeps old, vulnerable copies.
pins=$(mktemp)
# Upgrade them to the newest versions every *other* installed package still accepts.
"$PYTHON" - > "$pins" <<'PY'
import importlib.metadata as m, re
targets = {"certifi", "aiohttp", "urllib3"}
norm = lambda s: re.sub(r"[-_.]+", "-", s).lower()
have = {norm(d.metadata["Name"] or "") for d in m.distributions()}
for t in ("certifi>=2026.10.19", "aiohttp", "urllib3"):
    if t.startswith("certifi") or t in have:
        print(t)
for d in m.distributions():
    n = norm(d.metadata["Name"] or "")
    if n in targets or n == "eth-brownie":
        continue
    for r in d.requires or []:
        if "extra ==" in r:
            continue
        if norm(re.split(r"[\s;<>=!~\[(]", r, maxsplit=1)[0]) in targets:
            print(f"{n}=={d.version}")
            break
PY
"$PYTHON" -m pip install -q -U -r "$pins" || { echo "security_overrides: constrained upgrade failed, upgrading certifi only"; "$PYTHON" -m pip install -q -U "certifi>=2026.10.19"; }
"$PYTHON" -m pip list 2>/dev/null | grep -Ei '^(certifi|aiohttp|urllib3) '
exit 0
