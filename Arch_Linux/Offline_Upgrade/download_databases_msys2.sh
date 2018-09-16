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
mirror=http://repo.msys2.org/msys
fetch_exists="$(fetch 2>&1 | grep -e 'usage')"
gpg_exists="$(gpg -h 2>&1 | grep -e 'Syntax')"
if test "${fetch_exists}"
then
  fetch -o ${download_prefix} ${mirror}/${arch}/msys.db \
      ${mirror}/${arch}/msys.db.sig
else
  wget -v -P ${download_prefix} ${mirror}/${arch}/msys.db \
      ${mirror}/${arch}/msys.db.sig
fi
if test "${gpg_exists}"
then
  gpg --verify ${download_prefix}/msys.db.sig 2>&1 | head --lines=4 | \
      sed -e 's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
      xargs -0 echo -e
fi
mirror=http://repo.msys2.org/mingw
if test "${fetch_exists}"
then
  fetch -o ${download_prefix} ${mirror}/${arch}/mingw64.db \
      ${mirror}/${arch}/mingw64.db.sig
else
  wget -v -P ${download_prefix} ${mirror}/${arch}/mingw64.db \
      ${mirror}/${arch}/mingw64.db.sig
fi
if test "${gpg_exists}"
then
  gpg --verify ${download_prefix}/mingw64.db.sig 2>&1 | head --lines=4 | \
      sed -e 's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
      xargs -0 echo -e
fi
arch=i686
if test "${fetch_exists}"
then
  fetch -o ${download_prefix} ${mirror}/${arch}/mingw32.db \
      ${mirror}/${arch}/mingw32.db.sig
else
  wget -v -P ${download_prefix} ${mirror}/${arch}/mingw32.db \
      ${mirror}/${arch}/mingw32.db.sig
fi
if test "${gpg_exists}"
then
  gpg --verify ${download_prefix}/mingw32.db.sig 2>&1 | head --lines=4 | \
      sed -e 's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
      xargs -0 echo -e
fi
