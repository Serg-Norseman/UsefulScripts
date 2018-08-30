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
print "rm -rf help langs scripts src *.{cmd,bat,nsi,nsh,txt}"
print "cp -R " $2 "/* ./"
print "git add ."
print "git commit -S -m \"" $3 "\""
print "unset GIT_COMMITTER_DATE"
print "unset GIT_AUTHOR_DATE"
}
