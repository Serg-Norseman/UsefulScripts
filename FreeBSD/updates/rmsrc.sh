#! /bin/sh

find /usr/src -d \! \( \( -type l -a \
    -regex /usr/src/sys/amd64/conf/GARIPOV15_2 \) -o -regex /usr/src \) \
    -delete && exit 0
