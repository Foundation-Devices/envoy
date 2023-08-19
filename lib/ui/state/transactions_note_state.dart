import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final txNoteStreamProvider = StreamProvider.family<String?, String>((ref, id) {
  return EnvoyStorage().getTxNotesStream(id);
});

final txNoteProvider = Provider.family<String?, String>((ref, id) {
  final txNoteSnapShot = ref.watch(txNoteStreamProvider(id));
  if (txNoteSnapShot.hasValue) {
    return txNoteSnapShot.valueOrNull;
  } else {
    return null;
  }
});
