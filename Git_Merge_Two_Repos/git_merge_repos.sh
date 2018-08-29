#! /bin/awk -f
# Copyright (C) 2017 by Sergey Zhdanovskih.

# merge project-a into project-b:

cd ARGV[1] # path/to/project-b
git remote add ARGV[2] ARGV[3] # project-a path/to/project-a
git fetch ARGV[2] # project-a
git merge --allow-unrelated-histories ARGV[4] # project-a/master or whichever branch you want to merge
git remote remove ARGV[2] # project-a
