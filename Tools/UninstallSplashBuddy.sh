#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Uninstalls SplashBuddy

rm -rf "/Library/Application Support/SplashBuddy"
rm "/Library/LaunchAgents/io.fti.SplashBuddy.launch.plist"
rm "/Library/Preferences/io.fti.SplashBuddy.plist"

loggedInUser=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')

rm "/Users/${loggedInUser}/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone"

pkgutil --forget "io.fti.SplashBuddy.Installer"
