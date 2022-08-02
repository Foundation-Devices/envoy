docker_image := 'envoy'

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

generate:
    flutter pub run build_runner build --delete-conflicting-outputs

bump:
    bash bump_version.sh

format:
    bash fix_formatting.sh

build-ffi:
    bash build_ffi.sh