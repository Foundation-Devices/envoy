<!--
SPDX-FileCopyrightText: 2022 Foundation Devices Inc.

SPDX-License-Identifier: GPL-3.0-or-later
-->

# Envoy
Envoy is a companion app for the Passport hardware wallet. To learn more visit [foundationdevices.com/envoy](https://foundationdevices.com/envoy/)

## Building

To build Envoy you will need:
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Rust](https://www.rust-lang.org/tools/install)

After you've set up the two dependencies building is easy. For an Android build run:
````
./build_ffi_android.sh
flutter build apk
````

For iOS:
````
brew install automake libtool
./build_ffi_ios.sh
flutter build ipa
````

### Docker

If you so prefer it is also possible to build Envoy for Android within a [Docker](https://docs.docker.com/engine/install/) container. Using [just](https://github.com/casey/just) run:
````
just docker-build-android
````
the `.apk` and `.aab` files will be in the `releases` folder.

There are many other useful recipes in the `justfile`. If you are running an X11 based Linux distro you can even run Envoy on your desktop:
````
just docker-run
````

## Contributing

Contributors are more than welcome. Feel free to submit a PR or an issue on this very repo.
