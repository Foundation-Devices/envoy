import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:envoy/util/console.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/wallet.dart';

void main() {
  test("Benchmark sorting", () async {
    final sortedFile = File('./test/assets/sorted_txs.json');
    final sortedJson = await sortedFile.readAsString();

    List<Transaction> sorted = [];
    for (final transaction in jsonDecode(sortedJson)) {
      sorted.add(Transaction.fromJson(transaction));
    }

    List<Transaction> unsorted = List.from(sorted);
    unsorted.shuffle();

    expect(unsorted.length, sorted.length);

    // Let's benchmark this
    Stopwatch stopwatch = Stopwatch()..start();
    kPrint("Have to sort ${unsorted.length} transactions");
    unsorted.sort();
    kPrint('Sorted in ${stopwatch.elapsed.inMilliseconds}ms');

    for (var i = 0; i < unsorted.length; i++) {
      expect(unsorted[i].txId, sorted[i].txId);
    }
  });
}
