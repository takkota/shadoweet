import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shadoweet/enum/item.dart';
import 'package:shadoweet/urility/SharedPreferencesHelper.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:tuple/tuple.dart';

class ItemSelectScreen extends StatefulWidget {
  var allItems = <Item>[
    Item((b) => b ..itemType=ItemType.FOOD ..name="ドッグフード" ..price=10 ..affection=0  ..iconImagePath="assets/food.png"),
    Item((b) => b ..itemType=ItemType.JERKY ..name="ジャーキー" ..price=50 ..affection=10 ..iconImagePath="assets/jerky.png"),
    Item((b) => b ..itemType=ItemType.BONE ..name="骨" ..price=100 ..affection=50 ..iconImagePath="assets/bone.png"),
    Item((b) => b ..itemType=ItemType.SKATE ..name="スケボ" ..price=300 ..affection=100 ..iconImagePath="assets/skate.png"),
    Item((b) => b ..itemType=ItemType.HULAHOOP ..name="フラフープ" ..price=400 ..affection=200 ..iconImagePath="assets/hulahoop.png"),
    Item((b) => b ..itemType=ItemType.SUNGLASSES ..name="サングラス" ..price=600 ..affection=350 ..iconImagePath="assets/sunglasses.png"),
    Item((b) => b ..itemType=ItemType.BALL ..name="ボール" ..price=1000 ..affection=300 ..iconImagePath="assets/ball.png"),

    //Item((b) => b ..itemType=ItemType.FOOD ..name="DOG FOOD" ..price=0 ..affection=0  ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.BONE ..name="BONE" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.JERKY ..name="JERKY" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.HULAHOOP ..name="HULAHOOP" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.SKATE ..name="SKATE" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.BALL ..name="BALL" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
    //Item((b) => b ..itemType=ItemType.SUNGLASSES ..name="SUNGLASSES" ..price=0 ..affection=0 ..iconImagePath="assets/heart.png"),
  ];

  @override
  ItemSelectScreenState createState() => new ItemSelectScreenState();
}

class ItemSelectScreenState extends State<ItemSelectScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: new Text("何をあげよう？"), centerTitle: true),
        body: Builder(
          builder: (BuildContext context) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              shrinkWrap: true,
              children: List.generate(widget.allItems.length, (index) {
                return InkWell(
                  // When the user taps the button, show a snackbar
                    onTap: () => onTapItem(index, context),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.lightGreen)
                        ),
                        alignment: Alignment.center,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Image.asset(widget.allItems[index].iconImagePath, fit: BoxFit.contain),
                                flex: 3,
                              ),
                              Expanded(
                                child: Text(widget.allItems[index].name, style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                                flex: 1,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Image.asset('assets/heart.png'),
                                        Text(widget.allItems[index].affection.toString())
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Image.asset('assets/money.png', scale: 0.5, fit: BoxFit.scaleDown),
                                        Text(widget.allItems[index].price.toString())
                                      ],
                                    )
                                  ],
                                ),
                                flex: 1,
                              )
                            ]
                        )
                    )
                );
              }),
            );
          },
        )
    );
  }

  void onTapItem(int index, BuildContext context) async {
    final affection = await SharedPreferencesHelper.getAffection();
    final money = await SharedPreferencesHelper.getMoney();
    if (widget.allItems[index].affection > affection) {
      final snackBar = SnackBar(content: Text('愛情が足りないワン...'));
      Scaffold.of(context).showSnackBar(snackBar);
    } else if (widget.allItems[index].price > money) {
      final snackBar = SnackBar(content: Text('お金が足りないワン...'));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      SharedPreferencesHelper.countUpMoney(-widget.allItems[index].price);
      Navigator.pop(context, widget.allItems[index].itemType);
    }
  }
}
