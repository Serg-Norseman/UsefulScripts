#! /bin/sh
# Copyright (c) 2019-2020, Ruslan Garipov.
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
#   # ./dsrc.sh -d ~/freebsd-src -s

PrintUsage()
{
  echo "Usage: dsrc.sh [-d <store location>] [-s]"
  echo "               [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
NO_DOT_SVN="--exclude src/.svn"
while getopts ":hd:s" COMMAND_LINE_ARGUMENT
do
  case ${COMMAND_LINE_ARGUMENT} in
    h) PrintUsage;;
    d) DESTDIR=${OPTARG%/};;
    s) unset NO_DOT_SVN;;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${DESTDIR}"
then
  echo "Please use \`\`-d'' option to specify store (target) location."
  echo "'${0} -h' for more information."
  exit 1
fi

# Search svn or svnlite.
for P in /usr/bin /usr/local/bin
do
  for S in svn svnlite
  do
    if test -f ${P}/${S}
    then
      SVN_CMD=${P}/${S}
    fi
  done
done
for P in /usr/bin /usr/local/bin
do
  for S in svnversion svnliteversion
  do
    if test -f ${P}/${S}
    then
      SVNVERSION_CMD=${P}/${S}
    fi
  done
done

if test -z "${SVN_CMD}" -o -z "${SVNVERSION_CMD}"
then
  echo "Unable to find svn toolset."
  exit 1
fi

# Update /usr/src.
if test -d /usr/src/.svn
then
  ${SVN_CMD} update /usr/src
else
  ${SVN_CMD} checkout https://svn.FreeBSD.org/base/head /usr/src
fi

if test 0 -eq $?
then
  DESTDIR="${DESTDIR}"/r$(${SVNVERSION_CMD} /usr/src)
  mkdir -p ${DESTDIR}

  CURRENTDIR=$(pwd)
  cd ${DESTDIR}
  tar -cvvf src.tar --format pax ${NO_DOT_SVN} -C /usr src
  sha256 src.tar > CHECKSUM.SHA256-src
  sha512 src.tar > CHECKSUM.SHA512-src
  xz -zvF xz -C sha256 -T 0 src.tar
  sha256 src.tar.xz >> CHECKSUM.SHA256-src
  sha512 src.tar.xz >> CHECKSUM.SHA512-src
  cd ${CURRENTDIR}
else
  echo "svn toolset failed."
  exit 1
fi
