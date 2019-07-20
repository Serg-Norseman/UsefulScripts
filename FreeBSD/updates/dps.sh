#! /bin/sh
# Copyright (c) 2019, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script calls the dsrc.sh and dports.sh ones passing its parameters
# through to those scripts.

PrintUsage()
{
  echo "Usage: dps.sh [-p <store location>] [-s [p][s]]"
  echo "              [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hp:s:" opt
do
  case ${opt} in
    h) PrintUsage;;
    p) st_loc=${OPTARG};;
    s)
      if test "s" = ${OPTARG}
      then
        src_svn="-s"
      elif test "p" = ${OPTARG}
      then
        ports_svn="-s"
      elif test "ps" = ${OPTARG} -o "sp" = ${OPTARG}
      then
        src_svn="-s"
        ports_svn="-s"
      fi
      ;;
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
st_loc=st_loc/"$(date -I)"

echo "Download the ports tree"
./dports.sh -p "${st_loc}" "${ports_svn}"
echo "Download the source code"
./dsrc.sh -p "${st_loc}" "${src_svn}"
