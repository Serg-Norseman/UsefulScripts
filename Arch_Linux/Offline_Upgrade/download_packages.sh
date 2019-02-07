#! /bin/sh
# Copyright (c) 2018-2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: download_databases.sh [-f <package list file>]"
  echo "                             [-p <download location>] [-t]"
  echo "                             [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hf:p:t" opt
do
  case ${opt} in
    f) package_list_file=${OPTARG};;
    h) PrintUsage;;
    p) download_prefix=${OPTARG};;
    t) date=$(date -u "+%Y-%m-%d_%H_%M_%S_%Z")
      tag=${date};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test ! -f "${package_list_file}"
then
  echo "Please use \`\`-f'' option to specify location of existing package" \
      "list file."
  echo "'${0} -h' for more information."
  exit 1
fi
if test -z "${download_prefix}"
then
  echo "Please use \`\`-p'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1
elif test -n "${tag}"
then
  if test 1 -lt ${#download_prefix}
  then
    download_prefix=$(echo "${download_prefix}" | sed -n \
        -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2\/${tag}/p")
  else
    if test "/" != "${download_prefix}"
    then
      download_prefix=${download_prefix}/${tag}
    else
      download_prefix=${download_prefix}${tag}
    fi
  fi
fi
if test 1 -lt ${#download_prefix}
then
  download_prefix=$(echo "${download_prefix}" | sed -n \
      -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
fi

if test ! -e "${download_prefix}"
then
  mkdir -p ${download_prefix}
fi

echo $(cat ${package_list_file} | wc -l | \
    sed -n -e "s/^ \{0,\}\([0-9]\{1,\}\)$/\1/p") "file(s) to download".
if test "$(fetch 2>&1 | grep -e 'usage')"
then
  if test 1 -lt ${#download_prefix}
  then
    download_prefix=$(echo "${download_prefix}" | sed -e "s/\\//\\\\\//g")
  fi
  sed -n -e "s/^\(.\{1,\}\)$/\
fetch -o ${download_prefix} \1/p" ${package_list_file} | /bin/sh -s
else
  wget -v -P ${download_prefix} -i ${package_list_file}
fi
