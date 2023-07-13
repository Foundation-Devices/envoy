import 'package:envoy/business/coins.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_tag.g.dart';

@JsonSerializable()
class CoinTag {
  String id;
  String name;
  List<Coin> coins;

  CoinTag({
    required this.id,
    required this.name,
    required this.coins,
  });

  int get numOfLockedCoins => coins.where((element) => element.locked).length;

  int get numOfUnLockedCoins =>
      coins.where((element) => !element.locked).length;

  int get numOfCoins => coins.length;

  factory CoinTag.fromJson(Map<String, dynamic> json) =>
      _$CoinTagFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTagToJson(this);
}
