import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zen_garden_jam_flutter/models/level.dart';
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';
import 'package:zen_garden_jam_flutter/services/ad_manager.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Level currentLevel;
  late int movesUsed;
  late int timeRemaining;
  late AnimationController _timerController;
  late AnimationController _celebrationController;
  bool levelComplete = false;

  @override
  void initState() {
    super.initState();
    final gameState = context.read<GameState>();
    currentLevel = Level.generateLevel(gameState.currentLevel);
    movesUsed = 0;
    timeRemaining = currentLevel.timeLimit;

    _timerController = AnimationController(
      duration: Duration(seconds: currentLevel.timeLimit),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (currentLevel.timeLimit > 0) {
      _timerController.forward();
      _timerController.addListener(() {
        setState(() {
          timeRemaining = (currentLevel.timeLimit *
                  (1 - _timerController.value))
              .toInt();
        });
      });
    }

    AdManager().loadInterstitialAd();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onElementTapped(int index) {
    if (levelComplete) return;

    setState(() {
      final element = currentLevel.elements[index];
      if (!element.isMatched) {
        element.select();
        movesUsed++;

        // Simulate matching logic
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              element.markAsMatched();
            });

            // Check if level is complete
            if (currentLevel.isComplete()) {
              _completeLevel();
            }
          }
        });
      }
    });
  }

  void _completeLevel() {
    levelComplete = true;
    _celebrationController.forward();

    final score = currentLevel.calculateScore(movesUsed, timeRemaining);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.read<GameState>().completeLevel(score);
        
        // Show interstitial ad every 3 levels
        if (context.read<GameState>().currentLevel % 3 == 0) {
          AdManager().showInterstitialAd();
        }

        _showLevelCompleteDialog(score);
      }
    });
  }

  void _showLevelCompleteDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF9CAF88),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Moves: $movesUsed / ${currentLevel.maxMoves}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: Text('Level ${currentLevel.levelNumber}'),
        backgroundColor: const Color(0xFF9CAF88),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Level Info
          Container(
            color: const Color(0xFF9CAF88),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Moves',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '$movesUsed / ${currentLevel.maxMoves}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (currentLevel.timeLimit > 0)
                  Column(
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${(timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                Column(
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      currentLevel.targetPetals.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Game Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: currentLevel.elements.length,
                itemBuilder: (context, index) {
                  final element = currentLevel.elements[index];
                  return GestureDetector(
                    onTap: () => _onElementTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: element.isMatched
                            ? Colors.grey[300]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: element.isSelected
                              ? const Color(0xFF9CAF88)
                              : Colors.grey[300]!,
                          width: element.isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: element.isMatched
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF9CAF88), size: 32)
                          : Image.asset(
                              element.getAssetPath(),
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        movesUsed++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CAF88),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Undo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show rewarded ad for hint
                      AdManager().showRewardedAd((reward) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hint revealed!')),
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF9CAF88),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Hint',
                      style: TextStyle(color: Color(0xFF9CAF88)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
