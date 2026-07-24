
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
    GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx8g ./scripts/run_maestro.sh --build

maestroqa-android:
    GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx8g ./scripts/run_maestro.sh --build --android-only

maestroqa-prime:
    GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx8g ./scripts/run_maestro.sh --build --prime-only

maestroqaios:
    ./scripts/run_ios_maestro.sh --build
