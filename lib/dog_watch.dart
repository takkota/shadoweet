import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:shadoweet/bloc/DogWatchBloc.dart';
import 'package:shadoweet/dog_walk.dart';
import 'package:shadoweet/enum/item.dart';
import 'package:shadoweet/item_select.dart';
import 'package:shadoweet/provider/BlocProviderUtil.dart';
import 'package:shadoweet/provider/DogWatchProvider.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';

ImageMap _images;
SpriteSheet _dogSprites;
SpriteSheet _itemSprites;

class DogWatchScreen extends StatefulWidget {

  @override
  DogWatchScreenState createState() => new DogWatchScreenState();
}

class DogWatchScreenState extends State<DogWatchScreen> with TickerProviderStateMixin {
  DogRunArea dogRunArea = null;
  bool assetsLoaded = false;
  DogWatchBloc bloc;
  BannerAd _bannerAd;

  Future<Null> _loadAsset(AssetBundle bundle) async {
    _images = new ImageMap(bundle);
    await _images.load(<String>[
      'assets/room_basic.png',
      'assets/dog_sprites.png',
      'assets/item_sprites.png',
    ]);
    String json = await DefaultAssetBundle.of(context).loadString(
        'assets/dog_sprites.json');
    _dogSprites = new SpriteSheet(_images['assets/dog_sprites.png'], json);
    json = await DefaultAssetBundle.of(context).loadString('assets/item_sprites.json');
    _itemSprites = new SpriteSheet(_images['assets/item_sprites.png'], json);
  }

  @override
  void initState() {
    super.initState();
    AssetBundle bundle = rootBundle;

    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'beautiful apps'],
      contentUrl: 'https://flutter.io',
      childDirected: false,
      testDevices: <String>["82E2988F7C0E62124A6239991D6F2B06"], // Android emulators are considered test devices
    );

    BannerAd createBannerAd() {
      return new BannerAd(
        //adUnitId: BannerAd.testAdUnitId,
        adUnitId: "ca-app-pub-9653538784779155/9961202075",
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event $event");
        },
      );
    }
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-9653538784779155~8984243894');
    _bannerAd = createBannerAd();

    _loadAsset(bundle).then((_) {
      setState(() {
        assetsLoaded = true;
        bloc = DogWatchBlocProvider.of(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (assetsLoaded) {
      if (dogRunArea == null) {
        // 本来ここの数値はなんでも良い。その数値が論理的なWidgetの縦横サイズとなる。
        // 指定した数値に合わせてchildrenのnodeがscaleされる。
        // 例えば画像の物理的な横幅が10でWidgetの論理的な横幅が100であれば、1/10でnodeが表示される。
        dogRunArea = new DogRunArea(Size(360.0, 592.0), bloc);
      }
      _bannerAd
      // typically this happens well before the ad is shown
        ..load()
        ..show(
          anchorOffset: 80.0,
          // Banner Position
          anchorType: AnchorType.top,
        );

      bloc.refresh();
      return new Scaffold(
          body: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Expanded(
                flex: 8,
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage("assets/room_basic.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: new Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      new Positioned(
                        child: new SpriteWidget(dogRunArea),
                      ),
                      new Positioned(
                          bottom: 10.0,
                          left: 10.0,
                          child: new StreamBuilder<int>(
                            stream: bloc.affectionStream,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return getParam(
                                    snapshot.data, 'assets/heart.png');
                              } else {
                                return Container();
                              }
                            },
                          )
                      ),
                      new Positioned(
                          bottom: 30.0,
                          left: 10.0,
                          child: new StreamBuilder<int>(
                            stream: bloc.moneyStream,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return getParam(
                                    snapshot.data, 'assets/money.png');
                              } else {
                                return Container();
                              }
                            },
                          )
                      ),
                    ],
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blueGrey,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Container(
                        child: new Center(
                          child: IconButton(
                              icon: Image.asset('assets/ic_conversation.png'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProviderUtil.buildChatScreen()
                                    )
                                );
                              }
                          ),
                        ),
                        width: 100.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.orangeAccent
                        ),
                      ),
                      new Container(
                        child: new Center(
                          child: IconButton(
                              icon: Image.asset('assets/ic_dogfood.png'),
                              onPressed: nagivateToItemSelection
                          ),
                        ),
                        width: 100.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.greenAccent
                        ),
                      ),
                      new Container(
                        child: new Center(
                          child: IconButton(
                              icon: Image.asset('assets/ic_dog_running.png'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DogWalkScreen()
                                    )
                                );
                              }
                          ),
                        ),
                        width: 100.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.blueAccent
                        ),
                      ),
                    ],
                  ),

                )
                ,
              )
            ],
          )
      );
    } else {
      return new Container();
    }
  }

  //Future<List<Widget>> getHearts() async {
  Widget getParam(int value, String iconPath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          iconPath,
          height: 20.0,
          fit: BoxFit.scaleDown,
        ),
        Padding(padding: EdgeInsets.only(left: 10.0)),
        Text(value.toString())
      ],
    );
  }

  void nagivateToItemSelection() async {
    ItemType itemType = await Navigator.push(
      context,
      MaterialPageRoute<ItemType>(
          builder: (context) => ItemSelectScreen()
      ),
    );
    if (itemType != null) {
      dogRunArea.giveItem(itemType);
    }
  }

}

