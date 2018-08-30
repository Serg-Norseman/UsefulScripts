#! /bin/bash
# Copyright (c) 2016, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

LC_ALL=en_US.utf8 grep --color='auto' -P -n -r -H --include='*.cs' --exclude='exc.cs' '\p{Cyrillic}'
