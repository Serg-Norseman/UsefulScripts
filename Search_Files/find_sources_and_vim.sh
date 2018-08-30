#! /bin/bash
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script searches for files, which names match the specified regex
# ('.+\.[hcxr]+'), and which contain the text specified as the command line
# first argument, and then opens found files in Vim editor.
vim $(find -type f -regex '.+\.[hcxr]+' | xargs grep -l -e "$1" | \
  sed -n -e 'H;g;y/\n/ /;h;$P')
