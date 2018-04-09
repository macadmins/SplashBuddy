#!/bin/bash

# Based on the work from @jamfmatt
# Launch with sudo ./sb_ghost_pkg.sh <status> <packageName>
# Or add it to your Jamf Pro instance so you can call it from policies!

if [ `id -u` -ne 0 ]; then
	echo "ERROR: Please run as root"
	exit 1
fi

if [ "$4" != "" ]; then 
	status=$4
else
	status=$1
fi

shopt -s nocasematch

case "${status}" in
	"installing" | "orange")
		forceStatus="Installing"
		;;
	"installed" | "green")
		forceStatus="Successfully installed"
		;;
	"failed" | "red")
		forceStatus="Installation failed. The installer reported: installer: Package name is"
		;;
	*)
		echo "Usage: sudo ${0} <status> <packageName>"
		echo "status can be: installing, installed or failed or orange, green, red"
		echo "packageName is <packageName>-<version>.pkg"
		echo "example: sudo ${0} installing EnterpriseConnect"
		exit 1
		;;
esac



if [ "$5" != "" ]; then 
	forcePackage=$5
else
	if [ "$2" != "" ]; then
	    forcePackage="$2"
	else 
		forcePackage="GhostPackage" #Standard Splashbuddy compatible scheme "AppName-1.2.3.pkg"
	fi
fi

forceDate=`date`
forceUser="ghostNshell"


echo "$forceDate $forceUser: $forceStatus $forcePackage-1.2.3.pkg..." >> /var/log/jamf.log
echo "$forcePackage -> $forceStatus"
exit 0
