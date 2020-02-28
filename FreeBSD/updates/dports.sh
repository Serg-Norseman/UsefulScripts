#! /bin/sh
# Copyright (c) 2019-2020, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script updates/checkouts /usr/ports using the CURRENT svn repository,
# creates subdirectory within the specified directory, naming the subdirectory
# as r{revision number}, and puts tarball with content of /usr/ports inside the
# subdirectory.  The script also creats SHA-256 and SHA-512 checksums near the
# tarball.  This script never adds /usr/ports/distfiles into the tarball.
#
# For example, the following command updates /usr/ports and creates
# ~/freebsd-ports/r123456 directory where it puts: ports.tar.xz (packed tarball
# with the ports directory), CHECKSUM-SHA256-ports and CHECKSUM-SHA512-ports
# (checksums of unpacked and packed tarball).  Because `-s` is specified this
# script adds the .svn subdirectory into the tarball (otherwise it's ignored).
#
#   # ./dports.sh -d ~/freebsd-ports -s

PrintUsage()
{
  echo "Usage: dports.sh [-d <store location>] [-s]"
  echo "                 [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
NO_DOT_SVN="--exclude ports/.svn"
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

# Update /usr/ports.
if test -d /usr/ports/.svn
then
  ${SVN_CMD} update /usr/ports
else
  ${SVN_CMD} checkout https://svn.FreeBSD.org/ports/head /usr/ports
fi

if test 0 -eq $?
then
  DESTDIR_LCL="${DESTDIR}"/r$(${SVNVERSION_CMD} /usr/ports)
  mkdir -p ${DESTDIR_LCL}

  CURRENTDIR=$(pwd)
  cd ${DESTDIR_LCL}
  tar -cvvf ports.tar --format pax ${NO_DOT_SVN} --exclude ports/distfiles \
      -C /usr ports
  sha256 ports.tar > CHECKSUM.SHA256-ports
  sha512 ports.tar > CHECKSUM.SHA512-ports
  xz -zvF xz -C sha256 -T 0 ports.tar
  sha256 ports.tar.xz >> CHECKSUM.SHA256-ports
  sha512 ports.tar.xz >> CHECKSUM.SHA512-ports
  cd ${CURRENTDIR}
else
  echo "svn toolset failed."
  exit 1
fi
