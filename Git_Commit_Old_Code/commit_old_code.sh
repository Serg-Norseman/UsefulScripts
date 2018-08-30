#! /bin/awk -f
# Copyright (c) 2016, Ruslan Garipov.
# Contacts: <ruslanngaripov@gmail.com>.
# License: MIT License (https://opensource.org/licenses/MIT).
# Author: Ruslan Garipov <ruslanngaripov@gmail.com>.

BEGIN { print "#! /bin/sh\n"
FS = "\t+"
}
/^[^#]/ {print "export GIT_COMMITTER_DATE=\"" $1 "\""
print "export GIT_AUTHOR_DATE=\"" $1 "\""
print "rm -rf ./help/"
print "rm -rf ./langs/"
print "rm -rf ./scripts/"
print "rm -rf ./src/"
print "rm -rf ./*.cmd"
print "rm -rf ./*.bat"
print "rm -rf ./*.nsi"
print "rm -rf ./*.nsh"
print "rm -rf ./*.txt"
print "cp --recursive --target-directory ./ " $2 "/*"
print "git add ."
print "git commit -S -m \"" $3 "\""
print "unset GIT_COMMITTER_DATE"
print "unset GIT_AUTHOR_DATE"
}
