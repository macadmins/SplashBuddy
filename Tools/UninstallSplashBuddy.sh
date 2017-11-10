#!/bin/bash

export backupPATH=$PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Uninstalls SplashBuddy

rm -rf "/Library/Application Support/SplashBuddy"
rm "/Library/LaunchAgents/io.fti.SplashBuddy.launch.plist"
rm "/Library/Preferences/io.fti.SplashBuddy.plist"

loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

rm "/Users/${loggedInUser}/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone"

pkgutil --forget "io.fti.SplashBuddy.Installer"
export PATH=$backupPATH
