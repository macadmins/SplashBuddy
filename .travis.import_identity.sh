#!/bin/sh

# from https://github.com/travis-ci/travis-ci/issues/3072

KEY_CHAIN=ios-build.keychain
security create-keychain -p travis $KEY_CHAIN

# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN

# Unlock the keychain
security unlock-keychain -p travis $KEY_CHAIN

# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u $KEY_CHAIN

# Add certificates to keychain and allow codesign to access them
security import Assets/Mac-Developer-20180129.p12 -k $KEY_CHAIN -P $KEY_PASSWORD -T /usr/bin/codesign

security set-key-partition-list -S apple-tool:,apple: -s -k travis $KEY_CHAIN

echo "Add keychain to keychain-list"
security list-keychains -s ios-build.keychain
