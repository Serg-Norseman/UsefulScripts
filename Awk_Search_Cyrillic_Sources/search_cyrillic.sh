#! /bin/awk -f
# Copyright (C) 2016 by Ruslan Garipov.

LC_ALL=en_US.utf8 grep --color='auto' -P -n -r -H --include='*.cs' --exclude='exc.cs' '\p{Cyrillic}'
