import 'dart:convert';
import 'dart:io';

Directory libDirectory = Directory(Directory.current.path + Platform.pathSeparator + "lib");

List excludedDirs = [
  "${libDirectory.path}${Platform.pathSeparator}l10n",
  "${libDirectory.path}${Platform.pathSeparator}generated",
];

Directory arbDirectory =
    Directory(Directory.current.path + Platform.pathSeparator + "lib" + Platform.pathSeparator + "l10n");

main(args) async {
  File arbFile = File(arbDirectory.path + Platform.pathSeparator + "intl_en.arb");

  String arbContent = await arbFile.readAsString();
  Map<String, dynamic> textKeys = jsonDecode(arbContent);
  print("Total Keys: ${textKeys.keys.length}");

  List<String> excludedKeys = [];
  textKeys.keys.forEach((element) {
    bool foundUsage = false;
    libDirectory.listSync(recursive: true).forEach((file) {
      if (file is File && file.path.endsWith(".dart")) {
        for (final dir in excludedDirs) {
          if (file.path.contains(dir)) {
            /// Skip excluded directories files
            return;
          }
        }
        if (foundUsage) {
          return;
        }
        String content = file.readAsStringSync();
        if (content.contains(element)) {
          foundUsage = true;
        }
      }
    });
    if (!foundUsage) {
      if (!excludedKeys.contains(element)) {
        excludedKeys.add(element);
      }
    }
  });

  arbDirectory.listSync().forEach((file) {
    if (file is File && file.path.endsWith(".arb")) {
      String content = file.readAsStringSync();
      Map<dynamic, dynamic> textKeys = jsonDecode(content);
      excludedKeys.forEach((element) {
        textKeys.remove(element);
      });
      file.writeAsStringSync(jsonEncode(textKeys));
    }
  });
  print("Excluded ${excludedKeys.length} \nAfter filter: ${textKeys.keys.length - excludedKeys.length}\n Generating intl files...");

  await Process.run("flutter", ["pub", "global", "run", "intl_utils:generate"]);

  if (args.contains("--print-excludedKeys")) {
    print("Excluded keys:\n ${excludedKeys.join("\n")}");
  }
}
