#! /bin/sh

find /usr/ports -d -depth 1 -a \( -type f -o \
    -not \( -type d -a -name distfiles \) \) -exec rm -r \{\} \; && exit 0
