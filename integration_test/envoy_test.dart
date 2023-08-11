// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'package:envoy/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BEEFbench', () {
    testWidgets('Onboarding flow', (tester) async {
      Directory fdDir = Directory('/proc/$pid/fd');

      // ignore: unused_local_variable
      final oledPipe = Pipe.createSync();
      // ignore: unused_local_variable
      final ledPipe = Pipe.createSync();
      final numpadPipe = Pipe.createSync();
      // ignore: unused_local_variable
      final camCmdPipe = Pipe.createSync();
      // ignore: unused_local_variable
      final camImgPipe = Pipe.createSync();

      List<FileSystemEntity> fds = fdDir.listSync().toList();
      List<File> pipes = fds.whereType<File>().toList();

      File rOled = pipes[pipes.length - 10];
      File wOled = pipes[pipes.length - 9];

      File rLedPipe = pipes[pipes.length - 8];
      File wLedPipe = pipes[pipes.length - 7];

      File rNumpadPipe = pipes[pipes.length - 6];
      File wNumpadPipe = pipes[pipes.length - 5];

      File rCamCmdPipe = pipes[pipes.length - 4];
      File wCamCmdPipe = pipes[pipes.length - 3];

      File rCamImgPipe = pipes[pipes.length - 2];
      File wCamImgPipe = pipes[pipes.length - 1];

      await resetEnvoyData();
      await Passport.reset();
      await Passport.cleanUp();

      ScreenshotController envoyScreenshotController = ScreenshotController();

      final passport = Passport(
          envoyScreenshotController,
          tester,
          numpadPipe,
          rOled,
          wOled,
          rLedPipe,
          wLedPipe,
          rNumpadPipe,
          wNumpadPipe,
          rCamCmdPipe,
          wCamCmdPipe,
          rCamImgPipe,
          wCamImgPipe);

      await initSingletons();
      await tester.pumpWidget(
          Screenshot(controller: envoyScreenshotController, child: EnvoyApp()));

      await tester.pump();

      //final learnMore = find.text('Learn More');
      //final buyPassport = find.text('Buy Passport');
      //final emptyDevices = find.byType(GhostDevice);
      //final connectExistingPassport = find.text("CONNECT AN EXISTING PASSPORT");
      //final getStarted = find.text("Get Started");

      final setUpButtonFinder = find.text('Set Up Envoy Wallet');
      expect(setUpButtonFinder, findsOneWidget);
      await tester.tap(setUpButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      final continueButtonFinder = find.text('Continue');
      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      final enableMagicButtonFinder = find.text('Enable Magic Backups');
      expect(enableMagicButtonFinder, findsOneWidget);
      await tester.tap(enableMagicButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      // video
      final createMagicButtonFinder = find.text('Create Magic Backup');
      expect(createMagicButtonFinder, findsOneWidget);
      await tester.tap(createMagicButtonFinder);
      await tester.pump(Duration(milliseconds: 1500));

      await tester.pumpAndSettle();

      // animations
      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      final devicesButton = find.text('Devices');
      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      final iconPlus = find.byIcon(Icons.add);
      await tester.tap(iconPlus);
      await tester.pumpAndSettle();

      final connectNewPassport = find.text("SET UP A NEW PASSPORT");
      await tester.tap(connectNewPassport);
      await tester.pumpAndSettle();

      final acceptButton = find.text("I Accept");
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();

      final next = find.text("Next");
      await tester.tap(next);
      await tester.pumpAndSettle();

      await passport.pressButton(PassportButtons.right);
      await pause(1000);

      await passport.pressButton(PassportButtons.right);
      await pause(1000);
      await passport.pressButton(PassportButtons.right);
      await pause(1000);
      await passport.pressButton(PassportButtons.right);

      await pause(2000);

      await passport.containsText(["Scanning"]);
      await passport.sendFramesUntil(70, ["On Envoy, select Next", "100%"]);

      await pause(1000);
      await passport.pressButton(PassportButtons.right);

      await tester.tap(next);
      await tester.pumpAndSettle();

      final continueButton = find.text("Continue");
      await tester.tap(continueButton);

      await pause(1000);

      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await passport.pressButton(PassportButtons.right);
      await pause(1000);

      final passportInsecureContactUsFinder = find.text('Contact Us');
      expect(passportInsecureContactUsFinder, findsOneWidget);
      await Passport.cleanUp();
    });

//     testWidgets('Connect an existing passport flow', (tester) async {
//       await resetEnvoyData();
//       await initSingletons();
//       await tester.pumpWidget(EnvoyApp());
//
//       final originalOnError = FlutterError.onError!;
//       FlutterError.onError = (FlutterErrorDetails details) {
//         originalOnError(details);
//       };
//
//       await tester.pump();
//
//       final setUpButtonFinder = find.text('Set Up Envoy Wallet');
//       final continueButtonFinder = find.text('Continue');
//       final enableMagicButtonFinder = find.text('Enable Magic Backups');
//       final createMagicButtonFinder = find.text('Create Magic Backup');
//
//       expect(setUpButtonFinder, findsOneWidget);
//       await tester.tap(setUpButtonFinder);
//       await tester.pump(Duration(milliseconds: 500));
//
//       expect(continueButtonFinder, findsOneWidget);
//       await tester.tap(continueButtonFinder);
//       await tester.pump(Duration(milliseconds: 500));
//
//       expect(enableMagicButtonFinder, findsOneWidget);
//       await tester.tap(enableMagicButtonFinder);
//       await tester.pump(Duration(milliseconds: 500));
//
//       //video
//       expect(createMagicButtonFinder, findsOneWidget);
//       await tester.tap(createMagicButtonFinder);
//       await tester.pump(Duration(milliseconds: 1500));
//
//       await tester.pumpAndSettle();
//
// // animations
//
//       expect(continueButtonFinder, findsOneWidget);
//       await tester.tap(continueButtonFinder);
//       await tester.pump(Duration(milliseconds: 500));
//
//       expect(continueButtonFinder, findsOneWidget);
//       await tester.tap(continueButtonFinder);
//       await tester.pump(Duration(milliseconds: 500));
//
// // main ˇˇ
//
//       final devicesButton = find.text('Devices');
//       final iconPlus = find.byIcon(Icons.add);
//       final connectExistingPassport = find.text("CONNECT AN EXISTING PASSPORT");
//       final getStarted = find.text("Get Started");
//
//       await tester.tap(devicesButton);
//       await tester.pumpAndSettle();
//
//       await tester.tap(iconPlus);
//       await tester.pumpAndSettle();
//
//       await tester.tap(connectExistingPassport);
//       await tester.pump(Duration(milliseconds: 500));
//
//       expect(getStarted, findsOneWidget);
//       await tester.tap(getStarted);
//       await tester.pumpAndSettle();
//
//       expect(continueButtonFinder, findsOneWidget);
//       await tester.tap(continueButtonFinder);
//       // await tester.pumpAndSettle();
//     });
  });
}

