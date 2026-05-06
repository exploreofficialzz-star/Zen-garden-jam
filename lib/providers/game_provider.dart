import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  // FIX: Changed from `late SharedPreferences` to nullable.
  // Previously any widget reading state before initialize() completed would
  // throw LateInitializationError. Now all getters return safe defaults
  // until _prefs is ready.
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  int _currentLevel = 1;
  int _totalPetals = 0;
  int _bonsaiGrowthStage = 0;
  int _dailyStreak = 0;
  DateTime? _lastPlayDate;

  Map<String, int> _gardenRestorationProgress = {
    'bridge': 0,
    'pond': 0,
    'lantern': 0,
    'flowers': 0,
  };

  int get currentLevel => _currentLevel;
  int get totalPetals => _totalPetals;
  int get bonsaiGrowthStage => _bonsaiGrowthStage;
  int get dailyStreak => _dailyStreak;
  bool get isInitialized => _isInitialized;
  Map<String, int> get gardenRestorationProgress => _gardenRestorationProgress;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGameState();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadGameState() {
    final p = _prefs;
    if (p == null) return;

    _currentLevel = p.getInt('current_level') ?? 1;
    _totalPetals = p.getInt('total_petals') ?? 0;
    _bonsaiGrowthStage = p.getInt('bonsai_growth') ?? 0;
    _dailyStreak = p.getInt('daily_streak') ?? 0;

    final lastPlayDateStr = p.getString('last_play_date');
    if (lastPlayDateStr != null && lastPlayDateStr.isNotEmpty) {
      try {
        _lastPlayDate = DateTime.parse(lastPlayDateStr);
        _checkDailyStreak();
      } catch (_) {
        _lastPlayDate = null;
      }
    }
  }

  void _checkDailyStreak() {
    if (_lastPlayDate != null) {
      final today = DateTime.now();
      final difference = today.difference(_lastPlayDate!).inDays;
      if (difference == 1) {
        _dailyStreak++;
      } else if (difference > 1) {
        _dailyStreak = 1;
      }
    }
  }

  void completeLevel(int petalsEarned) {
    _currentLevel++;
    _totalPetals += petalsEarned;
    _bonsaiGrowthStage += petalsEarned ~/ 10;
    _lastPlayDate = DateTime.now();
    _saveGameState();
    notifyListeners();
  }

  void addPetals(int amount) {
    _totalPetals += amount;
    _bonsaiGrowthStage += amount ~/ 10;
    _saveGameState();
    notifyListeners();
  }

  void updateGardenRestoration(String element, int progress) {
    _gardenRestorationProgress[element] = progress;
    _saveGameState();
    notifyListeners();
  }

  void _saveGameState() {
    final p = _prefs;
    if (p == null) return;
    p.setInt('current_level', _currentLevel);
    p.setInt('total_petals', _totalPetals);
    p.setInt('bonsai_growth', _bonsaiGrowthStage);
    p.setInt('daily_streak', _dailyStreak);
    p.setString('last_play_date', _lastPlayDate?.toIso8601String() ?? '');
  }

  void resetGame() {
    _currentLevel = 1;
    _totalPetals = 0;
    _bonsaiGrowthStage = 0;
    _dailyStreak = 0;
    _lastPlayDate = null;
    _gardenRestorationProgress = {
      'bridge': 0,
      'pond': 0,
      'lantern': 0,
      'flowers': 0,
    };
    _saveGameState();
    notifyListeners();
  }
}
