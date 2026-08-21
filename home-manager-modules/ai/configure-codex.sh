#!/bin/bash
set -euo pipefail

config=$1
output=$2
fallback='project_doc_fallback_filenames = ["CLAUDE.md"]'
status='status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]'
section=top
fallback_seen=
tui_seen=
status_seen=

if [[ -f "$config" ]]; then
	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$line" =~ ^[[:space:]]*\[.*\][[:space:]]*$ ]]; then
			if [[ $section == top && -z $fallback_seen ]]; then
				printf '%s\n\n' "$fallback"
				fallback_seen=1
			elif [[ $section == tui && -z $status_seen ]]; then
				printf '%s\n\n' "$status"
				status_seen=1
			fi

			if [[ "$line" =~ ^[[:space:]]*\[tui\][[:space:]]*$ ]]; then
				section=tui
				tui_seen=1
			else
				section=other
			fi
			printf '%s\n' "$line"
			continue
		fi

		if [[ $section == top && "$line" =~ ^[[:space:]]*project_doc_fallback_filenames[[:space:]]*= ]]; then
			if [[ -z $fallback_seen ]]; then
				printf '%s\n' "$fallback"
				fallback_seen=1
			fi
		elif [[ $section == tui && "$line" =~ ^[[:space:]]*status_line[[:space:]]*= ]]; then
			if [[ -z $status_seen ]]; then
				printf '%s\n' "$status"
				status_seen=1
			fi
		else
			printf '%s\n' "$line"
		fi
	done < "$config"
fi > "$output"

if [[ -z $fallback_seen ]]; then
	printf '\n%s\n' "$fallback" >> "$output"
fi
if [[ -z $tui_seen ]]; then
	printf '\n[tui]\n%s\n' "$status" >> "$output"
elif [[ $section == tui && -z $status_seen ]]; then
	printf '%s\n' "$status" >> "$output"
fi
