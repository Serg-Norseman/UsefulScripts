#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: dports.sh [-p <store location>]"
  echo "                 [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) st_loc=${OPTARG};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${st_loc}"
then
  echo "Please use \`\`-p'' option to specify store (target) location."
  echo "'${0} -h' for more information."
  exit 1
fi
if test 1 -lt "${#st_loc}"
then
  st_loc=$(echo ${st_loc} | sed -n -e \
      "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
fi

if test ! -e "${st_loc}"
then
  mkdir -p ${st_loc}
fi

cur_dir=$(pwd)
cd ${st_loc}
tar -cvv --format pax -f ports.tar -C /usr --exclude .svn --exclude distfiles \
    ports
openssl sha256 ports.tar > CHECKSUM.SHA256-ports
openssl sha512 ports.tar > CHECKSUM.SHA512-ports
xz -zv -F xz -C sha256 -T 0 ports.tar
openssl sha256 ports.tar.xz >> CHECKSUM.SHA256-ports
openssl sha512 ports.tar.xz >> CHECKSUM.SHA512-ports
cd ${cur_dir}
