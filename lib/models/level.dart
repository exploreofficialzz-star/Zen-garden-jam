import 'package:zen_garden_jam_flutter/models/puzzle_element.dart';

class Level {
  final int levelNumber;
  final String title;
  final String description;
  final int targetPetals;
  final int timeLimit; // in seconds, 0 = no limit
  final List<PuzzleElement> elements;
  final int maxMoves;
  final String season; // spring, summer, autumn, winter

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
    // Generate levels dynamically based on level number
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

    final season = _getSeason(levelNumber);

    return Level(
      levelNumber: levelNumber,
      title: 'Garden Level $levelNumber',
      description: 'Restore the $season garden by clearing all elements',
      targetPetals: 50 + (levelNumber * 5),
      timeLimit: 300 - (difficulty * 10), // Decreases with difficulty
      elements: elements,
      maxMoves: maxMoves,
      season: season,
    );
  }

  static String _getSeason(int levelNumber) {
    final seasonIndex = ((levelNumber - 1) ~/ 50) % 4;
    const seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
    return seasons[seasonIndex];
  }

  bool isComplete() {
    return elements.every((element) => element.isMatched);
  }

  int calculateScore(int movesUsed, int timeRemaining) {
    int score = targetPetals;
    
    // Bonus for using fewer moves
    if (movesUsed < maxMoves) {
      score += (maxMoves - movesUsed) * 5;
    }

    // Bonus for time remaining
    if (timeLimit > 0 && timeRemaining > 0) {
      score += (timeRemaining ~/ 10);
    }

    return score;
  }
}