class DogRunArea extends NodeWithSize {
  Dog _dog;
  DogWatchBloc bloc;

  DogRunArea(Size size, DogWatchBloc bloc) : super(size) {
    this.bloc = bloc;

    var left = 40.0; // 20は適当
    var top = size.height * 0.65; // 背景画像のフローリング範囲
    var bottomMargin = 440.0; // 画面外に出ない範囲
    _dog = new Dog(Rect.fromLTWH(left, top, size.width - left * 2, size.height - bottomMargin));
    _dog.scale = 2.0;
    _dog.collisionRadius = 40.0;
    _dog.position = Offset(size.width / 2, top + 45.0); // 位置初期値は適当
    addChild(_dog);
    _dog.startFrameAction();
  }

  void giveItem(ItemType itemType) {
    GameObject _item;
    List<Offset> slideIn = [];
    double duration = 0.0;
    switch (itemType) {
      case ItemType.FOOD:
        _item = DogFood();
        _item.position = Offset(0.0, size.height - 100.0);
        slideIn = [
          Offset(0.0, size.height - 100.0),
          Offset(80.0, size.height - 100.0),
        ];
        duration = 2.0;
        break;
      case ItemType.BALL:
        _item = Ball();
        _item.position = Offset(size.width, size.height - 110.0);
        slideIn = [
          Offset(size.width, size.height - 110.0),
          Offset(size.width - 120.0, size.height - 110.0),
        ];
        duration = 2.0;
        break;
      case ItemType.SKATE:
        _item = Skate();
        _item.position = Offset(size.width, size.height - 100.0);
        slideIn = [
          Offset(size.width, size.height - 100.0),
          Offset(size.width / 2, size.height - 100.0),
        ];
        duration = 2.0;
        break;
      case ItemType.HULAHOOP:
        _item = HulaHoop();
        _item.position = Offset(size.width - 150.0, size.height - 100.0);
        break;
      case ItemType.BONE:
        _item = Bone();
        _item.position = Offset(size.width + 20.0, size.height - 160.0);
        slideIn = [
          _item.position - Offset(30.0, 0.0),
          _item.position - Offset(40.0, -15.0),
          _item.position - Offset(50.0, -30.0),
          _item.position - Offset(60.0, -45.0),
          _item.position - Offset(70.0, -60.0),
        ];
        duration = 0.7;
        break;
      case ItemType.SUNGLASSES:
        _item = Sunglasses();
        _item.position = Offset(150.0, size.height - 150.0);
        break;
      case ItemType.JERKY:
        _item = Jerky();
        _item.position = Offset(180.0, size.height - 100.0);
        break;
    }
    _item.scale = 2.0;
    _item.collisionRadius = 20.0;
    addChild(_item);

    if (slideIn.length > 0) {
      ActionSpline actionSpline = new ActionSpline(
              (pos) {
            _item.position = pos;
          },
          slideIn,
          duration
      );
      //actionSpline.tension = 0.8;
      _item.actions.run(actionSpline);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    var removeChild = <GameObject>[];

    for (var child in children) {
      if (!(child is Dog)) {
        var item = child as GameObject;
        if (_dog.overlapWith(child)) {
          removeChild.add(item);
          _dog.giveItem(item.itemType);
          bloc.addAffection(1);
        }
      }
    }
    removeChild.forEach((child) {
      child.removeFromParent();
    });
  }
}

class Dog extends GameObject {
  Dog(Rect moveArea) : super(_dogSprites['dog_sprites-walk_stay-0.ase'], moveArea);
  ItemType givenItemType;
  bool forceMove = false; // currentDirectionに関係なく自分で強制的に移動するフラグ

  void _changeSprite(SpriteTexture sprite) {
    texture = sprite;
  }

