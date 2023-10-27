#!/bin/bash
## you need to have fzf for this script to work.

SOLN_DIR="$(realpath $(dirname $(realpath $0))/..)"

: ${EDITOR:=vim}

# get all the solutions, filepaths REMOVED
solutions=$(find "$SOLN_DIR" -name '*.md' -type f | sed 's/.md//g')

# choose from the list
selection=$(echo "$solutions" | fzf)

if [ ! -z "$selection" ]; then
	# Open the selected solution
	SOLNAME="$selection.md"
	touch "$SOLNAME"
	$EDITOR "$SOLNAME"
fi
