#!/usr/bin/env bash

osascript -e 'tell app "System Events" to display dialog "You clicked on Continue. Edit this script at /Library/CasperSplash/postInstall.sh" buttons "OK" default button 1 with title "Well done!" with icon stop'
touch ~/Library/.CasperSplashDone