  @override
  void update(double dt) {
    if (forceMove) return;
    super.update(dt);
  }

  @override
  Action frames() {
    if (givenItemType == ItemType.FOOD) {
      return _eatFood();
    }
    if (givenItemType == ItemType.BONE) {
      return _hasBone();
    }
    if (givenItemType == ItemType.JERKY) {
      return _hasJerky();
    }
    if (givenItemType == ItemType.HULAHOOP) {
      return _rollHulaHoop();
    }
    if (givenItemType == ItemType.SUNGLASSES) {
        return _putOnSunGlasses();
    }
    if (givenItemType == ItemType.SKATE) {
        return _skate();
    }
    if (givenItemType == ItemType.BALL) {
      return _bringBall();
    }

    return _walk();
  }

  Action _walk() {
    return ActionSequence(<Action> [
      _walkAsFrameChange('dog_sprites-walk'),
      ActionCallFunction(() {
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _walkAsFrameChange(String prefix) {
    return new ActionRepeat(ActionTween<double>((time) {
        switch (currentDirection) {
          case Direction.Stay:
            _changeSprite(_dogSprites["${prefix}_stay-0.ase"]);
            break;
          case Direction.Up:
          case Direction.Down:
          case Direction.Left:
            if (time >= 0 && time < 0.17) {
              _changeSprite(_dogSprites["${prefix}_left-0.ase"]);
            } else if (time >= 0.17 && time <= 0.37) {
              _changeSprite(_dogSprites["${prefix}_left-1.ase"]);
            } else if (time >= 0.38 && time <= 0.55) {
              _changeSprite(_dogSprites["${prefix}_left-2.ase"]);
            } else {
              _changeSprite(_dogSprites["${prefix}_left-3.ase"]);
            }
            break;
          case Direction.Right:
            if (time >= 0 && time < 0.17) {
              _changeSprite(_dogSprites["${prefix}_right-0.ase"]);
            } else if (time >= 0.17 && time <= 0.37) {
              _changeSprite(_dogSprites["${prefix}_right-1.ase"]);
            } else if (time >= 0.38 && time <= 0.55) {
              _changeSprite(_dogSprites["${prefix}_right-2.ase"]);
            } else {
              _changeSprite(_dogSprites["${prefix}_right-3.ase"]);
            }
            break;
        }
      },
          0.0,
          0.75,
          0.75
      ), Random().nextInt(3) + 2);
  }

  Action _eatFood() {
    return ActionSequence(<Action> [
      new ActionRepeat(ActionTween<double>((time) {
        if (time >= 0 && time < 0.45) {
          _changeSprite(_dogSprites['dog_sprites-food-0.ase']);
        } else {
          _changeSprite(_dogSprites['dog_sprites-food-1.ase']);
        }
      },
          0.0,
          0.9,
          0.9
      ), 5),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _hasBone() {
    return ActionSequence(<Action> [
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-bone-0.ase']);
      }),
      new ActionDelay(0.6),
      new ActionRepeat(
          new ActionTween<double>((time) {
            if (time >= 0 && time < 0.45) {
              _changeSprite(_dogSprites['dog_sprites-bone-1.ase']);
            } else {
              _changeSprite(_dogSprites['dog_sprites-bone-2.ase']);
            }
          },
              0.0,
              0.9,
              0.9
          ),
          4
      ),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-bone-3.ase']);
      }),
      new ActionDelay(0.25),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-bone-4.ase']);
      }),
      new ActionCallFunction(() {
        // この骨は投げる用のもの
        var bone = Bone()
          ..position = position - Offset(10.0, 5.0)
          ..scale = 1.5;
        parent.addChild(bone);
        bone.thrownAway();

        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _hasJerky() {
    return ActionSequence(<Action> [
      new ActionSequence(<Action> [
        new ActionCallFunction(() {
          _changeSprite(_dogSprites['dog_sprites-jerky-0.ase']);
        }),
        new ActionDelay(3.0),
      ]),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _rollHulaHoop() {
    return ActionSequence(<Action> [
      new ActionRepeat(
          new ActionSequence(<Action> [
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-hulahoop-0.ase']);
            }),
            new ActionDelay(0.2),
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-hulahoop-1.ase']);
            }),
            new ActionDelay(0.2),
          ]),
          10
      ),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-hulahoop-2.ase']);
      }),
      new ActionDelay(5.0),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _putOnSunGlasses() {
    return new ActionSequence(<Action> [
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-sunglasses_stay-0.ase']);
      }),
      new ActionDelay(3.0),
      new ActionRepeat(
        ActionSequence(<Action>[
          // itemは保持したまま動き回る
          _walkAsFrameChange('dog_sprites-sunglasses'),
          ActionCallFunction(() {
            _switchDirection();
          })
        ])
      , 10),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      }),
    ]);
  }

  Action _bringBall() {
    return ActionSequence(<Action> [
      new ActionCallFunction(() {
        forceMove = true;
      }),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-ball_bite-0.ase']);
      }),
      new ActionDelay(1.0),
      new ActionGroup(<Action>[
        new ActionTween((newPosition) {
          position = newPosition;
        },
            position,
            Offset(position.dx, movableArea.bottom + 100.0),
            (movableArea.bottom - position.dy) / 50
        ),
        new ActionRepeat(
            ActionSequence(<Action>[
              ActionCallFunction(() {
                _changeSprite(_dogSprites['dog_sprites-ball_bite-1.ase']);
              }),
              ActionDelay(0.3),
              ActionCallFunction(() {
                _changeSprite(_dogSprites['dog_sprites-ball_bite-2.ase']);
              }),
              ActionDelay(0.3),
            ]),
            ((movableArea.bottom + 100.0 - position.dy) ~/ 25)
        )
      ]),
      new ActionCallFunction(() {
        opacity = 0.0;
      }),
      new ActionDelay(1.0),
      // big face
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-big_face_ball-0.ase']);
        scale = 4.0;
        opacity = 1.0;
      }),
      new ActionTween((newPosition) {
        position = newPosition;
      },
          Offset(parent.spriteBox.size.width / 2, movableArea.bottom + 100.0),
          Offset(parent.spriteBox.size.width / 2, movableArea.bottom - 60.0),
        1.5
      ),
      new ActionRepeat(
          ActionSequence(<Action>[
            ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-big_face_ball-0.ase']);
            }),
            ActionDelay(0.5),
            ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-big_face_ball-1.ase']);
            }),
            ActionDelay(0.5),
          ]),
          6
      ),
      new ActionRepeat(
          ActionSequence(<Action>[
            ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-big_face-0.ase']);
            }),
            ActionDelay(0.5),
            ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-big_face-1.ase']);
            }),
            ActionDelay(0.5),
          ]),
          4
      ),
      new ActionTween((newPosition) {
        position = newPosition;
      },
          Offset(parent.spriteBox.size.width / 2, movableArea.bottom - 60.0),
          Offset(parent.spriteBox.size.width / 2, movableArea.bottom + 150.0),
          1.5
      ),
      new ActionDelay(2.0),
      // ここから画面に復帰
      new ActionCallFunction(() {
        opacity = 0.0;
        _changeSprite(_dogSprites['dog_sprites-run_right-0.ase']);
        scale = 2.0;
        currentDirection = Direction.Right;
        position = Offset(50.0, 450.0);
        opacity = 1.0;
        forceMove = false;
      }),
      new ActionRepeat(
          new ActionSequence(<Action>[
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-0.ase']);
            }),
            new ActionDelay(0.2),
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-1.ase']);
            }),
            new ActionDelay(0.2),
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-2.ase']);
            }),
            new ActionDelay(0.2),
          ]),
          3
      ),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  Action _skate() {
    return ActionSequence(<Action> [
      new ActionCallFunction(() {
        forceMove = true;
      }),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-skate-0.ase']);
      }),
      new ActionDelay(2.0),
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-skate-1.ase']);
      }),
      new ActionDelay(1.0),
      new ActionTween((newPosition) {
        position = newPosition;
      },
          position,
          Offset(-10.0, position.dy),
          (position.dx + 10.0) / 200
      ),
      new ActionCallFunction(() {
        opacity = 0.0;
      }),
      new ActionDelay(5.0),
      // ここから画面に復帰
      new ActionCallFunction(() {
        _changeSprite(_dogSprites['dog_sprites-run_right-0.ase']);
        opacity = 1.0;
        currentDirection = Direction.Right;
        position = Offset(50.0, position.dy);
        forceMove = false;
      }),
      new ActionRepeat(
          new ActionSequence(<Action>[
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-0.ase']);
            }),
            new ActionDelay(0.2),
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-1.ase']);
            }),
            new ActionDelay(0.2),
            new ActionCallFunction(() {
              _changeSprite(_dogSprites['dog_sprites-run_right-2.ase']);
            }),
            new ActionDelay(0.2),
          ]),
          3
      ),
      new ActionCallFunction(() {
        givenItemType = null;
        _switchDirection();
        startFrameAction();
      })
    ]);
  }

  void _switchDirection() {
    var nextDirection = Direction.Stay;
    switch (Random().nextInt(5)) {
      case 0:
        nextDirection = Direction.Stay;
        break;
      case 1:
        nextDirection = Direction.Left;
        break;
      case 2:
        nextDirection = Direction.Right;
        break;
      case 3:
        nextDirection = Direction.Up;
        break;
      case 4:
        nextDirection = Direction.Down;
        break;
    }
    switchDirection(nextDirection);
  }

  void giveItem(ItemType itemType) {
    stopFrameAction();
    givenItemType = itemType;
    switchDirection(Direction.Stay);
    startFrameAction();
  }

}

