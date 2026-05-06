// FIX: Added missing import — Offset lives in dart:ui, re-exported by flutter/material.dart.
// Without this import `Offset(...)` was an unresolved symbol → compile error.
import 'package:flutter/material.dart';
import 'package:zen_garden_jam_flutter/models/puzzle_element.dart';

class Level {
  final int levelNumber;
  final String title;
  final String description;
  final int targetPetals;
  final int timeLimit;
  final List<PuzzleElement> elements;
  final int maxMoves;
  final String season;

  Level({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.targetPetals,
    required this.timeLimit,
    required this.elements,
    required this.maxMoves,
    required this.season,
  });

  factory Level.generateLevel(int levelNumber) {
    final difficulty = (levelNumber / 10).ceil();
    final elementCount = 5 + difficulty;
    final maxMoves = 20 + (difficulty * 2);

    final elements = <PuzzleElement>[];
    for (int i = 0; i < elementCount; i++) {
      elements.add(
        PuzzleElement(
          id: 'element_$i',
          type: ElementType.values[i % ElementType.values.length],
          color: ElementColor.values[i % ElementColor.values.length],
          initialPosition: Offset(
            (i % 3) * 100.0 + 50,
            (i ~/ 3) * 100.0 + 100,
          ),
        ),
      );
    }

    return Level(
      levelNumber: levelNumber,
      title: 'Garden Level $levelNumber',
      description: 'Restore the ${_getSeason(levelNumber)} garden',
      targetPetals: 50 + (levelNumber * 5),
      timeLimit: 300 - (difficulty * 10),
      elements: elements,
      maxMoves: maxMoves,
      season: _getSeason(levelNumber),
    );
  }

  static String _getSeason(int levelNumber) {
    const seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
    return seasons[((levelNumber - 1) ~/ 50) % 4];
  }

  bool isComplete() {
    return elements.every((element) => element.isMatched);
  }

  int calculateScore(int movesUsed, int timeRemaining) {
    int score = targetPetals;
    if (movesUsed < maxMoves) score += (maxMoves - movesUsed) * 5;
    if (timeLimit > 0 && timeRemaining > 0) score += (timeRemaining ~/ 10);
    return score;
  }
}
