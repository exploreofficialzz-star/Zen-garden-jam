import 'package:flutter/material.dart';

enum ElementType {
  cherryBlossom,
  lotus,
  lantern,
  bamboo,
}

enum ElementColor {
  pink,
  white,
  green,
  gray,
}

class PuzzleElement {
  final String id;
  final ElementType type;
  final ElementColor color;
  late Offset position;
  late bool isSelected;
  late bool isMatched;
  late int rotationAngle;

  PuzzleElement({
    required this.id,
    required this.type,
    required this.color,
    required Offset initialPosition,
  }) {
    position = initialPosition;
    isSelected = false;
    isMatched = false;
    rotationAngle = 0;
  }

  void select() {
    isSelected = true;
  }

  void deselect() {
    isSelected = false;
  }

  void markAsMatched() {
    isMatched = true;
  }

  void rotate(int angle) {
    rotationAngle = (rotationAngle + angle) % 360;
  }

  void moveTo(Offset newPosition) {
    position = newPosition;
  }

  Color getColorValue() {
    switch (color) {
      case ElementColor.pink:
        return Colors.pink[300]!;
      case ElementColor.white:
        return Colors.white;
      case ElementColor.green:
        return Colors.green[400]!;
      case ElementColor.gray:
        return Colors.grey[400]!;
    }
  }

  String getAssetPath() {
    switch (type) {
      case ElementType.cherryBlossom:
        return 'assets/images/cherry_blossom_branch.png';
      case ElementType.lotus:
        return 'assets/images/lotus_flower.png';
      case ElementType.lantern:
        return 'assets/images/stone_lantern.png';
      case ElementType.bamboo:
        return 'assets/images/bonsai_tree.png';
    }
  }
}
