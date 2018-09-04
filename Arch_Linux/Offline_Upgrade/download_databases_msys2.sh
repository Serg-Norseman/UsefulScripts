#! /bin/sh

date=$(date --utc --rfc-3339=seconds | \
    sed -e "s/\(\+\)00:00/\105:00/; s/ /_/g; s/\:/_/g")
download_prefix=./databases/${date}

mkdir --parents ${download_prefix}

arch=x86_64
mirror=http://repo.msys2.org/msys
wget --directory-prefix=${download_prefix} \
    ${mirror}/${arch}/msys.db{,.sig}
gpg --verify ${download_prefix}/msys.db.sig 2>&1 | head --lines=4 | \
    sed --expression \
    's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
    xargs -0 echo -e
mirror=http://repo.msys2.org/mingw
wget --directory-prefix=${download_prefix} \
    ${mirror}/${arch}/mingw64.db{,.sig}
gpg --verify ${download_prefix}/mingw64.db.sig 2>&1 | head --lines=4 | \
    sed --expression \
    's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
    xargs -0 echo -e
arch=i686
wget --directory-prefix=${download_prefix} \
    ${mirror}/${arch}/mingw32.db{,.sig}
gpg --verify ${download_prefix}/mingw32.db.sig 2>&1 | head --lines=4 | \
    sed --expression \
    's/\(.*\)\(Good signature\)\(.*\)/\1\\x1b[1;31m\2\\x1b[0m\3/' | \
    xargs -0 echo -e
