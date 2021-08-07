# Automatically Reset Google Advertising ID Every 5-10 Minutes

This Magisk module automatically resets Google Advertising ID to a new random value every 5-10 minutes. We don't trust Google Mobile Services, so we regenerate GAID ourselves - it's a UUID v4.

Note that you don't need this module if you don't have Google Mobile Services (for example, if you have an AOSP-based ROM like LineageOS and don't have Open GApps installed).

Tested on Android 9/10/11, works on any Android version up from 4.4.

## Installation

Download auto-reset-google-advertising-id.zip from Releases and install it via "Install from storage" in Magisk Manager.

## Credits

- buch0 at <a href="https://stackoverflow.com/questions/40409471/how-to-reset-google-advertising-id-in-android-programmatically">How to reset Google Advertising ID in Android Programmatically?"
