#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngairpov@gmail.com>
# License: MIT License (https://opensource.org/licenses/MIT/).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>

# NAME
# usrc.sh - updates /usr/src directory using the specified downloaded tarball
# and checksums.
#
# SYNOPSIS
# usrc.sh -p sources [-r {svn revision}]
# usrc.sh -h
#
# DESCRIPTION
# Assuming that the ``sources'' directory contains tarball with the src
# subdirectory (from /usr/src) and two checksums of the tarball, this script
# checks SHA-256 and SHA-512 checksums of the tarball, cleans /usr/src (only
# /usr/src/sys/amd64/conf/RG77 remains) and untar the tarball into /usr.
#
# If the caller has specified the ``svn revision'', this script patches the
# /usr/src/sys/conf/newvers.sh file to force the specified revision in new
# kernels.
#
# The following options are available:
#
# -p    Directory with the following files: src.tar.xz (tarball containing src
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
  echo "Usage: usrc.sh [-p <source files location>] [-r <SVN revision>]"
  echo "               [-h]"
  exit 0
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:r:" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) src_dir=${OPTARG};;
    r) svn_rev=${OPTARG};;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${src_dir}"
then
  echo "Please use \`\`-p'' option to specify directory with src tarball and"
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
if test ! -f "${src_dir}/src.tar.xz"
then
  printf "There's no %s found in %s.\n" "src.tar.xz" "${src_dir}"
  exit 1
fi
if test ! -f "${src_dir}/CHECKSUM.SHA256-src"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA256-src" "${src_dir}"
  exit 1
fi
if test ! -f "${src_dir}/CHECKSUM.SHA512-src"
then
  printf "There's no %s found in %s.\n" "CHECKSUM.SHA512-src" "${src_dir}"
  exit 1
fi

# Verify the checksums.
chk_sum=$(sed -ne "s/^SHA256 \{0,1\}(.\{0,\}src.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${src_dir}/CHECKSUM.SHA256-src")
sha256 -c "${chk_sum}" "${src_dir}/src.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA256 checksum."
  exit 1
fi
chk_sum=$(sed -ne "s/^SHA512 \{0,1\}(.\{0,\}src.tar.xz) \{0,1\}= \
\([0-9a-f]\{1,\}\)\$/\1/p" "${src_dir}/CHECKSUM.SHA512-src")
sha512 -c "${chk_sum}" "${src_dir}/src.tar.xz"
if test ! 0 -eq $?
then
  echo "Bad SHA512 checksum."
  exit 1
fi

# The checksums are valid.  Clean the target (/usr/src) using the dedicated
# script and untar the ${src_dir}/src.tar.xz.
echo "Clean /usr/src remaining my kernel config in place."
/root/rmsrc.sh
printf "Untar %s into /usr.\n" "${src_dir}/src.tar.xz"
tar -xf "${src_dir}/src.tar.xz" -C /usr
# Patch the /usr/src/sys/conf/newvers.sh if necessary.
if test -n "${svn_rev}"
then
  echo "Patch /usr/src/sys/conf/newvers.sh."
  tmp_patch=$(mktemp -t newvers.sh.patch)
  echo "--- /usr/src/sys/conf/newvers.sh.orig 2019-07-11 17:36:40.465037000 +0500" > ${tmp_patch}
  echo "+++ /usr/src/sys/conf/newvers.sh  2019-07-11 17:42:01.823922000 +0500" >> ${tmp_patch}
  echo "@@ -317,6 +317,13 @@" >> ${tmp_patch}
  echo " 	fi" >> ${tmp_patch}
  echo " fi" >> ${tmp_patch}
  echo "" >> ${tmp_patch}
  echo "+# Specify Subversion's revision explicitly for a) my \`\`RG77'' kernel config," >> ${tmp_patch}
  echo "+# and b) absence of the .svn meta-directory.  Actually, the latter is not a big" >> ${tmp_patch}
  echo "+# problem and I can bring it to this host, but lacking the svn toolset in the" >> ${tmp_patch}
  echo "+# kernel and/or installed subversion port I have to specify the revision of the" >> ${tmp_patch}
  echo "+# /usr/src here." >> ${tmp_patch}
  echo "+svn=\" r${svn_rev}\"" >> ${tmp_patch}
  echo "+" >> ${tmp_patch}
  echo ' [ ${include_metadata} = "if-modified" -a ${modified} = "yes" ] && include_metadata=yes' >> ${tmp_patch}
  echo ' if [ ${include_metadata} != "yes" ]; then' >> ${tmp_patch}
  echo ' 	VERINFO="${VERSION}${svn}${git}${hg} ${i}"' >> ${tmp_patch}
  patch -up0 --posix < ${tmp_patch}
  if test 0 -eq $?
  then
    echo "Revert the patch using \`patch -Rup0 < ${tmp_patch}\`"
  else
    echo "Patching failed"
    exit 1
  fi
fi
