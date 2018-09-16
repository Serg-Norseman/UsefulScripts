#! /bin/sh
# Copyright (c) 2018, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: download_databases.sh [-p <download location>] [-t]"
  echo "                             [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:t" opt
do
  case ${opt} in
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

if test -z ${download_prefix}
then
  echo "Please use \`\`-p'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1
elif test -n ${tag}
then
  # We have to use extended (modern) regular expressions and not BRE, because we
  # need branches, and BRE does not have it (``|'').
  download_prefix=$(echo "${download_prefix}" | sed -n -E \
      -e "s/^(.{1,})([^\/])\/{0,1}$/\1\2\/${tag}/p")
fi
download_prefix=$(echo "${download_prefix}" | sed -n -E \
    -e "s/^(.{1,})([^\/])\/{0,1}$/\1\2/p")

if ! test -e ${download_prefix}
then
  mkdir -p ${download_prefix}
fi

arch=x86_64
mirror=https://mirrors.edge.kernel.org/archlinux
if test "$(fetch 2>&1 | grep -e 'usage')"
then
  fetch -o ${download_prefix} ${mirror}/core/os/${arch}/core.db
  fetch -o ${download_prefix} ${mirror}/community/os/${arch}/community.db
  fetch -o ${download_prefix} ${mirror}/extra/os/${arch}/extra.db
  fetch -o ${download_prefix} ${mirror}/multilib/os/${arch}/multilib.db
else
  wget -v -P ${download_prefix} ${mirror}/core/os/${arch}/core.db
  wget -v -P ${download_prefix} ${mirror}/community/os/${arch}/community.db
  wget -v -P ${download_prefix} ${mirror}/extra/os/${arch}/extra.db
  wget -v -P ${download_prefix} ${mirror}/multilib/os/${arch}/multilib.db
fi
