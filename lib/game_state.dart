import 'package:flutter/material.dart';

/// Central game state shared across all screens.
/// Uses ChangeNotifier so any widget can listen for updates.
class GameState extends ChangeNotifier {
  // ── Coins ──────────────────────────────────────────────────────────────────
  int _coins = 1000;
  int get coins => _coins;

  void addCoins(int amount) {
    _coins += amount;
    if (_coins > _highScore) _highScore = _coins;
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (_coins >= amount) _coins -= amount;
    notifyListeners();
  }

  // ── High Score ──────────────────────────────────────────────────────────────
  int _highScore = 1000;
  int get highScore => _highScore;

  // ── Win Stats ───────────────────────────────────────────────────────────────
  int _totalSpins = 0;
  int _totalWins  = 0;
  int _bestStreak = 0;
  int _currentStreak = 0;
  int _scattersHit = 0;
  int _jackpotsHit = 0;

  int get totalSpins   => _totalSpins;
  int get totalWins    => _totalWins;
  int get bestStreak   => _bestStreak;
  int get currentStreak => _currentStreak;
  int get scattersHit  => _scattersHit;
  int get jackpotsHit  => _jackpotsHit;

  void recordSpin() {
    _totalSpins++;
    notifyListeners();
  }

  void recordWin({bool isJackpot = false, bool isScatter = false}) {
    _totalWins++;
    _currentStreak++;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    if (isJackpot) _jackpotsHit++;
    if (isScatter) _scattersHit++;
    _checkAchievements();
    notifyListeners();
  }

  void recordLoss() {
    _currentStreak = 0;
    notifyListeners();
  }

  // ── Daily Bonus ─────────────────────────────────────────────────────────────
  DateTime? _lastBonusClaimed;
  bool get canClaimBonus {
    if (_lastBonusClaimed == null) return true;
    final now = DateTime.now();
    return now.difference(_lastBonusClaimed!).inHours >= 24;
  }

  /// The timestamp when the next bonus becomes available (null if already available).
  DateTime? get nextBonusTime {
    if (_lastBonusClaimed == null) return null;
    return _lastBonusClaimed!.add(const Duration(hours: 24));
  }

  void claimBonus(int amount) {
    _lastBonusClaimed = DateTime.now();
    addCoins(amount);
  }


  // ── Achievements ────────────────────────────────────────────────────────────
  final Map<String, bool> _unlocked = {
    'first_spin':     false,
    'first_win':      false,
    'streak_3':       false,
    'streak_5':       false,
    'coins_5000':     false,
    'coins_10000':    false,
    'spins_50':       false,
    'spins_100':      false,
    'scatter_1':      false,
    'jackpot_1':      false,
  };

  Map<String, bool> get unlocked => Map.unmodifiable(_unlocked);

  // ── Achievement Toast Queue ──────────────────────────────────────────────────
  /// IDs of achievements that were just unlocked since the last [popNewlyUnlocked] call.
  final List<String> _pendingToasts = [];

  /// Returns and clears the pending toast queue.
  List<String> popNewlyUnlocked() {
    final result = List<String>.from(_pendingToasts);
    _pendingToasts.clear();
    return result;
  }

  void _checkAchievements() {
    _unlock('first_spin',  _totalSpins >= 1);
    _unlock('first_win',   _totalWins  >= 1);
    _unlock('streak_3',    _bestStreak >= 3);
    _unlock('streak_5',    _bestStreak >= 5);
    _unlock('coins_5000',  _coins >= 5000);
    _unlock('coins_10000', _coins >= 10000);
    _unlock('spins_50',    _totalSpins >= 50);
    _unlock('spins_100',   _totalSpins >= 100);
    _unlock('scatter_1',   _scattersHit >= 1);
    _unlock('jackpot_1',   _jackpotsHit >= 1);
  }

  void checkCoinsAchievements() {
    _unlock('coins_5000',  _coins >= 5000);
    _unlock('coins_10000', _coins >= 10000);
    notifyListeners();
  }

  void _unlock(String id, bool condition) {
    if (condition && !(_unlocked[id] ?? false)) {
      _unlocked[id] = true;
      _pendingToasts.add(id);
    }
  }

  // Mark first spin
  void markFirstSpin() {
    _totalSpins++;
    _unlock('first_spin', true);
    _checkAchievements();
    notifyListeners();
  }
}
