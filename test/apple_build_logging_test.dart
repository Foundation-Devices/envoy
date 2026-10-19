// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final helperPaths = Directory('packages')
      .listSync()
      .whereType<Directory>()
      .map((package) => '${package.path}/rust_builder/cargokit/build_pod.sh')
      .where((path) => File(path).existsSync())
      .toList()
    ..sort();

  test('discovers the local Apple build helpers', () {
    expect(helperPaths, isNotEmpty);
  });

  for (final path in [...helperPaths, 'tor']) {
    test('$path Apple build helper does not disclose inherited secrets',
        () async {
      final Uri helper;
      if (path == 'tor') {
        // Test the actual pinned dependency, not a second copy of its script.
        // Isolate.resolvePackageUri is unavailable in Flutter's test runner.
        final configFile = File('.dart_tool/package_config.json').absolute;
        final config = jsonDecode(await configFile.readAsString());
        final tor = (config['packages'] as List).singleWhere(
          (entry) => entry['name'] == 'tor',
        );
        final root = tor['rootUri'] as String;
        helper = configFile.uri
            .resolve(root.endsWith('/') ? root : '$root/')
            .resolve('cargokit/build_pod.sh');
      } else {
        helper = File(path).uri;
      }

      final sandbox = await Directory.systemTemp.createTemp('envoy-apple-log-');
      addTearDown(() => sandbox.delete(recursive: true));
      final script =
          await File.fromUri(helper).copy('${sandbox.path}/build_pod.sh');
      // Exercise the complete shell helper, but never invoke Cargo, Flutter,
      // signing tools, or the real build environment from this regression test.
      await File('${sandbox.path}/run_build_tool.sh').writeAsString('''
#!/bin/sh
printf '%s\\n' 'build-tool-reached'
''');

      const canary = 'ENV3073_SYNTHETIC_SECRET_DO_NOT_LOG';
      final result = await Process.run(
        'bash',
        [script.path, '../rust', 'rust_lib_canary'],
        includeParentEnvironment: false,
        environment: {
          // Preserve tool discovery in Nix shells, not the host's credentials.
          'PATH': Platform.environment['PATH'] ?? '',
          'HOME': sandbox.path,
          'ENV3073_TEST_SECRET': canary,
          'PLATFORM_NAME': 'iphoneos',
          'ARCHS': 'arm64',
          'CONFIGURATION': 'Release',
          'PODS_TARGET_SRCROOT': sandbox.path,
          'PODS_ROOT': '${sandbox.path}/Pods',
          'PODS_CONFIGURATION_BUILD_DIR': sandbox.path,
          'PRODUCT_NAME': 'canary',
          'TARGET_TEMP_DIR': sandbox.path,
          'SRCROOT': sandbox.path,
          'OBJROOT': sandbox.path,
          'BUILT_PRODUCTS_DIR': sandbox.path,
          'EXECUTABLE_PATH': 'canary.a',
        },
      );

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(result.stdout, contains('build-tool-reached'));
      expect('${result.stdout}${result.stderr}', isNot(contains(canary)));
    }, skip: Platform.isWindows);
  }
}
