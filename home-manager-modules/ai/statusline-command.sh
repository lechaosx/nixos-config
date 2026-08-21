#!/bin/bash
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
exec python3 "$HOME/.claude/statusline.py"
