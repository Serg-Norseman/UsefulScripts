#! /bin/bash
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

echo 'Search non-Unix line endings'
echo '# git-ls-files'
git ls-files --cached --modified --others --exclude-standard --eol | \
  grep 'mixed\|crlf.\+' | sed -e 's/\(.\+\.\(vcxproj\|sln\)\.\?.*\)/\1 \
  \\033[1;30m[Visual Studio file]\\033[0m/' | xargs -0 echo -e
echo '# dos2unix'
find -type f \! \( -regex '\./\.git/.+' -o -regex '\./build/.+' \) | \
  xargs dos2unix -i | grep '^[[:space:]]\+[1-9]' | \
  sed -e 's/\(.\+\)\(binary\)\(.\+\)/\1\\033[1;30m\2\\033[0m\3/' | \
  xargs -0 echo -e
find -type f \! \( -regex '\./\.git/.+' -o -regex '\./build/.+' \) | \
  xargs dos2unix -i | grep -v 'no_bom' | \
  sed -e 's/\(.\+\)\(binary\)\(.\+\)/\1\\033[1;30m\2\\033[0m\3/' | \
  xargs -0 echo -e

# Possible usage example:
# bin/crlf | \
# sed -n -e 's/ \+[0-9]\+ \+[0-9]\+ \+[0-9]\+ \+UTF\-8 \+ text \+\(.\+\)/\1/p' \
# | xargs dos2unix -r
# to remove the BOM from the text files from this script's output.
