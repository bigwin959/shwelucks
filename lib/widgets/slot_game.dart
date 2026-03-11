import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

// ─── Symbol Data ───────────────────────────────────────────────────────────
class SlotSymbol {
  final String emoji;
  final String name;
  final int multiplier; // multiplier when all 3 match
  final Color color;
  final bool isScatter;
  const SlotSymbol({
    required this.emoji,
    required this.name,
    required this.multiplier,
    required this.color,
    this.isScatter = false,
  });
}

const List<SlotSymbol> kSymbols = [
  SlotSymbol(emoji: "🍒", name: "Cherry",   multiplier: 3,  color: Color(0xFFFF4444)),
  SlotSymbol(emoji: "🍋", name: "Lemon",    multiplier: 4,  color: Color(0xFFFFDD44)),
  SlotSymbol(emoji: "🍊", name: "Orange",   multiplier: 5,  color: Color(0xFFFF8800)),
  SlotSymbol(emoji: "🔔", name: "Bell",     multiplier: 8,  color: Color(0xFFFFCC00)),
  SlotSymbol(emoji: "⭐", name: "Star",     multiplier: 10, color: Color(0xFFFFEB3B)),
  SlotSymbol(emoji: "💎", name: "Diamond",  multiplier: 25, color: Color(0xFF44CCFF)),
  SlotSymbol(emoji: "7️⃣", name: "Lucky 7", multiplier: 50, color: Color(0xFFFF2222)),
  SlotSymbol(emoji: "🌟", name: "Scatter",  multiplier: 0,  color: Color(0xFFAA88FF), isScatter: true),
];

// Weighted pool: higher-value symbols appear less
final List<SlotSymbol> kPool = [
  ...List.filled(8, kSymbols[0]),  // Cherry  (common)
  ...List.filled(7, kSymbols[1]),  // Lemon
  ...List.filled(6, kSymbols[2]),  // Orange
  ...List.filled(5, kSymbols[3]),  // Bell
  ...List.filled(4, kSymbols[4]),  // Star
  ...List.filled(3, kSymbols[5]),  // Diamond (rare)
  ...List.filled(2, kSymbols[6]),  // Lucky 7 (very rare)
  ...List.filled(3, kSymbols[7]),  // Scatter
];

// ─── Main Widget ────────────────────────────────────────────────────────────
class SlotGame extends StatefulWidget {
  const SlotGame({super.key});

  @override
  State<SlotGame> createState() => _SlotGameState();
}

class _SlotGameState extends State<SlotGame> with TickerProviderStateMixin {
  final Random _random = Random();

  // Reels
  late List<SlotSymbol> _reels;
  late List<bool> _reelStopped;

  // Game state (balance now from GameState, local for display)
  int get balance => _gameState?.coins ?? 1000;
  GameState? _gameState;
  int currentBet = 50;
  int freeSpinsLeft = 0;
  int winStreak = 0;
  int totalWon = 0;
  bool _isSpinning = false;
  String _resultMessage = '🎰 Spin to win!';
  bool _isCelebrating = false;
  int _lastWinAmount = 0;

  // Reel rolling symbols (shown during spin)
  late List<List<SlotSymbol>> _rollingSymbols;
  Timer? _spinTimer;

  // Animations
  late AnimationController _celebrationCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _reelShakeCtrl;

  final List<int> betOptions = [10, 25, 50, 100, 250];

  @override
  void initState() {
    super.initState();
    _reels = [kSymbols[0], kSymbols[1], kSymbols[2]];
    _reelStopped = [true, true, true];
    _rollingSymbols = [for (var i = 0; i < 3; i++) [kPool[0]]];

    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _reelShakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameState = context.read<GameState>();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _celebrationCtrl.dispose();
    _pulseCtrl.dispose();
    _reelShakeCtrl.dispose();
    super.dispose();
  }

  void _setBet(int amount) {
    if (_isSpinning) return;
    setState(() => currentBet = amount);
  }

