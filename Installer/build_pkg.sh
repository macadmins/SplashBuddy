#!/bin/bash

VERSION="0.14"

echo -e "\033[1mHave you updated VERSION?\033[0m"

# A weird way to get the absolute path
# http://stackoverflow.com/questions/3349105/how-to-set-current-working-directory-to-the-directory-of-the-script

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

echo $dir
pkgbuild --root ${dir}/payload \
	 --scripts ${dir}/scripts \
	 --identifier io.fti.SplashBuddy.Installer \
	 --version ${VERSION} \
	${dir}/SplashBuddyInstaller-${VERSION}.pkg
