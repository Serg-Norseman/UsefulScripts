#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngairpov@gmail.com>
# License: MIT License (https://opensource.org/licenses/MIT/).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>

# NAME
# uports.sh - updates /usr/ports directory using the specified downloaded
# tarball and checksums.
#
# SYNOPSIS
# uports.sh -p sources
# uports.sh -h
#
# DESCRIPTION
# Assuming that the ``sources'' directory contains tarball with the ports
# subdirectory (from /usr/ports) and two checksums of the tarball, this script
# checks SHA-256 and SHA-512 checksums of the tarball, cleans /usr/ports (only
# /usr/ports/distfiles remains) and untar the tarball into /usr.
#
# The following options are available:
#
# -p    Directory with the following files: ports.tar.xz (tarball containing
#       ports directory (a subdirectory of /usr), CHECKSUM.SHA256-ports (SHA-256
#       checksum of the ports.tar.xz) and CHECKSUM.SHA512-ports (SHA-512
#       checksum of the tarball).
#
# -h    Show script usage information.

PrintUsage()
{
  echo "Usage: uports.sh [-p <source files location>]"
  echo "                 [-h]"
  exit 0
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) src_dir=${OPTARG};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${src_dir}"
then
  echo "Please use \`\`-p'' option to specify directory with ports tarball and"
  echo "its checksums."
  echo "'${0} -h' for more information."
  exit 1
fi
if test 1 -lt "${#src_dir}"
then
  src_dir=$(echo ${src_dir} | sed -ne \
      "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
fi

# Check content of the ${src_dir}.
if test ! -f "${src_dir}/ports.tar.xz"
then
  printf "There's no %s found in %s.\n" "ports.tar.xz" "${src_dir}"
  exit 1
fi
if test ! -f "${src_dir}/CHECKSUM.SHA256-ports"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA256-ports" "${src_dir}"
  exit 1
fi
if test ! -f "${src_dir}/CHECKSUM.SHA512-ports"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA512-ports" "${src_dir}"
  exit 1
fi

# Verify the checksums.
chk_sum=$(sed -ne "s/^SHA256 \{0,1\}(.\{0,\}ports.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${src_dir}/CHECKSUM.SHA256-ports")
sha256 -c "${chk_sum}" "${src_dir}/ports.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA256 checksum."
  exit 1
fi
chk_sum=$(sed -ne "s/^SHA512 \{0,1\}(.\{0,\}ports.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${src_dir}/CHECKSUM.SHA512-ports")
sha512 -c "${chk_sum}" "${src_dir}/ports.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA512 checksum."
  exit 1
fi

# The checksums are valid.  Clean the target (/usr/ports) using the dedicated
# script and untar the ${src_dir}/ports.tar.xz.
echo "Clean /usr/ports remaining /usr/ports/distfiles in place."
/root/rmports.sh
printf "Untar %s into /usr.\n" "${src_dir}/ports.tar.xz"
tar -xf "${src_dir}/ports.tar.xz" -C /usr
# Patch /usr/ports/Mk/Scripts/do-fetch.sh file.  The latter was updated by
# r507705 in order to fix bug 239293.  But r507705 missed -n in an `echo`.
# While waiting for a new fix, apply patch here.
echo "Patch /usr/ports/Mk/Scripts/do-fetch.sh."
tmp_patch=$(mktemp -t do-fetch.sh.patch)
echo "--- /usr/ports/Mk/Scripts/do-fetch.sh.orig	2019-08-04 18:55:11.394671000 +0500" > ${tmp_patch}
echo "+++ /usr/ports/Mk/Scripts/do-fetch.sh	2019-08-06 11:21:52.993949000 +0500" >> ${tmp_patch}
echo "@@ -128,7 +128,7 @@" >> ${tmp_patch}
echo " 			*/*)" >> ${tmp_patch}
echo " 				case \${dp_TARGET} in" >> ${tmp_patch}
echo " 				fetch-list|fetch-url-list-int)" >> ${tmp_patch}
echo "-					echo \"mkdir -p \\\"\${file%/*}\\\" && \"" >> ${tmp_patch}
echo "+					echo -n \"mkdir -p \\\"\${file%/*}\\\" && \"" >> ${tmp_patch}
echo " 					;;" >> ${tmp_patch}
echo " 				*)" >> ${tmp_patch}
echo " 					mkdir -p \"\${file%/*}\"" >> ${tmp_patch}
patch -up0 --posix < ${tmp_patch}
if test 0 -eq $?
then
  echo "Revert the patch using \`patch -Rup0 < ${tmp_patch}\`"
else
  echo "Patching failed"
  exit 1
fi
