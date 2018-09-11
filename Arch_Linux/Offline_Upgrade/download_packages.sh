#! /bin/sh
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

tag=${1:-"undefined"}
pack_list=${2:-"package_list"}

if test -f ${pack_list}
then
date=$(date --utc --rfc-3339=seconds | \
    sed -e "s/\(\+\)00:00/\105:00/; s/ /_/g; s/\:/_/g")
download_prefix=./packages/${date}_${tag}

if ! test -e ${download_prefix}
then
mkdir --parents ${download_prefix}
fi

echo $(cat ${pack_list} | wc --lines) "file(s) to download".
wget --directory-prefix=${download_prefix} --verbose \
    --input-file=${pack_list}
else
echo "File \`\`${pack_list}'' does not exist."
fi
