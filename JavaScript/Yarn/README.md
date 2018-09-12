# Download dependencies specified in \`\`yarn.lock''

## Description

'download\_dependencies.sh' script extracts links to all package
tarballs specified in a \`\`yarn.lock'' [file][1] and downloads the
packages to the specified directory.

## Usage

```sh
./download_dependencies.sh -f <yarn.lock file> -p <download prefix>
```

or, for script synopsis:

```sh
./download_dependencies.sh -h
```

Using the `-f` option user specifies path to the source 'yarn.lock'
file. This script extracts links to package tarballs from that file, and
downloads the tarballs to directory defined by the `-p` option. If the
directory specified by the `-p` option does not exist, this script
creates it.

## Requirements

This script currently uses GNU \`\`wget'' tools.

This script is compatible with `sh(1)` shell.

[1]: https://yarnpkg.com/en/docs/yarn-lock
