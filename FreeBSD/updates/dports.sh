#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
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
#   # ./dports.sh -p ~/freebsd-ports -s

PrintUsage()
{
  echo "Usage: dports.sh [-p <store location>] [-s]"
  echo "                 [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
no_dot_svn="--exclude ports/.svn"
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

# Update /usr/ports.
if test -d /usr/ports/.svn
then
  ${svn_cmd} update /usr/ports
else
  ${svn_cmd} checkout https://svn.FreeBSD.org/ports/head /usr/ports
fi

if test 0 -eq $?
then
  st_loc="${st_loc}"/r$(${svnversion_cmd} /usr/ports)
  if test ! -d "${st_loc}"
  then
    mkdir -p ${st_loc}
  fi

  cur_dir=$(pwd)
  cd ${st_loc}
  tar -cvvf ports.tar --format pax ${no_dot_svn} --exclude ports/distfiles \
-C /usr ports
  sha256 ports.tar > CHECKSUM.SHA256-ports
  sha512 ports.tar > CHECKSUM.SHA512-ports
  xz -zvF xz -C sha256 -T 0 ports.tar
  sha256 ports.tar.xz >> CHECKSUM.SHA256-ports
  sha512 ports.tar.xz >> CHECKSUM.SHA512-ports
  cd ${cur_dir}
else
  echo "svn toolset failed."
  exit 1
fi
