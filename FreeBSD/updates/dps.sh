#! /bin/sh
# Copyright (c) 2019-2020, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

# This script calls dsrc.sh and dports.sh ones passing its parameters through to
# those scripts.

PrintUsage()
{
  echo "Usage: dps.sh [-d <store location>] [-s [p][s]]"
  echo "              [-h]"
  exit 0;
}

if test 0 -eq $#
then
  PrintUsage
fi
while getopts ":hd:s:" COMMAND_LINE_ARGUMENT
do
  case ${COMMAND_LINE_ARGUMENT} in
    h) PrintUsage;;
    d) DESTDIR=${OPTARG%/};;
    s)
      if test "s" = ${OPTARG}
      then
        SRC_SVN="-s"
      elif test "p" = ${OPTARG}
      then
        PORTS_SVN="-s"
      elif test "ps" = ${OPTARG} -o "sp" = ${OPTARG}
      then
        SRC_SVN="-s"
        PORTS_SVN="-s"
      fi
      ;;
    \?) echo "\`\`${OPTARG}'' is an unknown option." 1>&2
      exit 1;;
    :) echo "\`\`${OPTARG}'' requires an argument." 1>&2
      exit 1;;
  esac
done

if test -z "${DESTDIR}"
then
  echo "Please use \`\`-d'' option to specify destination location."
  echo "'${0} -h' for more information."
  exit 1
fi
DESTDIR="${DESTDIR}"/"$(date -I)"

echo "Download the ports tree."
. $(/bin/realpath "${0%/*}")/dports.sh -d "${DESTDIR}" "${PORTS_SVN}"
echo "Download the source code."
. $(/bin/realpath "${0%/*}")/dsrc.sh -d "${DESTDIR}" "${SRC_SVN}"
