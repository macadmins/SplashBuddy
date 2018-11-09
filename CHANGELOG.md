# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.3.1]

### Fixed

* Fixed build issues

## [1.3.0]

### Added

* Reworked localization [[#81](https://github.com/Shufflepuck/SplashBuddy/issues/81)]
* Added Spanish localization [[#85](https://github.com/Shufflepuck/SplashBuddy/issues/85)]
* Added User Input
* Added Japanese localization [[#96](https://github.com/Shufflepuck/SplashBuddy/issues/96)]
* Added support for `macOS 10.14`

## [1.2.2]

### Fixed

* 1.2.1 doesn't even show, let alone install policies [[#77](https://github.com/Shufflepuck/SplashBuddy/issues/77)]

## [1.2.1]

### Fixed

* Typo in the release note that could be confusing

## [1.2]

### Added

* `/private/tmp/SplashBuddy/` with more tag files : `CriticalDone` (All critical softwares are installed), `ErrorWhileInstalling` (Errors while installing), `AllInstalled` (All software is installed (failed or success)), `AllSuccessfullyInstalled` (All software is sucessfully installed).
* With `labMode` set to `true`, SplashBuddy will automatically display `complete.html` from `presentation.bundle` when all software is done installing (successfully or not) -- thank you @howardgmac

### Changed

* Better and faster parsing of the `/var/log/jamf.log`
* Better `presentation.bundle`, courtesy of @smithjw
* New exception in entitlements: `com.apple.security.temporary-exception.files.absolute-path.read-write` for `/private/tmp/SplashBuddy`

## [1.1]

### Added

* Key `hideSidebar` to hide the sidebar and get a full html view
* New behaviors for `Continue` button: Restart, Shutdown, Logout, Launch Application or Quit. (uses `continueAction` preferences key)
* Hide Background with setting `hideBackground` to `true`. Eg. `SplashBuddy.app/Contents/MacOS/SplashBuddy -hideBackground true`
* Italian localization

### Changed

* Brand new Layout!
* Added Temporary exception to sandbox to allow sending Apple Events to Login Window (to restart etc.)
* Continue button can now be hidden
* Moved Userinput on a separate branch. Feature is not ready for 1.1

### Fixed

* `.SplashBuddyDone` will be set when all critical items are done (`canContinue` = `false`) (@LovelessInSeattle)
* A failed item will no longer activate continue button (@LovelessInSeattle)

## [1.0]

### Added

* Application is now fully sandboxed, and running as user!
* Localization for French, German and Dutch
* An error pops up if it cannot find `/var/log/jamf.log`
* Easy way to build a package with Installer/build_pkg.sh
* Now using the new Logger facility from 10.12+ @cybertunnel
* Quit SplashBuddy and set .SplashBuddyDone by using CMD+ALT+CTRL+Q (@matgriffin)
* Tools/sb_ghost_pkg.sh originally from @jamfmatt -- to easily test & set status from Jamf Pro

### Changed

* Quit application by using CMD+ALT+Q
* All assets must now reside in /Library/Application Support/SplashBuddy/
* Moved from XIB to Storyboards
* Application has been renamed from CasperSplash to SplashBuddy
* Better HTML demo page (if no HTML asset is found)
* Moved much of the logic out of View Controllers
* Lots of code refactoring
* Fixed LaunchAgent script - @smashism #26
* Now using WKWebView and localization bundle (presentation.bundle)
* HTML view doesn't allow content outside of asset folder anymore for increased security (but remote content is ok as long as it is HTTPS)
* Disabled application switcher and gesture to ensure this Application stays on top - @matthewsphillips #34
* Hides all other applications on launch
* New icon!

### Removed

* Removed the postInstall script. Pressing Continue will create the file `~/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone`
* Removed `assetPath` and `htmlPath` (it is now hardcoded to `/Library/Application Support/SplashBuddy/presentation.bundle` )
* 10.11 is no longer supported (WKWebView NSCoding support was broken in previous versions) -- use RC4 if you *absolutely* need 10.11 support

### Fixed

* Better automated testing with Travis
* Compatible with Swift 4.0 and macOS 10.13
* WKWebView now accepts keyboard input (can use forms)
* Installer now better handle upgrades (thanks @elios and @scriptingosx)
* SplashBuddy now handles multiple screens (thanks @jamfmatt)
* Base.lproj renamed to en.lproj for 10.13 compatibility
* Switched from legacy "launchctl load" to "enable, bootstrap, kickstart"
* Error message will now clear if software turns from error to success (fixes #42 -- thanks @jamfmatt)
* Disable relaunch on login. This should be controlled by a LaunchAgent. (thanks @grahamrpugh)
* Background window now stays in front of Dock (thanks @jwojda)

## Contributors

## Code

* François 'ftiff' Levaux-Tiffreau (@ftiff)
* @cybertunnel
* Joel Rennich (@mactroll)

## Localization

* French (fr): François Levaux-Tiffreau (@ftiff)
* Dutch (nl): @riddl0rd, @thomasb
* German (de): Mic Milic Frederickx (@kermic)
