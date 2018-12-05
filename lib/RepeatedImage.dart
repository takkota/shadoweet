import 'package:spritewidget/spritewidget.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class RepeatedImage extends Node {
  Sprite _sprite0;
  Sprite _sprite1;

  RepeatedImage(ui.Image image, [ui.BlendMode mode]) {
    _sprite0 = new Sprite.fromImage(image);
    _sprite0.size = new Size(1024.0, 1024.0);
    _sprite0.pivot = Offset.zero;
    _sprite1 = new Sprite.fromImage(image);
    _sprite1.size = new Size(1024.0, 1024.0);
    _sprite1.pivot = Offset.zero;
    _sprite1.position = new Offset(-1024.0, 0.0);

    if (mode != null) {
      _sprite0.transferMode = mode;
      _sprite1.transferMode = mode;
    }

    addChild(_sprite0);
    addChild(_sprite1);
  }

  void move(double dx) {
    double xPos = (position.dx - dx) % 1024.0;
    position = new Offset(xPos, 0.0);
  }
}