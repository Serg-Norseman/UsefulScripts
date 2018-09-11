#! /bin/sh
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

date=$(date --utc --rfc-3339=seconds | \
    sed -e "s/\(\+\)00:00/\105:00/; s/ /_/g; s/\:/_/g")
download_prefix=./databases/${date}

mkdir --parents ${download_prefix}

arch=x86_64
mirror=https://mirrors.edge.kernel.org/\
archlinux
wget --directory-prefix=${download_prefix} \
    ${mirror}/core/os/${arch}/core.db
wget --directory-prefix=${download_prefix} \
    ${mirror}/community/os/${arch}/community.db
wget --directory-prefix=${download_prefix} \
    ${mirror}/extra/os/${arch}/extra.db
wget --directory-prefix=${download_prefix} \
    ${mirror}/multilib/os/${arch}/multilib.db