class DogFood extends GameObject {
  DogFood() : super(_itemSprites['item_sprites-food-0.ase']) {
    itemType = ItemType.FOOD;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class Bone extends GameObject {
  Bone() : super(_itemSprites['item_sprites-bone-0.ase']) {
    itemType = ItemType.BONE;
  }
  bool userInteractionEnabled = true;

  void thrownAway() {
    List<Offset> points = [
      position - Offset(20.0, 0.0),
      position - Offset(25.0, 3.0),
      position - Offset(35.0, 5.5),
      position - Offset(47.0, 8.0),
      position - Offset(57.0, 6.0),
      position - Offset(60.0, 5.5),
      position - Offset(65.0, 3.0),
      position - Offset(68.0, 1.5),
    ];
    var boneThrow = ActionSequence([
      new ActionSpline(
              (pos) { position = pos; }, points, 0.8
      ),
      new ActionCallFunction(() {
        removeFromParent();
      })
    ]);
    actions.run(boneThrow);
  }

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class Jerky extends GameObject {
  Jerky() : super(_itemSprites['item_sprites-jerky-0.ase']) {
    itemType = ItemType.JERKY;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class HulaHoop extends GameObject {
  HulaHoop() : super(_itemSprites['item_sprites-hulahoop-0.ase']) {
    itemType = ItemType.HULAHOOP;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class Ball extends GameObject {
  Ball() : super(_itemSprites['item_sprites-ball-0.ase']) {
    itemType = ItemType.BALL;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class Skate extends GameObject {
  Skate() : super(_itemSprites['item_sprites-skate-0.ase']) {
    itemType = ItemType.SKATE;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

class Sunglasses extends GameObject {
  Sunglasses() : super(_itemSprites['item_sprites-sunglasses-0.ase']) {
    itemType = ItemType.SUNGLASSES;
  }
  bool userInteractionEnabled = true;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    return true;
  }
}

// 動くオブジェクト
abstract class GameObject extends Sprite {
  Rect movableArea;
  double collisionRadius = 0.0;
  bool collidable = true;

  Direction currentDirection = Direction.Stay;
  Direction previousDirection;
  double speedBias = 1.0;

  Action currentFrameAction;

  // Itemのみのフィールド
  ItemType itemType;

  GameObject(SpriteTexture texture, [this.movableArea]) : super(texture);

  @override
  update(double dt) {
    // Move the node at a constant speed
    Offset newPosition;
    switch (currentDirection) {
      case Direction.Stay:
        newPosition = position;
        break;
      case Direction.Up:
        newPosition = position + new Offset(0.0, -1.0 * speedBias);
        break;
      case Direction.Down:
        newPosition = position + new Offset(0.0, 1.0 * speedBias);
        break;
      case Direction.Left:
        newPosition = position + new Offset(-1.0 * speedBias, 0.0);
        break;
      case Direction.Right:
        newPosition = position + new Offset(1.0 * speedBias, 0.0);
        break;
    }
    if (movableArea != null && movableArea.contains(newPosition)) {
      position = newPosition;
    } else {
      currentDirection = Direction.Stay;
    }
  }

  void startFrameAction() {
    actions.run(frames(), "frame");
  }

  Action frames() {}

  void stopFrameAction() {
    actions.stopWithTag("frame");
  }

  void switchDirection(Direction newDirection) {
    previousDirection = currentDirection;
    currentDirection = newDirection;
  }

  void changeSpeedBias(double bias) {
    speedBias = bias;
  }

  bool collidingWith(GameObject obj) {
    return (GameMath.distanceBetweenPoints(position, obj.position)
        < collisionRadius + obj.collisionRadius);
  }

  bool overlapWith(GameObject obj) {
    return (GameMath.distanceBetweenPoints(position, obj.position) + collisionRadius / 2 + obj.collisionRadius
        < collisionRadius + obj.collisionRadius);
  }
}

enum Direction {
  Left, Right, Down, Up, Stay
}
