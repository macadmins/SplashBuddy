# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]

### Added

* Application is now fully sandboxed, and running as user!
* Localization for French, German and Dutch
* An error pops up if it cannot find `/var/log/jamf.log`
* Easy way to build a package with Installer/build_pkg.sh
* Now using the new Logger facility from 10.12+ @cybertunnel

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

### Removed

* Removed the postInstall script. Pressing Continue will create the file `~/Library/Containers/io.fti.SplashBuddy/Data/Library/.SplashBuddyDone`
* Removed `assetPath` and `htmlPath` (it is now hardcoded to `/Library/Application Support/SplashBuddy/presentation.bundle` )

### Fixed

* Better automated testing with Travis
* Compatible with Swift 4.0 and macOS 10.13
* WKWebView now accepts keyboard input (can use forms)

### Known Issues

* Travis CI is not yet compatible with Swift 4.0

# Contributors

## Code

- François 'ftiff' Levaux-Tiffreau (@ftiff)
- @cybertunnel
- Joel Rennich (@mactroll)


## Localization

- French (fr): François Levaux-Tiffreau (@ftiff)
- Dutch (nl): @riddl0rd, @thomasb
- German (de): Mic Milic Frederickx (@kermic)


