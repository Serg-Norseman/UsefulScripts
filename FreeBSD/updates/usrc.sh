#! /bin/sh
# Copyright (c) 2019-2020, Ruslan Garipov.
# Contacts: <ruslanngairpov@gmail.com>
# License: MIT License (https://opensource.org/licenses/MIT/).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>

# NAME
# usrc.sh - updates content of /usr/src directory using the specified downloaded
# tarball and checksums.
#
# SYNOPSIS
# usrc.sh -s sources [-r {svn revision}]
# usrc.sh -h
#
# DESCRIPTION
# Assuming that the ``sources'' directory contains tarball with the src
# subdirectory (i.e. /usr/src) and two checksums of the tarball, this script
# checks SHA-256 and SHA-512 checksums of the tarball, cleans /usr/src (only my
# kernel configs remain) and untar the tarball into /usr.
#
# If the caller has specified the ``svn revision'', this script patches
# /usr/src/sys/conf/newvers.sh file to force the specified revision in new
# kernel(s).
#
# The following options are available:
#
# -s    Directory with the following files: src.tar.xz (tarball containing src
#       directory (a subdirectory of /usr), CHECKSUM.SHA256-src (SHA-256
#       checksum of the src.tar.xz) and CHECKSUM.SHA512-src (SHA-512 checksum of
#       the tarball).
#
# -r    SVN revision number.  Must be a result of svnversion or svnliteversion
#       executed within SVN working copy of the
#       https://svn.FreeBSD.org/base/head repository.
#
# -h    Show script usage information.

PrintUsage()
{
  echo "Usage: usrc.sh [-s <source files location>] [-r <SVN revision>]"
  echo "               [-h]"
  exit 0
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hs:r:" COMMAND_LINE_ARGUMENT
do
  case ${COMMAND_LINE_ARGUMENT} in
    h) PrintUsage;;
    s) SOURCEDIR=${OPTARG%/};;
    r) SVN_REV=${OPTARG};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${SOURCEDIR}"
then
  echo "Please use \`\`-s'' option to specify directory with src tarball and"
  echo "its checksums."
  echo "'${0} -h' for more information."
  exit 1
fi

# Check content of the ${SOURCEDIR}.
if test ! -f "${SOURCEDIR}/src.tar.xz"
then
  printf "There's no %s found in %s.\n" "src.tar.xz" "${SOURCEDIR}"
  exit 1
fi
if test ! -f "${SOURCEDIR}/CHECKSUM.SHA256-src"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA256-src" "${SOURCEDIR}"
  exit 1
fi
if test ! -f "${SOURCEDIR}/CHECKSUM.SHA512-src"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA512-src" "${SOURCEDIR}"
  exit 1
fi

# Verify the checksums.
chk_sum=$(sed -ne "s/^SHA256 \{0,1\}(.\{0,\}src.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${SOURCEDIR}/CHECKSUM.SHA256-src")
sha256 -c "${chk_sum}" "${SOURCEDIR}/src.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA256 checksum."
  exit 1
fi
chk_sum=$(sed -ne "s/^SHA512 \{0,1\}(.\{0,\}src.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${SOURCEDIR}/CHECKSUM.SHA512-src")
sha512 -c "${chk_sum}" "${SOURCEDIR}/src.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA512 checksum."
  exit 1
fi

# The checksums are valid.  Clean the target (/usr/src) using the dedicated
# script and untar the ${SOURCEDIR}/src.tar.xz.
echo "Clean /usr/src remaining my kernel config in place."
$(/bin/realpath "${0%/*}")/rmsrc.sh
if test ! 0 -eq $?
then
  echo "Unable to clean /usr/src."
  exit 1
fi
printf "Untar %s into /usr.\n" "${SOURCEDIR}/src.tar.xz"
tar -xf "${SOURCEDIR}/src.tar.xz" -C /usr
# Patch the /usr/src/sys/conf/newvers.sh if necessary.
if test -n "${SVN_REV}"
then
  echo "Patch /usr/src/sys/conf/newvers.sh."
  TMP_PATCH=$(mktemp -t newvers.sh.patch)
  echo "--- /usr/src/sys/conf/newvers.sh.orig 2019-07-11 17:36:40.465037000 +0500" > ${TMP_PATCH}
  echo "+++ /usr/src/sys/conf/newvers.sh  2019-07-11 17:42:01.823922000 +0500" >> ${TMP_PATCH}
  echo "@@ -317,6 +317,13 @@" >> ${TMP_PATCH}
  echo " 	fi" >> ${TMP_PATCH}
  echo " fi" >> ${TMP_PATCH}
  echo "" >> ${TMP_PATCH}
  echo "+# Specify Subversion's revision for my kernel config(s) explicitly" >> ${TMP_PATCH}
  echo "+# because of absence of the .svn meta-directory.  Actually, the latter is not a big" >> ${TMP_PATCH}
  echo "+# problem and I can bring it to this host, but lacking the svn toolset in the" >> ${TMP_PATCH}
  echo "+# kernel and/or installed subversion port I have to specify the revision of the" >> ${TMP_PATCH}
  echo "+# /usr/src here." >> ${TMP_PATCH}
  echo "+svn=\" r${SVN_REV}\"" >> ${TMP_PATCH}
  echo "+" >> ${TMP_PATCH}
  echo ' [ ${include_metadata} = "if-modified" -a ${modified} = "yes" ] && include_metadata=yes' >> ${TMP_PATCH}
  echo ' if [ ${include_metadata} != "yes" ]; then' >> ${TMP_PATCH}
  echo ' 	VERINFO="${VERSION}${svn}${git}${hg} ${i}"' >> ${TMP_PATCH}
  patch -up0 --posix < ${TMP_PATCH}
  if test 0 -eq $?
  then
    echo "Revert the patch using \`patch --posix -Rup0 < ${TMP_PATCH}\`"
  else
    echo "Patching failed"
    exit 1
  fi
fi
