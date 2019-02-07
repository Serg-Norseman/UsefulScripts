#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: dbu.sh [-c] [-p <download location>]"
  echo "              [-h]"
  echo "It is recommended to end the \`\`download location'' with"
  echo "\`\`freebsd-update'' name."
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:c" opt
do
  case ${opt} in
    c) rm_fname=1;;
    h) PrintUsage;;
    p) dl_loc=${OPTARG};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${dl_loc}"
then
  echo "Please use \`\`-p'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1
fi
if test 1 -lt "${#dl_loc}"
then
  dl_loc=$(echo ${dl_loc} | sed -n -e \
      "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
elif test 1 -eq ${#dl_loc}
then
  echo "\`\`-p'' must not be the root"
  exit 1
fi

if test ! -e "${dl_loc}"
then
  mkdir -p ${dl_loc}
fi

/usr/sbin/freebsd-update -d ${dl_loc} fetch
cur_dir=$(pwd)
chg_dir=$(echo "${dl_loc}" | sed -n -e "s/^\(.\{0,\}\\/\).\{1,\}\$/\1/p")
if test 1 -lt ${#chg_dir}
then
  chg_dir=$(echo "${chg_dir}" | sed -n -e \
      "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
fi
if test -n "${chg_dir}"
then
  esc_chg_dir=$(echo "${chg_dir}" | sed -e "s/\\//\\\\\//g")
  fname=$(echo "${dl_loc}" | sed -n -e \
      "s/^${esc_chg_dir}\\/\{0,1\}\(.\{1,\}\)\$/\1/p")
else
  fname=${dl_loc}
fi
cd ${chg_dir}
tar -cvv --format pax -f ${fname}.tar ${fname}
openssl sha256 ${fname}.tar > CHECKSUM.SHA256-${fname}
openssl sha512 ${fname}.tar > CHECKSUM.SHA512-${fname}
xz -zv -F xz -C sha256 -T 0 ${fname}.tar
openssl sha256 ${fname}.tar.xz >> CHECKSUM.SHA256-${fname}
openssl sha512 ${fname}.tar.xz >> CHECKSUM.SHA512-${fname}
if test -n "${rm_fname}"
then
  rm -r ${fname}
fi
cd ${cur_dir}
