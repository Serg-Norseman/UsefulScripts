#! /bin/sh
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

yarn_lock_file=${1:?"Please specify path to \`\`yarn.lock'' file to \
extract dependencies from."}
date=$(date --utc --rfc-3339=seconds | sed \
    -e "s/\(\+\)00:00/\105:00/; s/ /_/g; s/\:/_/g")
download_prefix=${2:-./dependencies/${date}}

mkdir --parents ${download_prefix}

sed --silent \
    --expression "/^ *resolved /s/^ *resolved \+\"\(.\+\)\"$/\1/p" \
    ${yarn_lock_file} | wget --directory-prefix=${download_prefix} \
    --verbose --input-file=- && \
    echo "The dependencies were successfully downloaded into the" \
    "\`\`${download_prefix}'' directory."
