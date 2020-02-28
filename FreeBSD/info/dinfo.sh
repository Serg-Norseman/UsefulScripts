#! /bin/sh
# Copyright (c) 2018-2020, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# NAME
# dinfo.sh - downloads books and articles from the FreeBSD Download site (from
# its ``en'' part†) in PDF format.
#
# SYNOPSIS
# dinfo.sh -d {destination directory} [-z]
# dinfo.sh -h
#
# DESCRIPTION
# dinfo.sh downloads the English-language documentation from the FreeBSD
# Download site into the ``destination directory''.  If the caller has specified
# `-z` option, this script creates tarball(s) for the downloaded directory(ies)
# (within the ``destination directory'') and removes the original
# directory(ies).
#
# The following options are available:
#
# -d    Directory where downloaded content is stored.  The content is mirrored
#       from the FreeBSD Download site.
#
# -z    Create packed tarballs and their checksums for each downloaded directory
#       inside the ``target directory''.  A downloaded directory itself is
#       removed.
#
# -h    Show script usage information.
#
# † The script downloads documentation it finds on this page:
# https://download.FreeBSD.org/ftp/doc/en/.

PrintUsage()
{
  echo "Usage: dinfo.sh [-d <download location>] [-z]"
  echo "                [-h]"
  exit 0;
}

INDEX_PAGE=https://download.FreeBSD.org/ftp/doc/en/
FORMAT=pdf

CreateTheFirstLayout()
{
  local download_prefix_1=${DESTDIR}
  local index_page_1=${INDEX_PAGE}
  local chapters_1=$(${fetch} -o - ${INDEX_PAGE} 2>/dev/null | \
sed -n -e "s/.\{1,\}<td.\{0,\}>\
<a href=\"\(.\{1,\}\)\" title=\".\{1,\}\">.\{1,\}<\/a><\/td>.\{1,\}/\1/p")
  for chapter_1 in ${chapters_1}
  {
    DESTDIR=${download_prefix_1}/${chapter_1}
    DESTDIR=${DESTDIR%/}
    mkdir -p ${DESTDIR}
    INDEX_PAGE=${index_page_1}${chapter_1}
    book=$(echo ${chapter_1} | sed -n -e "s/\([a-z]\{1,\}\)s\//\1.${FORMAT}/p")
    CreateTheSecondLayout
    # Make tarball if required.
    if test -n "${MKTAR}"
    then
      local trbl=$(echo ${chapter_1} |\
          sed -n -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
      (
        cd ${download_prefix_1}
        tar -cf ${trbl}.tar --format pax ${trbl}
        if test -f /sbin/sha256
        then
          /sbin/sha256 ${trbl}.tar > CHECKSUM.SHA256-${trbl}
          /sbin/sha512 ${trbl}.tar > CHECKSUM.SHA512-${trbl}
        else
          # This is for MSYS2 runtime's openssl package.  GNU coreutils'
          # sha{256,512}sum print result incompatible with FreeBSD's
          # sha{256,512}.
          openssl sha256 ${trbl}.tar > CHECKSUM.SHA256-${trbl}
          openssl sha512 ${trbl}.tar > CHECKSUM.SHA512-${trbl}
        fi
        xz -zF xz -C sha256 -T 0 ${trbl}.tar
        if test -f /sbin/sha256
        then
          /sbin/sha256 ${trbl}.tar.xz >> CHECKSUM.SHA256-${trbl}
          /sbin/sha512 ${trbl}.tar.xz >> CHECKSUM.SHA512-${trbl}
        else
          openssl sha256 ${trbl}.tar.xz >> CHECKSUM.SHA256-${trbl}
          openssl sha512 ${trbl}.tar.xz >> CHECKSUM.SHA512-${trbl}
        fi
        rm -r ${trbl}
      )
    fi
  }
}
CreateTheSecondLayout()
{
  local download_prefix_2=${DESTDIR}
  local index_page_2=${INDEX_PAGE}
  local chapters_2=$(${fetch} -o - ${INDEX_PAGE} 2>/dev/null | \
sed -n -e "s/.\{1,\}<td.\{0,\}>\
<a href=\"\(.\{1,\}\)\" title=\".\{1,\}\">.\{1,\}<\/a><\/td>.\{1,\}/\1/p")
  for chapter_2 in ${chapters_2}
  {
    DESTDIR=${download_prefix_2}/${chapter_2}
    DESTDIR=${DESTDIR%/}
    mkdir -p ${DESTDIR}
    INDEX_PAGE=${index_page_2}${chapter_2}
    DownloadBook
  }
}
DownloadBook()
{
  ${fetch} -o ${DESTDIR}/${book} ${INDEX_PAGE}${book}
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hd:z" COMMAND_LINE_ARGUMENT
do
  case ${COMMAND_LINE_ARGUMENT} in
    h) PrintUsage;;
    d) DESTDIR=${OPTARG%/};;
    z) MKTAR=1;;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${DESTDIR}"
then
  echo "Please use \`\`-d'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1
fi

mkdir -p ${DESTDIR}

if test "$(fetch 2>&1 | grep -e 'usage')"
then
  fetch=fetch
else
  fetch=curl
fi
CreateTheFirstLayout
