#!/bin/bash

loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
app="/Library/Application Support/SplashBuddy/SplashBuddy.app"
doneFile="/Users/${loggedInUser}/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone"

# Check if:
# - SplashBuddy binary exists (is fully installed)
# - User is in control (not _mbusersetup)
# - User is on desktop (Finder process exists)
# - Application is not already running
function IsRunning()
{
pgrep "SplashBuddy" && return 1 || return 0
}

if IsRunning && [ -f "$app"/Contents/MacOS/SplashBuddy ] \
	&& [ "$loggedInUser" != "_mbusersetup" ] \
	&& [ $(pgrep Finder | wc -l) -gt 0 ] \
	&& [ ! -f "${doneFile}" ]; then

    open -a "$app"
	
	# Remove and uninstall the LaunchDaemon
	# 
	# I suggest you create a Policy that will do the following
	# it will ensure that SplashBuddy restarts if interrupted
	# by a restart.

fi

exit 0
