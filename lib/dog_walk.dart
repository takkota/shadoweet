import 'package:flutter/material.dart';
import 'package:shadoweet/RepeatedImage.dart';
import 'package:shadoweet/urility/SharedPreferencesHelper.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';

ImageMap _images;
SpriteSheet _dogSprites;
SpriteSheet _enemySprites;

class DogWalkScreen extends StatefulWidget {

  @override
  DogWalkScreenState createState() => new DogWalkScreenState();
}

class DogWalkScreenState extends State<DogWalkScreen> with TickerProviderStateMixin {
  DogWalkArea dogWalkArea;
  bool assetsLoaded = false;

  Future<Null> _loadAsset(AssetBundle bundle) async {
    _images = new ImageMap(bundle);
    await _images.load(<String>[
      'assets/field.png',
      'assets/dog_sprites.png',
      'assets/enemy_sprites.png',
      'assets/money.png',
      'assets/start.png',
      'assets/end.png',
    ]);
    String json = await DefaultAssetBundle.of(context).loadString('assets/dog_sprites.json');
    _dogSprites = new SpriteSheet(_images['assets/dog_sprites.png'], json);
    String enemyJson = await DefaultAssetBundle.of(context).loadString('assets/enemy_sprites.json');
    _enemySprites = new SpriteSheet(_images['assets/enemy_sprites.png'], enemyJson);
  }