Future<void> pause(int duration) async {
  await Future.delayed(Duration(milliseconds: duration), () {});
}

Future<void> resetEnvoyData() async {
  // Preferences
  final prefs = await SharedPreferences.getInstance();
  final appSupportDir = await getApplicationSupportDirectory();

  // Database
  final String dbName = 'envoy.db';
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbFile = File(join(appDocumentDir.path, dbName));

  try {
    // Clear shared preferences
    await prefs.clear();
    // Delete app data directory
    await appSupportDir.delete(recursive: true);
    // Delete the database file
    await dbFile.delete();
  } catch (e) {
    print('Error deleting app data: $e');
  }
}

class Passport {
  final currentPath = Directory.current.path;
  final qrScannerDevice = '/dev/video5';
  final oledV4lDevice = '/dev/video6';
  final oledV4lDeviceDuplicate = '/dev/video7';

  final ScreenshotController screenshotController;
  final WidgetTester tester;

  final Pipe numpadPipe;
  final File rOled,
      wOled,
      rLedPipe,
      wLedPipe,
      rNumpadPipe,
      wNumpadPipe,
      rCamCmdPipe,
      wCamCmdPipe,
      rCamImgPipe,
      wCamImgPipe;

  late final String oledHandleNum;
  late final String numpadHandleNum;
  late final String ledHandleNum;
  late final String camCmdHandleNum;
  late final String camImgHandleNum;

  Passport(
    this.screenshotController,
    this.tester,
    this.numpadPipe,
    this.rOled,
    this.wOled,
    this.rLedPipe,
    this.wLedPipe,
    this.rNumpadPipe,
    this.wNumpadPipe,
    this.rCamCmdPipe,
    this.wCamCmdPipe,
    this.rCamImgPipe,
    this.wCamImgPipe,
  ) {
    oledHandleNum = basename(wOled.path);
    numpadHandleNum = basename(rNumpadPipe.path);
    ledHandleNum = basename(wLedPipe.path);
    camCmdHandleNum = basename(wCamCmdPipe.path);
    camImgHandleNum = basename(rCamImgPipe.path);

    final passportPath = "$currentPath/passport2";
    final env = {
      "MICROPYPATH":
          ":$passportPath/simulator/sim_modules:$passportPath/ports/stm32/boards/Passport/modules:$passportPath/extmod"
    };

    print("Command: " +
        "MICROPYPATH=" +
        env["MICROPYPATH"]! +
        " " +
        '$passportPath/ports/unix/passport-mpy -X heapsize=30m -i $passportPath/simulator/sim_boot.py $oledHandleNum $numpadHandleNum $ledHandleNum $camCmdHandleNum $camImgHandleNum color');

    Process.start(
      '$passportPath/ports/unix/passport-mpy',
      [
        '-X',
        'heapsize=30m',
        '-i',
        '$passportPath/simulator/sim_boot.py',
        oledHandleNum,
        numpadHandleNum,
        ledHandleNum,
        camCmdHandleNum,
        camImgHandleNum,
        "color"
      ],
      environment: env,
      workingDirectory: passportPath,
    ).then((simulator) async {
      simulator.stdout.listen((event) {
        print("simulator: " + utf8.decode(event));
      });
      simulator.stderr.listen((event) {
        print("simulator ERR:" + utf8.decode(event));
      });
      await Future.delayed(const Duration(seconds: 2), () {});

      createV4lDevices(oledHandleNum, oledV4lDevice, oledV4lDeviceDuplicate);
      displayOled(oledV4lDeviceDuplicate);
    });
  }

