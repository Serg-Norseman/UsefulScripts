#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: dsrc.sh [-p <store location>] [-s]"
  echo "               [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
no_dot_svn="--exclude .svn"
while getopts ":hsp:" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) st_loc=${OPTARG};;
    s) unset no_dot_svn;;
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
tar -cvvf src.tar --format pax ${no_dot_svn} -C /usr src
openssl sha256 src.tar > CHECKSUM.SHA256-src
openssl sha512 src.tar > CHECKSUM.SHA512-src
xz -zv -F xz -C sha256 -T 0 src.tar
openssl sha256 src.tar.xz >> CHECKSUM.SHA256-src
openssl sha512 src.tar.xz >> CHECKSUM.SHA512-src
cd ${cur_dir}
