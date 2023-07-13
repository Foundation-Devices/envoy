import 'package:freezed_annotation/freezed_annotation.dart';

part 'coins.g.dart';

@JsonSerializable()
class Coin {
  final String hash;
  final int index;
  final bool locked;
  final double amount;

  Coin({
    required this.hash,
    required this.index,
    required this.locked,
    required this.amount,
  });

  String getUniqueId() {
    return "${this.hash}:${this.index}";
  }

  factory Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

  Map<String, dynamic> toJson() => _$CoinToJson(this);
}
