#! /bin/sh
# Copyright (c) 2018-2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

PrintUsage()
{
  echo "Usage: dinfo.sh [-p <download location>] [-z]"
  echo "                [-h]"
  exit 0;
}

index_page=https://download.freebsd.org/ftp/doc/en/
format=pdf

CreateTheFirstLayout()
{
  local download_prefix_1=${download_prefix}
  local index_page_1=${index_page}
  local chapters_1=$(${fetch} -o - ${index_page} 2>/dev/null | \
sed -n -e "s/.\{1,\}<td.\{0,\}>\
<a href=\"\(.\{1,\}\)\" title=\".\{1,\}\">.\{1,\}<\/a><\/td>.\{1,\}/\1/p")
  for chapter_1 in ${chapters_1}
  {
    download_prefix=$(echo ${download_prefix_1}/${chapter_1} | sed -n \
        -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
    if test ! -e "${download_prefix}"
    then
      mkdir ${download_prefix}
    fi
    index_page=${index_page_1}${chapter_1}
    book=$(echo ${chapter_1} | sed -n -e "s/\([a-z]\{1,\}\)s\//\1.${format}/p")
    CreateTheSecondLayout
    # Make tarball if required.
    if test -n "${mktar}"
    then
      trbl=$(echo ${chapter_1} |\
          sed -n -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
      tar -c --format pax -f - -C ${download_prefix_1} ${trbl} | xz -z -F xz \
          -C sha256 > ${download_prefix_1}/${trbl}.tar.xz
    fi
  }
}
CreateTheSecondLayout()
{
  local download_prefix_2=${download_prefix}
  local index_page_2=${index_page}
  local chapters_2=$(${fetch} -o - ${index_page} 2>/dev/null | \
sed -n -e "s/.\{1,\}<td.\{0,\}>\
<a href=\"\(.\{1,\}\)\" title=\".\{1,\}\">.\{1,\}<\/a><\/td>.\{1,\}/\1/p")
  for chapter_2 in ${chapters_2}
  {
    download_prefix=$(echo ${download_prefix_2}/${chapter_2} | sed -n \
        -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
    if test ! -e "${download_prefix}"
    then
      mkdir ${download_prefix}
    fi
    index_page=${index_page_2}${chapter_2}
    DownloadBook
  }
}
DownloadBook()
{
  ${fetch} -o ${download_prefix}/${book} ${index_page}${book}
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:z" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) download_prefix=${OPTARG};;
    z) mktar=1;;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${download_prefix}"
then
  echo "Please use \`\`-p'' option to specify download (target) location."
  echo "'${0} -h' for more information."
  exit 1
fi
if test 1 -lt ${#download_prefix}
then
  download_prefix=$(echo ${download_prefix} | sed -n \
      -e "s/^\(.\{1,\}\)\([^\\/]\)\\/\{0,1\}\$/\1\2/p")
fi

if test ! -e "${download_prefix}"
then
  mkdir -p ${download_prefix}
fi

if test "$(fetch 2>&1 | grep -e 'usage')"
then
  fetch=fetch
else
  fetch=curl
fi
CreateTheFirstLayout
