docker_image := 'envoy'

docker-build:
    docker build --load --build-arg GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN -t {{docker_image}} .

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
    bash scripts/bump_version.sh

fmt:
    cargo-fmt && \
    ./scripts/format.sh

lint: fmt
    reuse lint && \
    flutter analyze && \
    cargo clippy -- -Dwarnings -A clippy::missing_safety_doc

copy:
    localazy download
    flutter pub run intl_utils:generate

maestroqa:
    ./scripts/run_maestro.sh --build

maestroqaios:
    ./scripts/run_ios_maestro.sh --build

