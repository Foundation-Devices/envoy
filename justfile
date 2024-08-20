docker_image := 'envoy'
docker_image_linux := 'envoy_linux'
docker_image_beefbench := 'beef'

docker_x := '-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -v $XAUTHORITY:/home/root/.Xauthority'
docker_v4l2 := '--privileged -v /dev/video5:/dev/video5 -v /dev/video6:/dev/video6 -v /dev/video7:/dev/video7'

docker-build:
    docker build -t {{docker_image}} .

docker-build-android: docker-build
    mkdir -p release && \
        docker run --mount type=bind,source="$(pwd)"/release,target=/release \
        -t {{docker_image}} /bin/bash \
        -c "flutter build apk --release -P nosign && flutter build appbundle --release -P nosign \
        && cp /root/build/app/outputs/flutter-apk/app-release.apk /release \
        && cp /root/build/app/outputs/bundle/release/app-release.aab /release"

docker-build-android-sign: docker-build
    mkdir -p release && \
        docker run --mount type=bind,source="$(pwd)"/release,target=/release \
        -e ALIAS_PASSWORD=$ALIAS_PASSWORD -e KEY_PASSWORD=$KEY_PASSWORD \
        -t {{docker_image}} /bin/bash \
        -c "flutter build apk --release && flutter build appbundle --release \
        && cp /root/build/app/outputs/flutter-apk/app-release.apk /release \
        && cp /root/build/app/outputs/bundle/release/app-release.aab /release"

docker-build-linux: docker-build
    docker build -t {{docker_image_linux}} . -f linux.Dockerfile

docker-test: docker-build-linux
    docker run -t {{docker_image_linux}} flutter test

docker-test-integration: docker-build-linux
    docker run -t {{docker_image_linux}} bash integration_test_headless.sh

docker-run: docker-build-linux
    xhost +local:root
    docker run {{docker_x}} -t {{docker_image_linux}} flutter run -d linux
    xhost -local:root

docker-console: docker-build-linux
    docker run -it {{docker_image_linux}} bash

# run the APK through SHA256
verify-sha sha:
  #!/usr/bin/env bash
  sha=$(shasum -a 256 release/app-release.apk | awk '{print $1}')
  echo -e "Expected SHA:\t{{sha}}"
  echo -e "Actual SHA:\t${sha}"
  if [ "$sha" = "{{sha}}" ]; then
    echo "Hashes match!"
  else
    echo "ERROR: Hashes DO NOT match!"
  fi

# https://github.com/dart-lang/build/issues/2835#issuecomment-1047849076
generate:
    rm pubspec.lock && \
    flutter packages pub get && \
    dart run build_runner build --delete-conflicting-outputs && \
    git restore pubspec.lock

bump:
    bash bump_version.sh

format:
    cargo fmt && \
    dart format .

lint: format
    reuse lint && \
    flutter analyze && \
    cargo clippy -- -Dwarnings -A clippy::missing_safety_doc

build-ffi:
    bash build_ffi.sh

copy:
    localazy download

passport-deps:
    sudo apt install -y autotools-dev automake libusb-1.0-0-dev libtool python3-virtualenv libsdl2-dev pkg-config curl vlc v4l2loopback-dkms
    sudo modprobe v4l2loopback video_nr=5,6,7

passport: passport-deps
    git clone git@github.com:Foundation-Devices/passport2.git || true
    rustup target add x86_64-unknown-none
    make -C passport2/mpy-cross
    cd passport2/simulator &&  make color && virtualenv -p python3 ENV && pip3 install -r requirements.txt


beef: passport
    flutter test integration_test/envoy_test.dart -d linux

docker-beef: docker-build-linux
    docker build -t {{docker_image_beefbench}} . -f beef.Dockerfile
    mkdir -p release
    docker run --mount type=bind,source="$(pwd)"/release,target=/root/release {{docker_v4l2}} {{docker_image_beefbench}}

qa:
    ./run_integration_tests.sh

