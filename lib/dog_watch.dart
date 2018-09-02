import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';

ImageMap _images;
SpriteSheet _sprites;

class DogWatchScreen extends StatefulWidget {
  @override
  DogWatchScreenState createState() => new DogWatchScreenState();
}

class DogWatchScreenState extends State<DogWatchScreen> with TickerProviderStateMixin {
  DogRunArea dogRunArea;
  bool assetsLoaded = false;

  Future<Null> _loadAsset(AssetBundle bundle) async {
    _images = new ImageMap(bundle);
    await _images.load(<String>[
      'assets/dog_run_sprites.png',
      'assets/food.png',
    ]);
    String json = await DefaultAssetBundle.of(context).loadString('assets/dog_run_sprites.json');
    _sprites = new SpriteSheet(_images['assets/dog_run_sprites.png'], json);
  }

  @override
  void initState() {
    super.initState();
    AssetBundle bundle = rootBundle;

    _loadAsset(bundle).then((_) {
      setState(() {
        assetsLoaded = true;
        Size size = MediaQuery.of(context).size;
        dogRunArea = new DogRunArea(size);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if (assetsLoaded) {
      return new Scaffold(
        body: new Stack(
            children: <Widget>[
              new Positioned(
                child: new SpriteWidget(dogRunArea),
              ),
              new Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  height: 40.0,
                  width: 40.0,
                  child: new Container(
                    child: new Center(
                      child: IconButton(
                          icon: Icon(Icons.access_alarm),
                          onPressed: () {
                            dogRunArea.feed(true);
                          }
                      ),
                    ),
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                  )
              ),
              new Positioned(
                  bottom: 10.0,
                  right: 60.0,
                  height: 40.0,
                  width: 40.0,
                  child: new Container(
                    child: new Center(
                      child: IconButton(
                          icon: Icon(Icons.access_alarm),
                          onPressed: () {
                            dogRunArea.feed(true);
                          }
                      ),
                    ),
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                  )
              ),
              new Positioned(
                  bottom: 10.0,
                  right: 35.0,
                  height: 120.0,
                  width: 40.0,
                  child: new Container(
                    child: new Center(
                      child: IconButton(
                          icon: Icon(Icons.access_alarm),
                          onPressed: () {
                            dogRunArea.feed(true);
                          }
                      ),
                    ),
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                  )
              ),
            ]
        ),

        //body: new Stack(
        //  children: <Widget>[
        //    new Expanded(
        //        child: new SpriteWidget(dogRunArea)
        //    ),
        //    new Positioned(
        //        bottom: 10.0,
        //        right: 40.0,
        //        height: 30.0,
        //        width: 30.0,
        //        child: new Container(
        //          child: new Center(
        //            child: IconButton(
        //                icon: Icon(Icons.access_alarm),
        //                onPressed: () {
        //                  dogRunArea.feed(true);
        //                }
        //            ),
        //          ),
        //          decoration: new BoxDecoration(
        //              shape: BoxShape.circle,
        //              color: Colors.white
        //          ),
        //        )
        //    ),
        //    new Positioned(
        //        bottom: 30.0,
        //        right: 25.0,
        //        height: 30.0,
        //        width: 30.0,
        //        child: new Container(
        //          child: new Center(
        //            child: IconButton(
        //                icon: Icon(Icons.access_alarm),
        //                onPressed: () {
        //                  dogRunArea.feed(true);
        //                }
        //            ),
        //          ),
        //          decoration: new BoxDecoration(
        //              shape: BoxShape.circle,
        //              color: Colors.white
        //          ),
        //        )
        //    ),
        //  ],
        //),
      );
    } else {
      return new Scaffold(
        body: new Column(
            children: <Widget>[
              new Center(
                child: new Text("ロード中"),
              )
            ]
        ),
      );
    }
  }
}

class DogRunArea extends NodeWithSize {
  GradientNode _background;
  Dog _dog;
  GameObject _food;

  DogRunArea(Size size) : super(size) {
    // Start by adding a background.
    _background = new GradientNode(
      size,
      const Color(0xff5ebbd5),
      const Color(0xff4aaafb),
    );
    addChild(_background);

    OnSpriteMoveListener onSpriteMoveListener = new OnSpriteMoveListener(
      onSpriteMoveEnd: (offset) {
        _dog.moveAtRandom();
      },
    );
    var widthMargin = 20.0 * window.devicePixelRatio;
    var heightMargin = 55.0 * window.devicePixelRatio;
    _dog = new Dog(_sprites['dog_run_1.png'], onSpriteMoveListener, Rect.fromLTWH(widthMargin, heightMargin, size.width - widthMargin * 2, size.height - heightMargin * 2));
    _dog.scale = 0.2;
    _dog.collisionRadius = 20.0 * window.devicePixelRatio;
    _dog.position = Offset(size.width / 2, size.height / 2);
    addChild(_dog);
    _dog.moveAtRandom();
  }

  void feed(bool test) {
    _food = new DogFood(new SpriteTexture(_images['assets/food.png']));
    _food.scale = 0.1;
    _food.collisionRadius = 10.0 * window.devicePixelRatio;
    _food.position = Offset(size.width / 2, 0.0);
    List<Offset> points = [
      _food.position,
      _food.position + Offset(0.0, size.height / 8),
      _food.position + Offset(0.0, size.height / 4),
      _food.position + Offset(0.0, size.height / 2),
    ];
    addChild(_food);
    ActionSpline actionSpline = new ActionSpline(
        (pos) {
          _food.position = pos;
        },
        points,
        4.0
    );
    actionSpline.tension = 0.8;
    _food.actions.run(actionSpline);
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
    if (children.contains(_dog) && children.contains(_food)) {
      if (_dog.overlapWith(_food)) {
        _food.removeFromParent();
        _dog.eatFood();
      }
    }
  }
}

class GradientNode extends NodeWithSize {
  GradientNode(Size size, this.colorTop, this.colorBottom) : super(size);
  Color colorTop;
  Color colorBottom;

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);

    Rect rect = Offset.zero & size;
    Paint gradientPaint = new Paint()..shader = new LinearGradient(
        begin: FractionalOffset.topLeft,
        end: FractionalOffset.bottomLeft,
        colors: <Color>[colorTop, colorBottom],
        stops: <double>[0.0, 1.0]
    ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
  }
}

class Dog extends GameObject {
  Dog(SpriteTexture texture, OnSpriteMoveListener onSpriteMoveListener, Rect moveArea) : super(texture, onSpriteMoveListener, moveArea);
  bool eating = false;

  void _changeSprite(SpriteTexture sprite) {
    texture = sprite;
  }

  void startMoveFrames() {
    ActionRepeatForever frames = new ActionRepeatForever(
        new ActionTween<double>((time) {
          switch (currentDirection) {
            case Direction.Stay:
              _changeSprite(_sprites['dog_run_1.png']);
              break;
            case Direction.Up:
            case Direction.Down:
            case Direction.Right:
            case Direction.Left:
              if (time >= 0 && time < 0.2) {
                _changeSprite(_sprites['dog_run_1.png']);
              } else if (time >= 0.2 && time >= 0.4) {
                _changeSprite(_sprites['dog_run_2.png']);
              } else {
                _changeSprite(_sprites['dog_run_3.png']);
              }
          }
        },
            0.0,
            0.6,
            0.6
        )
    );
    actions.run(frames, "moveFrames");
  }

  void stopMoveFrames() {
    actions.stopWithTag("moveFrames");
  }

  void move(int randomVal) {
    double distance = Random().nextInt(100).toDouble() + 100.0;
    double duration = Random().nextInt(3).toDouble() + 2.0;

    switch (randomVal) {
      case 0:
        moveLeft(distance, duration);
        break;
      case 1:
        moveRight(distance, duration);
        break;
      case 2:
        moveUp(distance, duration);
        break;
      case 3:
        moveDown(distance, duration);
        break;
      case 4:
        stay(duration, () {
          moveAtRandom();
        });
        break;
    }
  }

  void moveAtRandom() {
    startMoveFrames();
    move(Random().nextInt(5));
  }

  void eatFood() {
    stopMoveFrames();
  }
}

class DogFood extends GameObject {
  DogFood(SpriteTexture texture) : super(texture);
}

// 動くオブジェクト
abstract class GameObject extends Sprite {
  OnSpriteMoveListener _onSpriteMoveListener;
  ActionSequence currentAction;
  Rect movableArea;
  double collisionRadius = 0.0;
  bool collidable = true;

  Direction currentDirection;

  GameObject(SpriteTexture texture, [this._onSpriteMoveListener, this.movableArea]) : super(texture);

  void _move(double horizontalDist, double verticalDist, double duration) {
    ActionSequence moveAction = new ActionSequence([
      new ActionCallFunction(() {
        if (_onSpriteMoveListener.onSpriteMoveStart != null) {
          _onSpriteMoveListener.onSpriteMoveStart(position);
        }
      }),
      new ActionTween<Offset>(
          (pos) {
            if (movableArea != null) {
              if (movableArea.contains(pos)) {
                position = pos;
              } else {
                actions.stopWithTag("move");
                _onSpriteMoveListener.onSpriteMoveEnd(position);
                return;
              }
            }
            if (_onSpriteMoveListener.onSpriteMoveProgress != null) {
              _onSpriteMoveListener.onSpriteMoveProgress(position);
            }
          },
          position,
          position.translate(horizontalDist, verticalDist),
          duration.toDouble()
      ),
      new ActionCallFunction(() {
        if (_onSpriteMoveListener.onSpriteMoveEnd != null) {
          _onSpriteMoveListener.onSpriteMoveEnd(position);
        }
      })
    ]);
    actions.run(moveAction, "move");
  }

  void moveLeft(double distance, double duration) {
    currentDirection = Direction.Left;
    distance = -distance;
    _move(distance, 0.0, duration);
  }

  void moveRight(double distance, double duration) {
    currentDirection = Direction.Right;
    _move(distance, 0.0, duration);
  }

  void moveUp(double distance, double duration) {
    currentDirection = Direction.Up;
    _move(0.0, -distance, duration);
  }

  void moveDown(double distance, double duration) {
    currentDirection = Direction.Down;
    _move(0.0, distance, duration);
  }

  void stay(double duration, Function callback) {
    currentDirection = Direction.Stay;
    actions.run(new ActionSequence(<Action>[
      new ActionCallFunction(() {
        actions.stopWithTag("move");
        if (_onSpriteMoveListener.onSpriteMovePause!= null) {
          _onSpriteMoveListener?.onSpriteMovePause(position);
        }
      }),
      new ActionDelay(duration),
      new ActionCallFunction(callback)
    ]));
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

typedef void OnSpriteMove(Offset offset);
class OnSpriteMoveListener {
  final OnSpriteMove onSpriteMoveStart;
  final OnSpriteMove onSpriteMoveProgress;
  final OnSpriteMove onSpriteMovePause;
  final OnSpriteMove onSpriteMoveEnd;

  const OnSpriteMoveListener({
    this.onSpriteMoveStart,
    this.onSpriteMoveProgress,
    this.onSpriteMovePause,
    this.onSpriteMoveEnd,
  });
}

enum Direction {
  Left, Right, Down, Up, Stay
}
