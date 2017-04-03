#!/bin/bash

VERSION=`date +%Y%m%d%H%M`

# A weird way to get the absolute path
# http://stackoverflow.com/questions/3349105/how-to-set-current-working-directory-to-the-directory-of-the-script

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

pkgbuild --root "${dir}/payload" \
	 --scripts "${dir}/scripts" \
	 --identifier io.fti.SplashBuddy.Installer \
	 --version ${VERSION} \
	"${dir}/SplashBuddyInstaller-${VERSION}.pkg"
