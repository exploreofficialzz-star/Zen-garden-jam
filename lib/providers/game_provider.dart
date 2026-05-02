import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Game progress
  int _currentLevel = 1;
  int _totalPetals = 0;
  int _bonsaiGrowthStage = 0;
  int _dailyStreak = 0;
  DateTime? _lastPlayDate;
  
  // Meta progression
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
  Map<String, int> get gardenRestorationProgress => _gardenRestorationProgress;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGameState();
  }

  void _loadGameState() {
    _currentLevel = _prefs.getInt('current_level') ?? 1;
    _totalPetals = _prefs.getInt('total_petals') ?? 0;
    _bonsaiGrowthStage = _prefs.getInt('bonsai_growth') ?? 0;
    _dailyStreak = _prefs.getInt('daily_streak') ?? 0;
    
    final lastPlayDateStr = _prefs.getString('last_play_date');
    if (lastPlayDateStr != null) {
      _lastPlayDate = DateTime.parse(lastPlayDateStr);
      _checkDailyStreak();
    }

    final gardenData = _prefs.getString('garden_restoration');
    if (gardenData != null) {
      // Parse garden data if needed
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
    _prefs.setInt('current_level', _currentLevel);
    _prefs.setInt('total_petals', _totalPetals);
    _prefs.setInt('bonsai_growth', _bonsaiGrowthStage);
    _prefs.setInt('daily_streak', _dailyStreak);
    _prefs.setString('last_play_date', _lastPlayDate?.toIso8601String() ?? '');
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
