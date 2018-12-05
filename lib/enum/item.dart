import 'package:built_value/built_value.dart';

part 'item.g.dart';

abstract class Item implements Built<Item, ItemBuilder> {

  String get name;
  int get price;
  int get affection;
  String get iconImagePath;
  ItemType get itemType;

  Item._();
  factory Item([updates(ItemBuilder b)]) = _$Item;
}

enum ItemType {
  FOOD, BONE, JERKY, HULAHOOP, BALL, SKATE, SUNGLASSES
}
