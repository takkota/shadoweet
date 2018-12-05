// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: avoid_returning_this
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_new
// ignore_for_file: test_types_in_equals

class _$Item extends Item {
  @override
  final String name;
  @override
  final int price;
  @override
  final int affection;
  @override
  final String iconImagePath;
  @override
  final ItemType itemType;

  factory _$Item([void updates(ItemBuilder b)]) =>
      (new ItemBuilder()..update(updates)).build();

  _$Item._(
      {this.name,
      this.price,
      this.affection,
      this.iconImagePath,
      this.itemType})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Item', 'name');
    }
    if (price == null) {
      throw new BuiltValueNullFieldError('Item', 'price');
    }
    if (affection == null) {
      throw new BuiltValueNullFieldError('Item', 'affection');
    }
    if (iconImagePath == null) {
      throw new BuiltValueNullFieldError('Item', 'iconImagePath');
    }
    if (itemType == null) {
      throw new BuiltValueNullFieldError('Item', 'itemType');
    }
  }

  @override
  Item rebuild(void updates(ItemBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemBuilder toBuilder() => new ItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Item &&
        name == other.name &&
        price == other.price &&
        affection == other.affection &&
        iconImagePath == other.iconImagePath &&
        itemType == other.itemType;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, name.hashCode), price.hashCode), affection.hashCode),
            iconImagePath.hashCode),
        itemType.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Item')
          ..add('name', name)
          ..add('price', price)
          ..add('affection', affection)
          ..add('iconImagePath', iconImagePath)
          ..add('itemType', itemType))
        .toString();
  }
}

class ItemBuilder implements Builder<Item, ItemBuilder> {
  _$Item _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  int _price;
  int get price => _$this._price;
  set price(int price) => _$this._price = price;

  int _affection;
  int get affection => _$this._affection;
  set affection(int affection) => _$this._affection = affection;

  String _iconImagePath;
  String get iconImagePath => _$this._iconImagePath;
  set iconImagePath(String iconImagePath) =>
      _$this._iconImagePath = iconImagePath;

  ItemType _itemType;
  ItemType get itemType => _$this._itemType;
  set itemType(ItemType itemType) => _$this._itemType = itemType;

  ItemBuilder();

  ItemBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _price = _$v.price;
      _affection = _$v.affection;
      _iconImagePath = _$v.iconImagePath;
      _itemType = _$v.itemType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Item other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Item;
  }

  @override
  void update(void updates(ItemBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Item build() {
    final _$result = _$v ??
        new _$Item._(
            name: name,
            price: price,
            affection: affection,
            iconImagePath: iconImagePath,
            itemType: itemType);
    replace(_$result);
    return _$result;
  }
}