  static reset() {
    final currentPath = Directory.current.path;
    final passportPath = "$currentPath/passport2";

    // final directoryToDelete = '$currentPath/passport2/simulator/work';
    // Directory(directoryToDelete).deleteSync();

    final fileToDelete = 'spi_flash.bin';
    try {
      File(passportPath + "/" + fileToDelete).deleteSync();
    } on Exception catch (e) {
      print("Couldn't reset Passport: $e");
    }
  }

  static cleanUp() async {
    cleanUpFfmpeg();
    cleanUpSim();
  }

  static cleanUpFfmpeg() async {
    await Process.run('pkill', ['-9', 'ffmpeg']);
  }

  static cleanUpSim() async {
    await Process.run('pkill', ['-9', 'passport-mpy']);
  }

  void displayOled(String oledV4lDeviceDuplicate) {
    Process.start('ffplay', ['$oledV4lDeviceDuplicate'],
        environment: {"DISPLAY": ":0"}).then((ffplay) {
      print("ffplay started!");
      // ffplay.stderr.listen((event) {
      //   print("ffplay: " + utf8.decode(event));
      // });
    });
  }

  void createV4lDevices(String oledHandleNum, String oledV4lDevice,
      String oledV4lDeviceDuplicate) {
    Process.start('ffmpeg', [
      '-vcodec',
      'rawvideo',
      '-f',
      'rawvideo',
      '-pix_fmt',
      'rgb565',
      '-s',
      '240x320',
      '-i',
      '/proc/$pid/fd/$oledHandleNum',
      '-f',
      'video4linux2',
      oledV4lDevice,
      '-f',
      'video4linux2',
      oledV4lDeviceDuplicate,
      '-f',
      'video4linux2',
      qrScannerDevice,
    ]).then((ffmpeg) {
      print("v4l devices created!");
      ffmpeg.stdout.listen((event) {
        print(event);
      });
      ffmpeg.stderr.listen((event) {
        print("ffmpeg :" + utf8.decode(event));
      });
    });
  }

  Future<void> sendFramesUntil(int number, List<String> text) async {
    for (var i = 0; i < number; i++) {
      await sendFrameToPassport(screenshotController, rCamImgPipe.path);
      await pause(100);
      await tester.pumpAndSettle();
      if (await containsText(text)) {
        break;
      }
    }
  }

  Future<void> sendFrameToPassport(
      ScreenshotController screenshotController, String camPipePath) async {
    final currentPath = Directory.current.path;
    final screenshotFileName = "screenshot.png";
    await screenshotController.captureAndSave(currentPath,
        fileName: screenshotFileName);

    final imagePath = '$currentPath/$screenshotFileName';

    var scriptPath = '$currentPath/integration_test/png_to_raw.sh';

    // ignore: unused_local_variable
    final script = await Process.run(
        'bash', [scriptPath, imagePath, camPipePath],
        stdoutEncoding: systemEncoding, stderrEncoding: systemEncoding);
    //print("STDOUT: " + script.stdout);
    //print("STDERR: " + script.stderr);
  }

  Future<bool> containsText(List<String> texts) async {
    var scriptPath = '$currentPath/integration_test/ocr_passport.sh';

    // Run the script using Bash
    ProcessResult process = await Process.run(
        'bash', [scriptPath, oledV4lDevice],
        stdoutEncoding: systemEncoding);

    if (process.stdout == null) {
      return false;
    }

    print("CAPTURE: " + process.stdout);

    for (final text in texts) {
      if (process.stdout.contains(text)) {
        print('This screen contains: $text');
        return true;
      }
    }

    print('This screen does not contain: $texts');
    return false;
  }

  Future<void> pressButton(String button) async {
    numpadPipe.write.add('$button:d\n'.codeUnits);
    await pause(200);
    numpadPipe.write.add('$button:u\n'.codeUnits);
  }
}

class PassportButtons {
  static String get left => "x";

  static String get right => "y";

  static String get navigationUp => "u";

  static String get navigationDown => "d";

  static String get navigationRight => "r";

  static String get navigationLeft => "l";

  static String get number0 => "0";

  static String get number1 => "1";

  static String get number2 => "2";

  static String get number3 => "3";

  static String get number4 => "4";

  static String get number5 => "5";

  static String get number6 => "6";

  static String get number7 => "7";

  static String get number8 => "8";

  static String get number9 => "9";

  static String get star => "*";

  static String get hash => "#";
}
