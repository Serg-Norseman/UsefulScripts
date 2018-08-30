#! /bin/bash
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script searches for files, which names match the specified regex
# ('.+\.[hcxr]+'), and which contain text specified as the first command
# line argument.
find -type f -regex '.+\.[hcxr]+' | xargs grep -n --color -e "$1"
