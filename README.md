# CasperSplash
Onboarding splash screen for Casper Suite DEP

Caution: This repo is not ready.
Watch for an announcement at http://maclovin.org

# Setting Preferences

## CasperSplash.plist

domain is io.fti.CasperSplash

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
                <key>displayName</key>
                <string>Enterprise Connect</string>
                <key>description</key>
                <string>SSO</string>
                <key>packageName</key>
                <string>EnterpriseConnect</string>
                <key>iconRelativePath</key>
                <string>ec_32x32.png</string>
                <key>canContinue</key>
                <true/>
            </dict>
        </array>
    </dict>
</plist>
```