  void _spin() {
    if (_isSpinning) return;

    final bool usingFreeSpins = freeSpinsLeft > 0;
    final gs = context.read<GameState>();

    if (!usingFreeSpins && gs.coins < currentBet) {
      setState(() => _resultMessage = '💸 Not enough coins! Add more!');
      return;
    }

    setState(() {
      _isSpinning = true;
      _isCelebrating = false;
      _reelStopped = [false, false, false];
      if (!usingFreeSpins) {
        gs.spendCoins(currentBet);
      } else {
        freeSpinsLeft--;
      }
      _resultMessage = usingFreeSpins
          ? '✨ FREE SPIN! ($freeSpinsLeft left)'
          : '🎰 Spinning...';
    });
    gs.recordSpin();

    // Roll each reel with changing symbols
    _spinTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        for (int i = 0; i < 3; i++) {
          if (!_reelStopped[i]) {
            _rollingSymbols[i] = [
              kPool[_random.nextInt(kPool.length)],
              kPool[_random.nextInt(kPool.length)],
            ];
          }
        }
      });
    });

    // Stop reels sequentially
    Future.delayed(const Duration(milliseconds: 500), () => _stopReel(0));
    Future.delayed(const Duration(milliseconds: 900), () => _stopReel(1));
    Future.delayed(const Duration(milliseconds: 1300), () {
      _stopReel(2);
      _spinTimer?.cancel();
      _spinTimer = null;
      Future.delayed(const Duration(milliseconds: 100), _checkWin);
    });
  }

  void _stopReel(int index) {
    final symbol = kPool[_random.nextInt(kPool.length)];
    setState(() {
      _reels[index] = symbol;
      _reelStopped[index] = true;
    });
  }

  void _checkWin() {
    final s1 = _reels[0];
    final s2 = _reels[1];
    final s3 = _reels[2];

    // Count scatters
    int scatterCount = [s1, s2, s3].where((s) => s.isScatter).length;

    if (scatterCount >= 3) {
      // 3 scatters = free spins
      final gs = context.read<GameState>();
      setState(() {
        freeSpinsLeft += 5;
        _resultMessage = '🌟 SCATTER! +5 Free Spins!';
        _isSpinning = false;
        winStreak++;
      });
      gs.recordWin(isScatter: true);
      _triggerCelebration(750);
      return;
    }

    if (s1.emoji == s2.emoji && s2.emoji == s3.emoji) {
      // Full match
      final gs = context.read<GameState>();
      final multiplier = s1.multiplier + (winStreak > 2 ? winStreak : 0);
      final winAmount = currentBet * multiplier;
      final isJack = winAmount >= currentBet * 20;
      setState(() {
        gs.addCoins(winAmount);
        totalWon += winAmount;
        winStreak++;
        _lastWinAmount = winAmount;
        _resultMessage = isJack
            ? '🎉 JACKPOT! +$winAmount coins!'
            : '✅ ${s1.name} WIN! +$winAmount coins!';
        _isSpinning = false;
      });
      gs.recordWin(isJackpot: isJack);
      gs.checkCoinsAchievements();
      _triggerCelebration(isJack ? 2000 : 1000);
    } else if (s1.emoji == s2.emoji || s2.emoji == s3.emoji || s1.emoji == s3.emoji) {
      // Partial match
      final gs = context.read<GameState>();
      final winAmount = currentBet * 2;
      setState(() {
        gs.addCoins(winAmount);
        totalWon += winAmount;
        winStreak++;
        _lastWinAmount = winAmount;
        _resultMessage = '👍 Small Win! +$winAmount coins';
        _isSpinning = false;
      });
      gs.recordWin();
    } else {
      context.read<GameState>().recordLoss();
      setState(() {
        winStreak = 0;
        _resultMessage = freeSpinsLeft > 0
            ? '🎁 Free spin remaining: $freeSpinsLeft'
            : '😞 Try Again!';
        _isSpinning = false;
      });
    }
  }

  void _triggerCelebration(int durationMs) {
    setState(() => _isCelebrating = true);
    _celebrationCtrl.forward(from: 0);
    Future.delayed(Duration(milliseconds: durationMs), () {
      if (mounted) setState(() => _isCelebrating = false);
    });
  }

  void _addCoins() {
    final gs = context.read<GameState>();
    gs.addCoins(500);
    setState(() => _resultMessage = '💰 +500 Coins Added! Good luck!');
  }

  void _showPaytable(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.amber, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎮 HOW TO PLAY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Match 3 symbols to earn bonus coins!',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Divider(color: Colors.amber, height: 24),
              ...kSymbols.where((s) => !s.isScatter).map((sym) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(sym.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sym.name,
                            style: TextStyle(color: sym.color, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: sym.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sym.color, width: 1),
                          ),
                          child: Text(
                            'x${sym.multiplier}',
                            style: TextStyle(color: sym.color, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(color: Colors.purple, height: 24),
              Row(
                children: const [
                  Text("🌟🌟🌟", style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Scatter",
                      style: TextStyle(color: Color(0xFFAA88FF), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("5 Free Spins!", style: TextStyle(color: Color(0xFFAA88FF), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  Widget _buildReelSymbol(int index) {
    final stopped = _reelStopped[index];
    final symbol = _reels[index];

    if (stopped) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          symbol.emoji,
          key: ValueKey('${symbol.emoji}_$index'),
          style: const TextStyle(fontSize: 54),
        ),
      );
    }

    // Rolling animation: show two blurred symbols
    return _rollingSymbols[index].isNotEmpty
        ? Text(
            _rollingSymbols[index].last.emoji,
            style: const TextStyle(fontSize: 54),
          )
        : const Text('❓', style: TextStyle(fontSize: 54));
  }

  Widget _buildReel(int index) {
    final stopped = _reelStopped[index];
    final symbol = _reels[index];
    final isWinningReel = !_isSpinning &&
        _isCelebrating &&
        (_reels[0].emoji == _reels[1].emoji && _reels[1].emoji == _reels[2].emoji);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 85,
      height: 95,
      decoration: BoxDecoration(
        color: isWinningReel
            ? symbol.color.withOpacity(0.2)
            : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWinningReel ? symbol.color : Colors.amber.withOpacity(0.4),
          width: isWinningReel ? 2 : 1,
        ),
        boxShadow: isWinningReel
            ? [BoxShadow(color: symbol.color.withOpacity(0.6), blurRadius: 18, spreadRadius: 3)]
            : stopped
                ? []
                : [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Center(child: _buildReelSymbol(index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch GameState so coin display stays in sync
    final gs = context.watch<GameState>();
    return Stack(
      children: [
        Column(
          children: [
            // ── Balance + Stats Row ─────────────────────────────────────
            _buildStatsRow(),
            const SizedBox(height: 16),

            // ── Free Spins Indicator ─────────────────────────────────────
            if (freeSpinsLeft > 0) _buildFreeSpinsIndicator(),
            if (freeSpinsLeft > 0) const SizedBox(height: 12),

            // ── Slot Machine ─────────────────────────────────────────────
            _buildSlotMachine(),
            const SizedBox(height: 24),

            // ── Result Message ───────────────────────────────────────────
            _buildResultMessage(),
            const SizedBox(height: 20),

            // ── Bet Selector ─────────────────────────────────────────────
            _buildBetSelector(),
            const SizedBox(height: 20),

            // ── Action Buttons ───────────────────────────────────────────
            _buildActionButtons(context),
          ],
        ),

        // ── Win Celebration Overlay ──────────────────────────────────────
        if (_isCelebrating) _buildCelebrationOverlay(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Balance
        Expanded(
          child: _statCard(
            icon: Icons.monetization_on_rounded,
            label: 'COINS',
            value: balance.toString(),
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 10),
        // Win Streak
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department,
            label: 'STREAK',
            value: winStreak.toString(),
            color: winStreak > 3 ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        // Total Won
        Expanded(
          child: _statCard(
            icon: Icons.emoji_events,
            label: 'TOTAL WON',
            value: totalWon.toString(),
            color: Colors.greenAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, letterSpacing: 1)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildFreeSpinsIndicator() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A0DAD), Color(0xFFAA88FF)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x884400CC), blurRadius: 12, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'FREE SPINS: $freeSpinsLeft',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotMachine() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isSpinning
              ? [const Color(0xFF2A1A00), const Color(0xFF1A1000)]
              : [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isSpinning ? Colors.amber : Colors.amber.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: _isSpinning
            ? [const BoxShadow(color: Color(0xAAFFCC00), blurRadius: 30, spreadRadius: 4)]
            : [const BoxShadow(color: Color(0x33FFCC00), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReel(0),
              _buildDivider(),
              _buildReel(1),
              _buildDivider(),
              _buildReel(2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _reels.map((s) => Text(
              s.isScatter ? 'SCATTER' : s.name.toUpperCase(),
              style: TextStyle(color: s.color.withOpacity(0.8), fontSize: 9, letterSpacing: 1),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 2,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.amber.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildResultMessage() {
    final isWin = _resultMessage.contains('WIN') ||
        _resultMessage.contains('JACKPOT') ||
        _resultMessage.contains('SCATTER');
    final isFree = _resultMessage.contains('FREE') || _resultMessage.contains('Free');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_resultMessage),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isWin
              ? Colors.amber.withOpacity(0.12)
              : isFree
                  ? Colors.purple.withOpacity(0.12)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _resultMessage,
          style: TextStyle(
            color: isWin
                ? Colors.amber
                : isFree
                    ? const Color(0xFFAA88FF)
                    : Colors.grey[400],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBetSelector() {
    return Column(
      children: [
        Text(
          'COINS PER SPIN',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: betOptions.map((bet) {
            final isSelected = currentBet == bet;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => _setBet(bet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [const BoxShadow(color: Color(0x88FFCC00), blurRadius: 8)]
                        : [],
                  ),
                  child: Text(
                    bet.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Main SPIN button
        GestureDetector(
          onTap: _spin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
            decoration: BoxDecoration(
              gradient: _isSpinning
                  ? const LinearGradient(colors: [Color(0xFF888800), Color(0xFF665500)])
                  : const LinearGradient(
                      colors: [Color(0xFFFFCC00), Color(0xFFFF8800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: _isSpinning
                  ? []
                  : const [
                      BoxShadow(color: Color(0xAAFF8800), blurRadius: 20, spreadRadius: 2),
                    ],
            ),
            child: Text(
              _isSpinning
                  ? '⏳ SPINNING...'
                  : freeSpinsLeft > 0
                      ? '✨ FREE SPIN!'
                      : '🎰  SPIN',
              style: TextStyle(
                color: _isSpinning ? Colors.grey[300] : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Bottom row: Paytable + Add Coins
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Paytable
            OutlinedButton.icon(
              onPressed: () => _showPaytable(context),
              icon: const Icon(Icons.table_chart_outlined, size: 16, color: Colors.amber),
              label: const Text('HOW TO PLAY', style: TextStyle(color: Colors.amber, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.amber, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(width: 12),
            // Add coins
            if (balance < 100)
              OutlinedButton.icon(
                onPressed: _addCoins,
                icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.greenAccent),
                label: const Text('+500 Coins', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.greenAccent, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _celebrationCtrl,
          builder: (context, child) {
            final t = _celebrationCtrl.value;
            return Stack(
              children: [
                // Shimmer overlay
                Opacity(
                  opacity: (1 - t) * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.amber.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
                // Floating win amount
                if (_lastWinAmount > 0)
                  Positioned(
                    top: 80 + (t * -60),
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Text(
                        '+$_lastWinAmount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.orange, blurRadius: 20)],
                        ),
                      ),
                    ),
                  ),
                // Confetti dots
                ...List.generate(12, (i) {
                  final angle = (i / 12) * 2 * pi;
                  final radius = t * 120;
                  final x = cos(angle) * radius;
                  final y = sin(angle) * radius;
                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + x - 6,
                    top: 160 + y,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: [
                            Colors.amber,
                            Colors.orange,
                            Colors.yellow,
                            Colors.red,
                          ][i % 4],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}