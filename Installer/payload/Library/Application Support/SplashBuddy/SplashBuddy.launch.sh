#!/bin/bash

# This file should be called by a LaunchAgent
# Its goal is to ensure SplashBuddy only executes when user is on the desktop.
# If you would like to launch SplashBuddy over the Login Window, uncomment the following line

# launchAtLoginWindow="yes"

# I suggest you create a Policy to Remove and uninstall the LaunchAgent
# We cannot do it here as LaunchAgents are executed by the user.


loggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
app="/Library/Application Support/SplashBuddy/SplashBuddy.app"
doneFile="/Users/${loggedInUser}/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone"

# Default behaviour is to check if:
# - SplashBuddy is not already running
# - SplashBuddy is signed (is fully installed)
# - User is in control (not _mbsetupuser)
# - User is on desktop (Finder process exists)
# - Done file doesn't exist

function appInstalled {
    /usr/bin/codesign --verify "${app}" && return 0 || return 1
}

function appNotRunning {
    /usr/bin/pgrep SplashBuddy && return 1 || return 0
}

function finderRunning {
    /usr/bin/pgrep Finder && return 0 || return 1
}

if [[ $launchAtLoginWindow == "yes" ]]; then
    echo "Launch at LW = Yes"
    if appNotRunning \
    	&& appInstalled \
    	&& [ ! -f "${doneFile}" ]; then

        /usr/bin/open -a "$app"
    fi
else
    echo "Launch at LW = No"
    if appNotRunning \
    	&& appInstalled \
    	&& [ "$loggedInUser" != "_mbsetupuser" ] \
    	&& finderRunning \
    	&& [ ! -f "${doneFile}" ]; then

        /usr/bin/open -a "$app"
    fi
fi

exit 0
