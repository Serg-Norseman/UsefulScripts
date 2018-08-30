#!/bin/bash
# Build a commit frequency list.

ROW_LIMIT=20

git log --name-status $*		| \
	grep -E '^[A-Z]\s+'		| \
	cut -c3-500			| \
	sort				| \
	uniq -c				| \
	grep -vE '^ {6}1 '		| \
	sort -n				| \
tail --lines="$ROW_LIMIT"