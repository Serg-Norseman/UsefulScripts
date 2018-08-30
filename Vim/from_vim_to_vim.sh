#! /bin/bash
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

echo "This script transforms list of vim buffers, like"
echo "1 %a   \"src/lo_gui/worker_thread/update_device_state.hxx\" line 68"
echo "2  h   \"src/README_DB"                line 53\"
echo "3 #h   \"src/libtools/windows_api/handle/menu.hxx\" line 35"
echo "to command that runs vim to edit files opened in those buffers \
at the specified line numbers."
echo "Type a list of vim buffers below and add the empty line (or Ctrl+D to \
cancel):"
vim -c "$(sed -n -e '/^.\+\".\+\".\+line [0-9]\+$/{s/^.\+\"\(.\+\)\".\+line \([0-9]\+\)$/:e \1|:\2|/;H;g;s/\(.\+\)\n\(.\+\)/\1\2/;h;};/^$/{g;s/\(.\+\)|$/\1/p;q;};')"
