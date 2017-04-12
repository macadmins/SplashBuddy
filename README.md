# SplashBuddy
Onboarding splash screen for DEP

Caution: This repo is not ready.
Watch for an announcement at http://maclovin.org

#Quick Start

- Install SplashBuddy.app in /Library/Application Support/SplashBuddy
- Generate a SplashBuddy Demo Assets package and install it
```
DemoAssets/build_pkg.sh
sudo install -target / -pkg DemoAssets/SplashBuddyDemoAssets-0.7.pkg
```

# Setting Preferences

## SplashBuddy.plist

Preference domain is `io.fti.SplashBuddy`

I recommend installing a plist in `/Library/Preferences/io.fti.SplashBuddy.plist`

Unfortunately, the timing for a profile being pushed is not guaranteed.

The following example will:
- Set the base path to `/Library/Application Support/SplashBuddy`
- Will display the html page `/Library/Application Support/SplashBuddy/presentation.html`
- Will add an item in the right corner, called "Acrobat Reader" with subtitle "PDF Reader", with the icon `/Library/Application Support/SplashBuddy/acrobatreader.png`. It will expect a package name in the form "Adobe Reader XI Installer-11.0.10.pkg"


```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <array>
            <dict>
                <key>canContinue</key>
                <true/>
                <key>description</key>
                <string>PDF Reader</string>
                <key>displayName</key>
                <string>Acrobat Reader</string>
                <key>iconRelativePath</key>
                <string>acrobatreader.png</string>
                <key>packageName</key>
                <string>Adobe Reader XI Installer</string>
            </dict>
        </array>
        <key>assetPath</key>
        <string>/Library/Application Support/SplashBuddy</string>
        <key>htmlPath</key>
        <string>presentation.html</string>
        <key>applicationsArray</key>
    </dict>
</plist>
```


