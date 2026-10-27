// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/restore_account_metadata.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngwallet/ngwallet.dart';

const walletPath = '/wallets/envoy_bitcoin_aabbccdd_acc_0';

NgAccountBackup backup({
  Map<String, String> notes = const {'txid': 'Customer note'},
  Map<String, String> tags = const {},
  Map<String, bool> doNotSpend = const {},
}) =>
    NgAccountBackup(
      ngAccountConfig: NgAccountConfig(
        name: 'Mobile Wallet',
        color: '#009DB9',
        seedHasPassphrase: false,
        deviceSerial: 'envoy',
        preferredAddressType: AddressType.p2Wpkh,
        index: 0,
        descriptors: const [],
        network: Network.bitcoin,
        id: 'original-wallet-id',
        archived: false,
        lastRemoteSequence: BigInt.zero,
      ),
      xfp: 'aabbccdd',
      publicDescriptors: const [],
      lastUsedIndex: const [],
      notes: notes,
      tags: tags,
      doNotSpend: doNotSpend,
    );

class RecordingHandler extends Fake implements EnvoyAccountHandler {
  RecordingHandler(this.path);

  final String path;
  final notes = <String, String>{};
  final tags = <String, String>{};
  final doNotSpend = <String, bool>{};
  final events = <String>[];
  Completer<void>? migration;
  Object? writeError;
  Object? updateError;

  @override
  String getDirectoryPath() => path;

  @override
  Future<void> migrateMeta({
    required Map<String, String> notes,
    required Map<String, String> tags,
    required Map<String, bool> doNotSpend,
  }) async {
    events.add('migrate');
    if (writeError != null) throw writeError!;
    if (migration != null) await migration!.future;
    this.notes.addAll(notes);
    this.tags.addAll(tags);
    this.doNotSpend.addAll(doNotSpend);
  }

  @override
  Future<void> sendUpdate() async {
    if (updateError != null) throw updateError!;
    events.add('update');
  }
}

void main() {
  test('seed-created hot wallet receives notes even without any tags',
      () async {
    final handler = RecordingHandler(walletPath);
    final restored = await restoreExistingAccountMetadata(
      handlers: [handler],
      directoryPath: walletPath,
      backup: backup(),
    );

    expect(restored, same(handler));
    expect(handler.notes, {'txid': 'Customer note'});
    expect(handler.tags, isEmpty);
    expect(handler.events, ['migrate', 'update']);
  });

  test('restores tags and coin locks along with notes', () async {
    final handler = RecordingHandler(walletPath);
    await restoreExistingAccountMetadata(
      handlers: [handler],
      directoryPath: walletPath,
      backup: backup(
        tags: {'txid:0': 'Savings'},
        doNotSpend: {'txid:0': true},
      ),
    );

    expect(handler.tags, {'txid:0': 'Savings'});
    expect(handler.doNotSpend, {'txid:0': true});
    expect(handler.notes, {'txid': 'Customer note'});
  });

  test('only the matching wallet receives metadata', () async {
    final others = [
      RecordingHandler('/wallets/envoy_signet_aabbccdd_acc_0'),
      RecordingHandler('/wallets/envoy_bitcoin_11223344_acc_0'),
      RecordingHandler('/wallets/envoy_bitcoin_aabbccdd_acc_1'),
      RecordingHandler('/wallets/passport_bitcoin_aabbccdd_acc_0'),
    ];
    final matching = RecordingHandler(walletPath);
    expect(
      await restoreExistingAccountMetadata(
        handlers: [...others, matching],
        directoryPath: walletPath,
        backup: backup(),
      ),
      same(matching),
    );
    for (final other in others) {
      expect(other.events, isEmpty);
    }
    expect(matching.notes, {'txid': 'Customer note'});
  });

  test('missing wallet falls through to normal account restoration', () async {
    final other = RecordingHandler('/wallets/other');
    expect(
      await restoreExistingAccountMetadata(
        handlers: [other],
        directoryPath: walletPath,
        backup: backup(),
      ),
      isNull,
    );
    expect(other.events, isEmpty);
  });

  test('waits for metadata persistence before publishing the account',
      () async {
    final handler = RecordingHandler(walletPath)..migration = Completer<void>();
    final restored = restoreExistingAccountMetadata(
      handlers: [handler],
      directoryPath: walletPath,
      backup: backup(),
    );
    expect(handler.events, ['migrate']);
    handler.migration!.complete();
    expect(await restored, same(handler));
    expect(handler.events, ['migrate', 'update']);
  });

  test('a failed metadata write does not publish a successful update',
      () async {
    final handler = RecordingHandler(walletPath)..migration = Completer<void>();
    final restored = restoreExistingAccountMetadata(
      handlers: [handler],
      directoryPath: walletPath,
      backup: backup(),
    );
    final failure = expectLater(restored, throwsStateError);
    handler.migration!.completeError(StateError('Storage failure'));
    await failure;
    expect(handler.events, ['migrate']);
  });

  for (final failDuringUpdate in [false, true]) {
    test(
      'failed ${failDuringUpdate ? 'publication' : 'write'} does not skip later accounts or report success',
      () async {
        final error = StateError('Storage failure');
        final failed = RecordingHandler('/wallets/failed');
        if (failDuringUpdate) {
          failed.updateError = error;
        } else {
          failed.writeError = error;
        }
        final existing = RecordingHandler(walletPath);
        final paths = ['/wallets/failed', walletPath, '/wallets/new'];
        final errors = <Object>[];
        final created = <String>[];
        var attempted = 0;

        final complete = await restoreAccountBackups(
          backups: [backup(), backup(), backup()],
          restore: (accountBackup) async {
            final path = paths[attempted++];
            if (await restoreExistingAccountMetadata(
                  handlers: [failed, existing],
                  directoryPath: path,
                  backup: accountBackup,
                ) !=
                null) {
              return;
            }
            created.add(path);
          },
          onError: (error, stack) => errors.add(error),
        );

        expect(complete, isFalse);
        expect(attempted, 3);
        expect(errors, [error]);
        expect(failed.events, ['migrate']);
        expect(existing.notes, {'txid': 'Customer note'});
        expect(existing.events, ['migrate', 'update']);
        // A failed existing wallet must not be reopened via the fallback.
        expect(created, ['/wallets/new']);
      },
    );
  }

  test('complete recovery waits for every account and returns true', () async {
    final write = Completer<void>();
    var restored = 0;
    final complete = restoreAccountBackups(
      backups: [backup(), backup()],
      restore: (_) async {
        await write.future;
        restored++;
      },
      onError: (error, stack) => fail('Unexpected recovery failure'),
    );
    expect(restored, 0);
    write.complete();
    expect(await complete, isTrue);
    expect(restored, 2);
  });
}
