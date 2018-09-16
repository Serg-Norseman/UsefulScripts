# Download \`\`pacman'' databases and packages

## Description

This directory provides shell scripts that allow to upgrade
\`\`pacman''-based systems like [Arch Linux][2] distribution and
[MSYS2][3] environment, while their hosts are offline (lack the Internet
connection).

## Usage

First, you must download package databases using a script targetting
your platform, running it on a host connected to the Internet:

- \`\`download\_databases\_arch\_linux.sh'' if you are to upgrade Arch
Linux host;
- \`\`download\_databases\_msys2.sh'' if you are to upgrade MSYS2
environment.

```sh
./download_databases_arch_linux.sh -p <download prefix> [-t]
```

or

```sh
./download_databases_msys2.sh -p <download prefix> [-t]
```

or, for scripts synopsis:

```sh
./download_databases_arch_linux.sh -h
./download_databases_msys2.sh -h
```

Those scripts downloads package databases (\*.db files) to directory
defined by the `-p` option. If the directory specified by the `-p`
option does not exist, the scipts create it. If you specified `-t`
option, the scripts create subdirectory in directory defined by the
`-p`. That "tagged" subdirectory has name consisting of the current
date/time information.

MSYS2 targeting script also downloads GPG signature files. If executing
host has [GNU GPG][4] installed, \`\`download\_databases\_msys2.sh''
script verifies the downloaded databases using *sig* files.

After you have downloaded package databases, you must transfer all the
\`\`\*.db'' files (for MSYS2 also all the \`\`\*.db.sig'' files) to
\`\`/var/lib/pacman/sync/'' directory on your target (offline) host.
This way you emulate executing of `pacman -Sy` on your host.

Next, run "system upgrade" on your offline host using the following
command:

```sh
pacman -Sup --noconfirm
```

This gives you direct links to outdated packages basing on your
\`\`/etc/pacman.d/mirrorlist'' file and new package databases. To save
those link list into a file you may use something like this:

```sh
pacman -Sup | sed -n -e "/https:\/\//p" > package_list
```

Now, you must transfer package list file back to host connected to the
Internet, and run \`\`download\_packages.sh'' scirpt:

```sh
./download_packages.sh -f <package list file> -p <download prefix> [-t]
```

or, for script synopsis:

```sh
./download_databases.sh -h
```

Using the `-f` option you specify path to file containg links to
required packages (the one you created on your offline host). This
scirpt downloads packages to directory defined by the `-p` option. If
the directory specified by the `-p` option does not exist, this script
creates it. If you specified `-t` option, the scripts create
subdirectory in directory defined by the `-p`. That "tagged"
subdirectory has name consisting of the current date/time information.

Transfer all \`\`\*.pkg.tar.xz'' files you have downloaded to
\`\`/var/cache/pacman/pkg/'' directory on your target (offline) host,
and run system upgrade:

```sh
pacman -Su
```

## Requirements

On [FreeBSD][1] this script uses fetch(1). On other systems it uses GNU
wget(1). MSYS2-targeting script may use [GNU GPG][4] toolset.

This script is compatible with sh(1) shell.

[1]: https://freebsd.org/
[2]: https://www.archlinux.org/
[3]: https://www.msys2.org/
[4]: https://gnupg.org/
