#!/bin/bash
plist="/Library/LaunchDaemons/io.fti.CasperSplash.launch.plist"

loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
app="/Library/CasperSplash/CasperSplash.app"
doneFile="/Users/${loggedInUser}/Library/.CasperSplashDone"

# Check if:
# - CasperSplash binary exists (is fully installed)
# - User is in control (not _mbusersetup)
# - User is on desktop (Finder process exists)

if [ -f "$app"/Contents/MacOS/CasperSplash ] \
	&& [ "$loggedInUser" != "_mbusersetup" ] \
	&& [ $(pgrep Finder | wc -l) -gt 0 ] \
	&& [ ! -f "${doneFile}" ]; then

    open -a "$app"
	
	# Remove and uninstall the LaunchDaemon
	# 
	# I suggest you create a Policy that will do the following
	# it will ensure that CasperSplash restarts if interrupted
	# by a restart.
	#
	# If so, comment the following two lines:
	#
    launchctl remove io.fti.CasperSplash.launch
    rm "$plist"

fi

exit 0
