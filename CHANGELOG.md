# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]

### Added

* Application is now fully sandboxed, and running as user!
* Localization for French, German and Dutch
* An error pops up if it cannot find `/var/log/jamf.log`
* Easy way to build a package with Installer/build_pkg.sgh
* Now using the new Logger facility from 10.12+ @cybertunnel

### Changed

* Quit application by using CMD+ALT+Q
* Moved from XIB to Storyboards
* Application has been renamed from CasperSplash to SplashBuddy
* Better HTML demo page (if no HTML asset is found)
* Moved much of the logic out of View Controllers
* Lots of code refactoring

### Removed

* Removed the postInstall script. Pressing Continue will create the file `~/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone`

### Fixed

* Better automated testing with Travis
* Compatible with Swift 3.1 and macOS 10.12.4
* Javascript and Java were enabled by default.

# Contributors

## Code

- François 'ftiff' Levaux-Tiffreau (@ftiff)
- @cybertunnel
- Joel Rennich (@mactroll)


## Localization

- French (fr): François Levaux-Tiffreau (@ftiff)
- Dutch (nl): @riddl0rd, @thomasb
- German (de): Mic Milic Frederickx (@kermic)


