docker_image := 'envoy'

docker-build:
    docker build -t {{docker_image}} .

docker-build-android: docker-build
    docker run -t {{docker_image}} /bin/bash -c "flutter build apk --release -P nosign && flutter build appbundle --release -P nosign"

docker-build-android-sign: docker-build
    docker run -e ALIAS_PASSWORD=$ALIAS_PASSWORD -e KEY_PASSWORD=$KEY_PASSWORD -t {{docker_image}} /bin/bash -c "flutter build apk --release && flutter build appbundle --release"

docker-get-apk:
    docker cp $(docker create {{docker_image}}):/root/build/app/outputs/flutter-apk/app-release.apk .

docker-get-aab:
    docker cp $(docker create {{docker_image}}):/root/build/app/outputs/bundle/release/app-release.aab .

docker-test: docker-build
    docker run -t {{docker_image}} flutter test

docker-test-integration: docker-build
    docker run -t {{docker_image}} bash integration_test_headless.sh

docker-run: docker-build
    xhost +local:root
    docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \
     -v $HOME/.Xauthority:/home/root/.Xauthority -t {{docker_image}} flutter run -d linux
    xhost -local:root

docker-console:
    docker run -it {{docker_image}} bash

generate:
    flutter pub run build_runner build --delete-conflicting-outputs

bump:
    bash bump_version.sh

format:
    bash fix_formatting.sh

build-ffi:
    bash build_ffi.sh