  @override
  void initState() {
    super.initState();
    AssetBundle bundle = rootBundle;

    _loadAsset(bundle).then((_) {
      setState(() {
        assetsLoaded = true;

        Size size = MediaQuery.of(context).size;
        dogWalkArea = new DogWalkArea(size, context);

        dogWalkArea.startGame();
        Timer(Duration(seconds: 60), () {
          dogWalkArea.finishGame();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (assetsLoaded) {
      return new Scaffold(
          body: new SpriteWidget(dogWalkArea),
      );
    } else {
      return new Scaffold(
          body: new Column(
              children: <Widget>[
                new Center(
                  child: new Text("ロード中"),
                )
              ]
          )
      );
    }
  }
}

class DogWalkArea extends NodeWithSize {
  Dog _dog;
  RepeatedImage _background;
  Rect _gameArea;
  VirtualJoystick _joystick;
  bool _pause = true;
  BuildContext context;

  DogWalkArea(Size size, BuildContext context) : super(size) {
    this.context = context;

    _gameArea = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    // background
    _background = new RepeatedImage(_images["assets/field.png"]);
    addChild(_background);

    var left = 40.0; // 40は適当
    var top = size.height * 0.4;
    _dog = new Dog(_dogSprites['dog_sprites-walk_right-1.ase'], Rect.fromLTWH(left, top, size.width - left * 2, size.height - 300));
    _dog.scale = 2.0;
    _dog.collisionRadius = 40.0;
    _dog.position = Offset(size.width / 4, size.height / 2); // 位置初期値は適当
    addChild(_dog);
    _dog.startFrameAction();

    _joystick = new VirtualJoystick();
    _joystick.position = Offset(size.width / 2, size.height);
    addChild(_joystick);

  }

  void startGame() {
    final image = Sprite.fromImage(_images['assets/start.png']);
    image.scale = 1.5;
    image.position = Offset(size.width, size.height / 2);
    addChild(image);

    List<Offset> points = [
      image.position,
      Offset(size.width / 2, image.position.dy),
      Offset(0.0, image.position.dy),
    ];
    final action = ActionSequence([
      ActionSpline((offset){
        image.position = offset;
      },
          points,
          2.0
      ),
      ActionCallFunction(() {
        image.removeFromParent();
        // ここから操作可能
        _pause = false;
        startAddingObjects();
      })
    ]);

    image.actions.run(action);
  }

  void finishGame() {
    // 操作不可
    _pause = true;
    final image = Sprite.fromImage(_images['assets/end.png']);
    image.scale = 1.5;
    image.position = Offset(size.width, size.height / 2);
    addChild(image);

    List<Offset> points = [
      image.position,
      Offset(size.width / 2, image.position.dy),
      Offset(0.0, image.position.dy),
    ];
    final action = ActionSequence([
      ActionSpline((offset){
        image.position = offset;
      },
          points,
          2.0
      ),
      ActionCallFunction(() {
        image.removeFromParent();
        // 画面遷移
        Navigator.pop(context);
      })
    ]);

    image.actions.run(action);
  }

  void startAddingObjects() async {
    while (!_pause) {
      final objectCount = Random().nextInt(5) + 1;
      for (var i = 0; i < objectCount; i++) {
        GameObject object;
        final randomVal = Random().nextInt(100);
        if (randomVal < 10) {
          final randomHeight = size.height - (Random().nextInt(300) + 100);
          object = Money()
            ..scale=0.2
            ..position=Offset(size.width - 10.0, randomHeight);
        } else if (randomVal < 50){
          final randomWidth= Random().nextInt(300) + 200;
          object = Cat()
            ..scale=2.0
            ..position=Offset(randomWidth - 10.0, size.height - 30.0);
          object.startFrameAction();
        } else {
          final randomHeight = size.height - Random().nextInt(400) + 10;
          object = Husky()
            ..scale=2.0
            ..position=Offset(size.width - 10.0, randomHeight);
          object.startFrameAction();
        }
        addChild(object);
      }

      final wait = Random().nextInt(1) + 1;
      await Future.delayed(Duration(seconds: wait));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_pause) return;
    // 背景動かす
    if (!_pause) {
      _background.move(100 * dt);

      for (int i = children.length - 1; i >= 0; i--) {
        Node object = children[i];
        if (object is GameObject) {
          if (!_gameArea.contains(object.position)) {
            // 画面外に出たらremove
            object.removeFromParent();
          }
          if (_dog.overlapWith(object)) {
            object.onCollideWithDog();
            if (object.damageable) {
              finishGame();
            }
          }
        }
      }

      _dog.applyThrust(_joystick.value);
    }
  }
}

class Dog extends GameObject {
  Dog(SpriteTexture texture, Rect moveArea) : super(texture, moveArea);

  DogAction currentAction = DogAction.WALK;

  void _changeSprite(SpriteTexture sprite) {
    texture = sprite;
  }

  @override
  Action frames() {
    return new ActionRepeatForever(ActionTween<double>((time) {
      if (time >= 0 && time < 0.17) {
        _changeSprite(_dogSprites['dog_sprites-walk_right-0.ase']);
      } else if (time >= 0.17 && time <= 0.37) {
        _changeSprite(_dogSprites['dog_sprites-walk_right-1.ase']);
      } else if (time >= 0.38 && time <= 0.55) {
        _changeSprite(_dogSprites['dog_sprites-walk_right-2.ase']);
      } else {
        _changeSprite(_dogSprites['dog_sprites-walk_right-3.ase']);
      }
    },
        0.0,
        0.75,
        0.75
    ));
  }

  void applyThrust(Offset joystickValue) {
    Offset oldPos = position;
    var targetX = position.dx + joystickValue.dx * 10.0;
    if (targetX <= movableArea.left) {
      targetX = movableArea.left;
    } else if (targetX >= movableArea.right) {
      targetX = movableArea.right;
    }
    var targetY = position.dy + joystickValue.dy * 10.0;
    if (targetY >= movableArea.bottom) {
      targetY = movableArea.bottom;
    } else if (targetY <= movableArea.top) {
      targetY = movableArea.top;
    }
    Offset target = Offset(targetX, targetY);
    double filterFactor = 0.3;

    final moveTo = new Offset(
        GameMath.filter(oldPos.dx, target.dx, filterFactor),
        GameMath.filter(oldPos.dy, target.dy, filterFactor));

    if (movableArea.contains(moveTo)) {
      position = moveTo;
    }
  }
}

class Money extends GameObject {
  Money() : super(SpriteTexture(_images['assets/money.png']));

  @override
  void onCollideWithDog() {
    SharedPreferencesHelper.countUpMoney(5);
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    double xPos = (position.dx - dt * 100);
    position = new Offset(xPos, position.dy);
  }
}

class Cat extends GameObject {
  Cat() : super(_enemySprites['enemy_sprites-cat-0.ase']);
  bool damageable = true;

  @override
  void onCollideWithDog() {
    removeFromParent();
  }

  void _changeSprite(SpriteTexture sprite) {
    texture = sprite;
  }

  @override
  Action frames() {
    return new ActionRepeatForever(ActionTween<double>((time) {
      if (time >= 0 && time < 0.17) {
        _changeSprite(_enemySprites['enemy_sprites-cat-0.ase']);
      } else if (time >= 0.17 && time <= 0.37) {
        _changeSprite(_enemySprites['enemy_sprites-cat-1.ase']);
      } else if (time >= 0.38 && time <= 0.55) {
        _changeSprite(_enemySprites['enemy_sprites-cat-2.ase']);
      } else {
        _changeSprite(_enemySprites['enemy_sprites-cat-1.ase']);
      }
    },
        0.0,
        0.75,
        0.75
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final randomY = Random().nextInt(70);
    final randomX = Random().nextInt(70);
    double yPos = (position.dy - dt * (80 + randomY));
    double xPos = (position.dx - dt * (110 + randomX));
    position = new Offset(xPos, yPos);
  }
}

class Husky extends GameObject {
  Husky() : super(_enemySprites['enemy_sprites-husky-0.ase']);
  bool damageable = true;

  @override
  void onCollideWithDog() {
    removeFromParent();
  }

  void _changeSprite(SpriteTexture sprite) {
    texture = sprite;
  }

  @override
  Action frames() {
    return new ActionRepeatForever(ActionTween<double>((time) {
      if (time >= 0 && time < 0.17) {
        _changeSprite(_enemySprites['enemy_sprites-husky-0.ase']);
      } else if (time >= 0.17 && time <= 0.37) {
        _changeSprite(_enemySprites['enemy_sprites-husky-1.ase']);
      } else if (time >= 0.38 && time <= 0.55) {
        _changeSprite(_enemySprites['enemy_sprites-husky-2.ase']);
      } else {
        _changeSprite(_enemySprites['enemy_sprites-husky-1.ase']);
      }
    },
        0.0,
        0.75,
        0.75
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final randomX = Random().nextInt(70);
    double yPos = (position.dy + dt * 10);
    double xPos = (position.dx - dt * (110 + randomX));
    position = new Offset(xPos, yPos);
  }
}

// 動くオブジェクト
abstract class GameObject extends Sprite {
  Rect movableArea;
  double collisionRadius = 0.0;
  bool collidable = true;
  bool damageable = false;

  Action currentFrameAction;

  GameObject(SpriteTexture texture, [this.movableArea]) : super(texture);

  void startFrameAction() {
    actions.run(frames(), "frame");
  }

  Action frames() {}

  void stopFrameAction() {
    actions.stopWithTag("frame");
  }

  bool collidingWith(GameObject obj) {
    return (GameMath.distanceBetweenPoints(position, obj.position)
        < collisionRadius + obj.collisionRadius);
  }

  bool overlapWith(GameObject obj) {
    return (GameMath.distanceBetweenPoints(position, obj.position) + collisionRadius / 2 + obj.collisionRadius
        < collisionRadius + obj.collisionRadius);
  }

  void onCollideWithDog() {}
}

enum DogAction {
  WALK, FOOD, BONE
}
