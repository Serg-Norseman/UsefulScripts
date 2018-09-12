#! /bin/sh
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: download_dependencies.sh [-f <'yarn.lock' file>]"
  echo "                                [-p <download location>]"
  echo "                                [-h]"
  exit 0
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hf:p:" opt
do
  case ${opt} in
    f)
      yarn_lock_file=${OPTARG};;
    h)
      PrintUsage;;
    p)
      download_prefix=${OPTARG};;
    \?)
      echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :)
      echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z ${yarn_lock_file}
then
  echo "Please use \`\`-f'' option to specify location of 'yarn.lock' file."
  echo "'${0} -h' for more information."
  exit 1;
fi
if test -z ${download_prefix}
then
  echo "Please use \`\`-p'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1;
fi

if ! test -e ${download_prefix}
then
  mkdir -p ${download_prefix}
fi

sed -n -e "/^ *resolved /s/^ *resolved \+\"\(.\+\)\"$/\1/p" \
    ${yarn_lock_file} | wget -P=${download_prefix} -v -i=- && \
    echo "The dependencies were successfully downloaded into the" \
    "\`\`${download_prefix}'' directory."
