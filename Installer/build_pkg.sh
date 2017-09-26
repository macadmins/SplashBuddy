#!/bin/bash

VERSION=`date +%Y%m%d%H%M`

# Get the absolute path of the directory containing this script
# https://unix.stackexchange.com/questions/9541/find-absolute-path-from-a-script

dir=$(unset CDPATH && cd "$(dirname "$0")" && echo $PWD)

if [ -d "${dir}/payload/Library/Application Support/SplashBuddy/presentation.bundle/Base.lproj" ]; then
    echo "Renaming Base.lproj to en.lproj…"
    mv "${dir}/payload/Library/Application Support/SplashBuddy/presentation.bundle/Base.lproj" "${dir}/payload/Library/Application Support/SplashBuddy/presentation.bundle/en.lproj"
fi

# Every use should have read rights and scripts should be executable

/bin/chmod -R o+r "${dir}/payload/"
/bin/chmod +x "${dir}/scripts"

/usr/bin/find "${dir}" -name .DS_Store -delete

# Build package

/usr/bin/pkgbuild --root "${dir}/payload" \
	 --scripts "${dir}/scripts" \
	 --identifier io.fti.SplashBuddy.Installer \
	 --version ${VERSION} \
	 --component-plist "${dir}/SplashBuddy-component.plist" \
	 "${dir}/SplashBuddyInstaller-${VERSION}.pkg"
