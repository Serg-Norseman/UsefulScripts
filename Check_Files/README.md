# Check files for "inconsistences"

## crlf

Script `crlf.sh` checks line-endings in files using two techniques:
`git-ls-files(1)` and `dos2unix(1)`. Therefore, the current directory
must be a git-directory, and user need to have `dos2unix` package
installed.

### git-ls-files

This part of the script checks untracked files, the index and the
working tree, and warns user when it has found file(s) having CRLF line
endings. If a found file is Microsoft Visual Studio solution file or C++
project, this script shows an additional hint (MSVS solution and project
files **must** have CRLF line-endings).

### dos2unix

This part of the script checks all files in the current directory and
all subdirectories (except \`\`.git'' and \`\`build'' subdirectories of
the current one). This part also checks BOM presence in files, and shows
a hint on binary files.
