#! /bin/bash

tag=${1:-"undefined"}
date=$(date --utc --rfc-3339=seconds | \
    sed -e "s/\(\+\)00:00/\105:00/; s/ /_/g; s/\:/_/g")
download_prefix=./packages/${date}_${tag}

mkdir --parents ${download_prefix}

echo $(cat packages_list | wc --lines) "file(s) to download".
wget --directory-prefix=${download_prefix} --verbose \
    --input-file=packages_list
