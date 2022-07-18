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
./build_ffi_ios.sh
flutter build ipa
````

### Docker

If you so prefer it is also possible to build Envoy for Android within a [Docker](https://docs.docker.com/engine/install/) container. Using [just](https://github.com/casey/just) run:
````
just docker-build-android
````
To fetch the compiled `.apk` from the container:
````
just docker-get-apk
````

There are many other useful recipes in the `justfile`. If you are running an X11 based Linux distro you can even run Envoy on your desktop:
````
just docker-run
````

## Contributing

Contributors are more than welcome. Feel free to submit a PR or an issue on this very repo.
