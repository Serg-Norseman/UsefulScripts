#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script updates/checkouts /usr/src using the CURRENT svn repository,
# creates subdirectory within the specified directory, naming the subdirectory
# as r{revision number}, and puts tarball with content of /usr/src inside the
# subdirectory.  The script also creats SHA-256 and SHA-512 checksums near the
# tarball.
#
# For example, the following command updates /usr/src and creates
# ~/freebsd-src/r123456 directory where it puts: src.tar.xz (packed tarball with
# the src directory), CHECKSUM-SHA256-src and CHECKSUM-SHA512-src (checksums of
# unpacked and packed tarball).  Because `-s` is specified this script adds the
# .svn subdirectory into the tarball (otherwise it's ignored).
#
#   # ./dsrc.sh -p ~/freebsd-src -s

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
no_dot_svn="--exclude src/.svn"
while getopts ":hp:s" opt
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

# Search svn or svnlite.
for p in /usr/bin /usr/local/bin
do
  for s in svn svnlite
  do
    if test -f ${p}/${s}
    then
      svn_cmd=${p}/${s}
    fi
  done
done
for p in /usr/bin /usr/local/bin
do
  for s in svnversion svnliteversion
  do
    if test -f ${p}/${s}
    then
      svnversion_cmd=${p}/${s}
    fi
  done
done

if test -z "${svn_cmd}" -o -z "${svnversion_cmd}"
then
  echo "Unable to find svn toolset."
  exit 1
fi

# Update /usr/src.
if test -d /usr/src/.svn
then
  ${svn_cmd} update /usr/src
else
  ${svn_cmd} checkout https://svn.FreeBSD.org/base/head /usr/src
fi

if test 0 -eq $?
then
  st_loc="${st_loc}"/r$(${svnversion_cmd} /usr/src)
  if test ! -d "${st_loc}"
  then
    mkdir -p ${st_loc}
  fi

  cur_dir=$(pwd)
  cd ${st_loc}
  tar -cvvf src.tar --format pax ${no_dot_svn} -C /usr src
  sha256 src.tar > CHECKSUM.SHA256-src
  sha512 src.tar > CHECKSUM.SHA512-src
  xz -zvF xz -C sha256 -T 0 src.tar
  sha256 src.tar.xz >> CHECKSUM.SHA256-src
  sha512 src.tar.xz >> CHECKSUM.SHA512-src
  cd ${cur_dir}
else
  echo "svn toolset failed."
  exit 1
fi
