// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'package:envoy/main.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetData() async {
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
  final oledV4lDevice = '/dev/video5';
  final oledV4lDeviceDuplicate = '/dev/video6';

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
            environment: env)
        .then((simulator) async {
      simulator.stdout.listen((event) {
        print("simulator: " + utf8.decode(event));
      });
      await Future.delayed(const Duration(seconds: 2), () {});

      createV4lDevices(oledHandleNum, oledV4lDevice, oledV4lDeviceDuplicate);
      displayOled(oledV4lDeviceDuplicate);
    });
  }

  static reset() {
    final currentPath = Directory.current.path;

    // final directoryToDelete = '$currentPath/passport2/simulator/work';
    // Directory(directoryToDelete).deleteSync();

    final fileToDelete = 'spi_flash.bin';
    try {
      File(currentPath + "/" + fileToDelete).deleteSync();
    } on Exception catch (e) {
      print("Couldn't reset Passport: $e");
    }
  }

  static cleanUpFfmpeg() async {
    await Process.run('pkill', ['-9', 'ffmpeg']);
  }

  void displayOled(String oledV4lDeviceDuplicate) {
    Process.start('ffplay', [oledV4lDeviceDuplicate]).then((ffplay) {
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
    ]).then((ffmpeg) {
      print("ffmpeg started!");
      // ffmpeg.stdout.listen((event) {
      //   print(event);
      // });
      // ffmpeg.stderr.listen((event) {
      //   print("ffmpeg :" + utf8.decode(event));
      // });
    });
  }

  Future<void> sendFrames(int number) async {
    for (var i = 0; i < number; i++) {
      await sendScreenToPassport(screenshotController, camImgHandleNum);
      await pause(100);
      await tester.pumpAndSettle();
    }
  }

  Future<void> sendScreenToPassport(
      ScreenshotController screenshotController, String CamPipeNumber) async {
    final currentPath = Directory.current.path;
    final screenshotFileName = "screenshot";
    await screenshotController.captureAndSave(currentPath,
        fileName: screenshotFileName);

    final imagePath = '$currentPath/$screenshotFileName';
    final rawImage = '$currentPath/rawImage.raw';
    var scriptPath = '$currentPath/integration_test/png_to_raw.sh';
    await Process.run('bash', [scriptPath, imagePath, rawImage]);

    Process.run('ffmpeg', [
      '-vcodec',
      'rawvideo',
      '-f',
      'rawvideo',
      '-pix_fmt',
      'rgb565',
      '-s',
      '396x330',
      '-i',
      rawImage,
      '-vcodec',
      'rawvideo',
      '-f',
      'rawvideo',
      '-pix_fmt',
      'rgb565',
      '-s',
      '396x330',
      '/proc/$pid/fd/$CamPipeNumber',
      '-y'
    ]);
  }

  Future<bool> containsText(String text) async {
    var scriptPath = '$currentPath/integration_test/ocr_passport.sh';

    // Run the script using Bash
    ProcessResult process =
        await Process.run('bash', [scriptPath, oledV4lDevice]);
    await process.stdout.forEach((data) {
      if (data.contains(text)) {
        print('This screen contains: $text');
        return true;
      } else {
        print('This string does not contain: $text');
        return false;
      }
    });

    return false;
  }

  Future<void> pressButton(String button) async {
    numpadPipe.write.add('$button:d\n'.codeUnits);
    await pause(200);
    numpadPipe.write.add('$button:u\n'.codeUnits);
  }
}

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Connect a new passport flow', (tester) async {
      Directory fdDir = Directory('/proc/$pid/fd');

      final oledPipe = await Pipe.create();
      final ledPipe = await Pipe.create();
      final numpadPipe = await Pipe.create();
      final camCmdPipe = await Pipe.create();
      final camImgPipe = await Pipe.create();

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

      Passport.reset();
      await Passport.cleanUpFfmpeg();

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

      await tester.pumpAndSettle();

      final devicesButton = find.text('Devices');
      final learnMore = find.text('Learn More');
      final buyPassport = find.text('Buy Passport');
      final emptyDevices = find.byType(GhostDevice);
      final iconPlus = find.byIcon(Icons.add);
      final connectExistingPassport = find.text("CONNECT AN EXISTING PASSPORT");
      final connectNewPassport = find.text("SET UP A NEW PASSPORT");
      final acceptButton = find.text("I Accept");
      final Next = find.text("Next");
      final getStarted = find.text("Get Started");
      final continueButton = find.text("Continue");

      final currentPath = Directory.current.path;

      /////////////////////////////////////////// PATH TO QR CODE FOR CONNECT NEW PASSPORT

      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      await tester.tap(iconPlus);
      await tester.pumpAndSettle();

      await tester.tap(connectNewPassport);
      await tester.pumpAndSettle();

      await tester.tap(acceptButton);
      await tester.pumpAndSettle();
      await tester.tap(Next);

      await tester.pumpAndSettle();

      ///////////////////////////////////////////////////////////////////////

      // final oled_w = oledPipe.write;
      // final oled_r = oledPipe.read;
      //
      // final led_w = ledPipe.write;
      // final led_r = ledPipe.read;
      //
      // final numpad_w = numpadPipe.write;
      // final numpad_r = numpadPipe.read;
      //
      // final cam_cmd_w = camCmdPipe.write;
      // final cam_cmd_r = camCmdPipe.read;
      //
      // final cam_img_w = camImgPipe.write;
      // final cam_img_r = camImgPipe.read;

      // // IMPORTANT: in debug read int values of these handles !!!!!!!!!!!
      // final oledHandle = ResourceHandle.fromWritePipe(oled_w);
      // final numpadHandle = ResourceHandle.fromReadPipe(numpad_r);
      // final ledHandle = ResourceHandle.fromWritePipe(led_w);
      // final camCmdHandle = ResourceHandle.fromWritePipe(cam_cmd_w);
      // final camImgHandle = ResourceHandle.fromReadPipe(cam_img_r);

      await pause(2000);
      await passport.containsText("Welcome to Passport");

      await passport.pressButton(PassportButtons.right);
      await pause(1000);
      await passport.pressButton(PassportButtons.right);
      await pause(1000);
      await passport.pressButton(PassportButtons.right);
      await pause(1000);
      await passport.pressButton(PassportButtons.right);

      //expect(await passport.containsText("Scanning"), true);
      // here is scanning

      await passport.sendFrames(70);

      await Future.delayed(const Duration(minutes: 500), () {});
    });

    testWidgets('Connect an existing passport flow', (tester) async {
      await resetData();
      await initSingletons();
      await tester.pumpWidget(EnvoyApp());

      final originalOnError = FlutterError.onError!;
      FlutterError.onError = (FlutterErrorDetails details) {
        originalOnError(details);
      };

      await tester.pump();

      final setUpButtonFinder = find.text('Set Up Envoy Wallet');
      final continueButtonFinder = find.text('Continue');
      final enableMagicButtonFinder = find.text('Enable Magic Backups');
      final createMagicButtonFinder = find.text('Create Magic Backup');

      expect(setUpButtonFinder, findsOneWidget);
      await tester.tap(setUpButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(enableMagicButtonFinder, findsOneWidget);
      await tester.tap(enableMagicButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      //video
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

// main ˇˇ

      final devicesButton = find.text('Devices');
      final iconPlus = find.byIcon(Icons.add);
      final connectExistingPassport = find.text("CONNECT AN EXISTING PASSPORT");
      final getStarted = find.text("Get Started");

      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      await tester.tap(iconPlus);
      await tester.pumpAndSettle();

      await tester.tap(connectExistingPassport);
      await tester.pump(Duration(milliseconds: 500));

      expect(getStarted, findsOneWidget);
      await tester.tap(getStarted);
      await tester.pumpAndSettle();

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();
    });
  });
}

Future<void> pause(int duration) async {
  await Future.delayed(Duration(milliseconds: duration), () {});
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
