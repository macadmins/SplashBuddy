# CasperSplash
Onboarding splash screen for Casper Suite DEP

Caution: This repo is not ready.
Watch for an announcement at http://maclovin.org

# Setting Preferences

## CasperSplash.plist

domain is io.fti.CasperSplash

I recommend installing a plist in /Library/Preferences/io.fti.CasperSplash.plist
Unfortunately, the timing a profile will be pushed is not guaranteed.

The following example will:
- Set the base path to `/Library/CasperSplash`
- Will run the script `/Library/CasperSplash/postInstall.sh` when user click on "Continue"
- Will display the html page `/Library/CasperSplash/presentation.html`
- Will add an item in the right corner, called "Acrobat Reader" with subtitle "PDF Reader", with the icon `/Library/CasperSplash/acrobatreader.png`. It will expect a package name in the form "Adobe Reader XI Installer-11.0.10.pkg"


```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>assetPath</key>
        <string>/Library/CasperSplash</string>
        <key>postInstallAssetPath</key>
        <string>postInstall.sh</string>
        <key>htmlPath</key>
        <string>presentation.html</string>
        <key>applicationsArray</key>
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
    </dict>
</plist>
```

