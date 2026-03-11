import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

// ─── Molecule Symbol ────────────────────────────────────────────────────────
class MoleculeSymbol {
  final String emoji;
  final String name;
  final int multiplier;
  final Color color;
  final bool isScatter;
  const MoleculeSymbol({
    required this.emoji,
    required this.name,
    required this.multiplier,
    required this.color,
    this.isScatter = false,
  });
}

const List<MoleculeSymbol> kSymbols = [
  MoleculeSymbol(emoji: '⚗️',  name: 'Vial',      multiplier: 3,  color: Color(0xFF00CFFF)),
  MoleculeSymbol(emoji: '🧬',  name: 'Helix',     multiplier: 4,  color: Color(0xFF00FF99)),
  MoleculeSymbol(emoji: '🔬',  name: 'Scope',     multiplier: 5,  color: Color(0xFF88AAFF)),
  MoleculeSymbol(emoji: '🔥',  name: 'Plasma',    multiplier: 8,  color: Color(0xFFFF6644)),
  MoleculeSymbol(emoji: '🌀',  name: 'Vortex',    multiplier: 12, color: Color(0xFF9966FF)),
  MoleculeSymbol(emoji: '💎',  name: 'Crystal',   multiplier: 25, color: Color(0xFF00F5FF)),
  MoleculeSymbol(emoji: '☢️',  name: 'Catalyst',  multiplier: 50, color: Color(0xFFFF2244)),
  MoleculeSymbol(emoji: '🌟',  name: 'Catalyst+', multiplier: 0,  color: Color(0xFFAA44FF), isScatter: true),
];

// Weighted pool — rarer molecules appear less
final List<MoleculeSymbol> kPool = [
  ...List.filled(8, kSymbols[0]),  // Vial      (common)
  ...List.filled(7, kSymbols[1]),  // Helix
  ...List.filled(6, kSymbols[2]),  // Scope
  ...List.filled(5, kSymbols[3]),  // Plasma
  ...List.filled(4, kSymbols[4]),  // Vortex
  ...List.filled(3, kSymbols[5]),  // Crystal   (rare)
  ...List.filled(2, kSymbols[6]),  // Catalyst  (legendary)
  ...List.filled(3, kSymbols[7]),  // Scatter
];

// Palette constants
const kCyan   = Color(0xFF00F5FF);
const kViolet = Color(0xFF7B2FFF);
const kBg     = Color(0xFF050510);

// ─── Main Widget ─────────────────────────────────────────────────────────────
class SlotGame extends StatefulWidget {
  const SlotGame({super.key});

  @override
  State<SlotGame> createState() => _SlotGameState();
}

class _SlotGameState extends State<SlotGame> with TickerProviderStateMixin {
  final Random _random = Random();

  late List<MoleculeSymbol> _reels;
  late List<bool>  _reelStopped;

  int get balance => _gameState?.coins ?? 1000;
  GameState? _gameState;
  int currentBet    = 50;
  int freeSpinsLeft = 0;
  int winStreak     = 0;
  int totalWon      = 0;
  bool _isSpinning  = false;
  String _resultMessage = '⚗️  Awaiting synthesis...';
  bool _isCelebrating   = false;
  int  _lastWinAmount   = 0;

  late List<List<MoleculeSymbol>> _rollingSymbols;
  Timer? _spinTimer;

  late AnimationController _celebrationCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  final List<int> betOptions = [10, 25, 50, 100, 250];

  static const _reactionLabels = {
    'low':     '🧪 Mild Reaction!',
    'medium':  '⚡ Chain Reaction!',
    'high':    '🌋 CRITICAL SYNTHESIS ☢️',
    'scatter': '🌀 CATALYST EVENT! +5 Boosts!',
    'miss':    '🔬 No Reaction — Recalibrate…',
    'partial': '💡 Partial Bond! +',
    'free':    '✨ FREE SYNTHESIS! (',
    'broke':   '⚠️ Insufficient Energy Units!',
  };

  @override
  void initState() {
    super.initState();
    _reels       = [kSymbols[0], kSymbols[1], kSymbols[2]];
    _reelStopped = [true, true, true];
    _rollingSymbols = [for (var i = 0; i < 3; i++) [kPool[0]]];

    _celebrationCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
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
    _glowCtrl.dispose();
    super.dispose();
  }

  void _setBet(int amount) {
    if (_isSpinning) return;
    setState(() => currentBet = amount);
  }

  void _spin() {
    if (_isSpinning) return;
    final bool usingFree = freeSpinsLeft > 0;
    final gs = context.read<GameState>();

    if (!usingFree && gs.coins < currentBet) {
      setState(() => _resultMessage = _reactionLabels['broke']!);
      return;
    }

    setState(() {
      _isSpinning   = true;
      _isCelebrating = false;
      _reelStopped  = [false, false, false];
      if (!usingFree) {
        gs.spendCoins(currentBet);
      } else {
        freeSpinsLeft--;
      }
      _resultMessage = usingFree
          ? '${_reactionLabels['free']}$freeSpinsLeft left)'
          : '🔬 Synthesizing...';
    });
    gs.recordSpin();

    _spinTimer = Timer.periodic(const Duration(milliseconds: 75), (timer) {
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

    Future.delayed(const Duration(milliseconds: 500), () => _stopReel(0));
    Future.delayed(const Duration(milliseconds: 900), () => _stopReel(1));
    Future.delayed(const Duration(milliseconds: 1300), () {
      _stopReel(2);
      _spinTimer?.cancel();
      _spinTimer = null;
      Future.delayed(const Duration(milliseconds: 100), _checkReaction);
    });
  }

  void _stopReel(int index) {
    final symbol = kPool[_random.nextInt(kPool.length)];
    setState(() {
      _reels[index]       = symbol;
      _reelStopped[index] = true;
    });
  }

  void _checkReaction() {
    final s1 = _reels[0];
    final s2 = _reels[1];
    final s3 = _reels[2];

    final scatterCount = [s1, s2, s3].where((s) => s.isScatter).length;

    if (scatterCount >= 3) {
      final gs = context.read<GameState>();
      setState(() {
        freeSpinsLeft += 5;
        _resultMessage = _reactionLabels['scatter']!;
        _isSpinning    = false;
        winStreak++;
      });
      gs.recordWin(isScatter: true);
      _triggerCelebration(750);
      return;
    }

    if (s1.emoji == s2.emoji && s2.emoji == s3.emoji) {
      // Full match — critical synthesis
      final gs         = context.read<GameState>();
      final multiplier = s1.multiplier + (winStreak > 2 ? winStreak : 0);
      final winAmount  = currentBet * multiplier;
      final isJack     = winAmount >= currentBet * 20;
      setState(() {
        gs.addCoins(winAmount);
        totalWon       += winAmount;
        winStreak++;
        _lastWinAmount  = winAmount;
        _resultMessage  = isJack
            ? '${_reactionLabels['high']} +$winAmount EU!'
            : '${_reactionLabels['medium']} ${s1.name} x${s1.multiplier}  +$winAmount EU!';
        _isSpinning     = false;
      });
      gs.recordWin(isJackpot: isJack);
      gs.checkCoinsAchievements();
      _triggerCelebration(isJack ? 2000 : 1000);
    } else if (s1.emoji == s2.emoji || s2.emoji == s3.emoji || s1.emoji == s3.emoji) {
      // Partial bond
      final gs        = context.read<GameState>();
      final winAmount = currentBet * 2;
      setState(() {
        gs.addCoins(winAmount);
        totalWon       += winAmount;
        winStreak++;
        _lastWinAmount  = winAmount;
        _resultMessage  = '${_reactionLabels['partial']}$winAmount EU';
        _isSpinning     = false;
      });
      gs.recordWin();
    } else {
      context.read<GameState>().recordLoss();
      setState(() {
        winStreak      = 0;
        _resultMessage = freeSpinsLeft > 0
            ? '🎁 Free synthesis remaining: $freeSpinsLeft'
            : _reactionLabels['miss']!;
        _isSpinning    = false;
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

  void _addEnergy() {
    final gs = context.read<GameState>();
    gs.addCoins(500);
    setState(() => _resultMessage = '⚡ +500 EU injected into reactor!');
  }

  void _showFormulas(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0A0A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kCyan, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚗️  FORMULA GUIDE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kCyan,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Match 3 molecules to trigger a reaction',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(color: kCyan, height: 24),
              ...kSymbols.where((s) => !s.isScatter).map((sym) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(sym.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(sym.name,
                        style: TextStyle(color: sym.color, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: sym.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sym.color, width: 1),
                      ),
                      child: Text('x${sym.multiplier}',
                        style: TextStyle(color: sym.color, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              )),
              const Divider(color: kViolet, height: 24),
              Row(
                children: const [
                  Text('🌟🌟🌟', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Catalyst+ Scatter',
                      style: TextStyle(color: Color(0xFFAA44FF), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  Text('5 Free Reactions!', style: TextStyle(color: Color(0xFFAA44FF), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('CLOSE LAB', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  Widget _buildReelSymbol(int index) {
    final stopped = _reelStopped[index];
    final symbol  = _reels[index];
    if (stopped) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(symbol.emoji,
          key: ValueKey('${symbol.emoji}_$index'),
          style: const TextStyle(fontSize: 50)),
      );
    }
    return _rollingSymbols[index].isNotEmpty
        ? Text(_rollingSymbols[index].last.emoji, style: const TextStyle(fontSize: 50))
        : const Text('🌀', style: TextStyle(fontSize: 50));
  }

  Widget _buildReel(int index) {
    final stopped = _reelStopped[index];
    final symbol  = _reels[index];
    final isWin   = !_isSpinning && _isCelebrating &&
        (_reels[0].emoji == _reels[1].emoji && _reels[1].emoji == _reels[2].emoji);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 85,
        height: 95,
        decoration: BoxDecoration(
          color: isWin
              ? symbol.color.withOpacity(0.15)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWin
                ? symbol.color
                : stopped
                    ? kCyan.withOpacity(0.25)
                    : kCyan.withOpacity(0.6 * _glowAnim.value),
            width: isWin ? 2 : 1,
          ),
          boxShadow: isWin
              ? [BoxShadow(color: symbol.color.withOpacity(0.6), blurRadius: 20, spreadRadius: 3)]
              : stopped
                  ? [const BoxShadow(color: Color(0x2200F5FF), blurRadius: 6)]
                  : [BoxShadow(color: kCyan.withOpacity(0.3 * _glowAnim.value), blurRadius: 14)],
        ),
        child: Center(child: child),
      ),
      child: _buildReelSymbol(index),
    );
  }

  Widget _buildLabMachineDivider() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        width: 2, height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              kCyan.withOpacity(0.5 * _glowAnim.value),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<GameState>(); // keep in sync
    return Stack(
      children: [
        Column(
          children: [
            _buildStatsRow(),
            const SizedBox(height: 16),
            if (freeSpinsLeft > 0) _buildFreeSpinsIndicator(),
            if (freeSpinsLeft > 0) const SizedBox(height: 12),
            _buildReactor(),
            const SizedBox(height: 24),
            _buildResultMessage(),
            const SizedBox(height: 20),
            _buildEnergySelector(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
        if (_isCelebrating) _buildCelebrationOverlay(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _statCard(
          icon: Icons.bolt_rounded,
          label: 'ENERGY',
          value: balance.toString(),
          color: kCyan,
        )),
        const SizedBox(width: 10),
        Expanded(child: _statCard(
          icon: Icons.local_fire_department_rounded,
          label: 'STREAK',
          value: winStreak.toString(),
          color: winStreak > 3 ? const Color(0xFFFF6644) : Colors.grey,
        )),
        const SizedBox(width: 10),
        Expanded(child: _statCard(
          icon: Icons.science_rounded,
          label: 'COLLECTED',
          value: totalWon.toString(),
          color: const Color(0xFF00FF99),
        )),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String   label,
    required String   value,
    required Color    color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, letterSpacing: 1)),
          Text(value,  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
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
          gradient: const LinearGradient(colors: [kViolet, Color(0xFFAA44FF)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Color(0x887B2FFF), blurRadius: 14, spreadRadius: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌀', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'FREE REACTIONS: $freeSpinsLeft',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactor() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isSpinning
                ? [const Color(0xFF080820), const Color(0xFF050510)]
                : [const Color(0xFF0A0A20), const Color(0xFF050510)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isSpinning
                ? kCyan.withOpacity(0.9 * _glowAnim.value)
                : kCyan.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: _isSpinning
              ? [BoxShadow(color: kCyan.withOpacity(0.4 * _glowAnim.value), blurRadius: 30, spreadRadius: 4)]
              : [BoxShadow(color: kCyan.withOpacity(0.08), blurRadius: 12)],
        ),
        child: child,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReel(0),
              _buildLabMachineDivider(),
              _buildReel(1),
              _buildLabMachineDivider(),
              _buildReel(2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _reels.map((s) => Text(
              s.name.toUpperCase(),
              style: TextStyle(color: s.color.withOpacity(0.7), fontSize: 9, letterSpacing: 1),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMessage() {
    final isWin     = _resultMessage.contains('Reaction') || _resultMessage.contains('SYNTHESIS') || _resultMessage.contains('Bond');
    final isScatter = _resultMessage.contains('CATALYST');
    final isFree    = _resultMessage.contains('FREE');

    Color msgColor = Colors.grey[400]!;
    Color bgColor  = Colors.transparent;
    if (isWin)     { msgColor = kCyan;                  bgColor = kCyan.withOpacity(0.08); }
    if (isScatter) { msgColor = const Color(0xFFAA44FF); bgColor = const Color(0xFF7B2FFF).withOpacity(0.08); }
    if (isFree)    { msgColor = const Color(0xFF00FF99); bgColor = const Color(0xFF00FF99).withOpacity(0.07); }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_resultMessage),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _resultMessage,
          style: TextStyle(color: msgColor, fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEnergySelector() {
    return Column(
      children: [
        Text(
          'ENERGY UNITS PER REACTION',
          style: TextStyle(color: Colors.grey[600], fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
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
                    color: isSelected ? kCyan : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kCyan : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? const [BoxShadow(color: Color(0x8800F5FF), blurRadius: 10)]
                        : [],
                  ),
                  child: Text(
                    bet.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[400],
                      fontSize: 14,
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
        // Main SYNTHESIZE button
        GestureDetector(
          onTap: _spin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            decoration: BoxDecoration(
              gradient: _isSpinning
                  ? const LinearGradient(colors: [Color(0xFF003344), Color(0xFF001122)])
                  : const LinearGradient(
                      colors: [kCyan, kViolet],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: _isSpinning
                  ? []
                  : const [BoxShadow(color: Color(0xAA00F5FF), blurRadius: 22, spreadRadius: 2)],
            ),
            child: Text(
              _isSpinning
                  ? '⏳ REACTING...'
                  : freeSpinsLeft > 0
                      ? '🌀 FREE REACTION!'
                      : '⚗️  SYNTHESIZE',
              style: TextStyle(
                color: _isSpinning ? Colors.grey[400] : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showFormulas(context),
              icon: const Icon(Icons.biotech_outlined, size: 16, color: kCyan),
              label: const Text('FORMULA GUIDE', style: TextStyle(color: kCyan, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kCyan.withOpacity(0.5), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(width: 12),
            if (balance < 100)
              OutlinedButton.icon(
                onPressed: _addEnergy,
                icon: const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF00FF99)),
                label: const Text('+500 EU', style: TextStyle(color: Color(0xFF00FF99), fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00FF99), width: 1),
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
                Opacity(
                  opacity: (1 - t) * 0.25,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [kCyan.withOpacity(0.5), Colors.transparent],
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
                ..._buildParticles(t),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildParticles(double t) {
    return List.generate(12, (i) {
      final angle  = (i / 12) * 2 * pi;
      final radius = 80 + 120 * t;
      final dx     = cos(angle) * radius;
      final dy     = sin(angle) * radius;
      final colors = [kCyan, kViolet, const Color(0xFF00FF99), const Color(0xFFFF6644)];
      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + dx - 6,
        top:  280 + dy - 6,
        child: Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: colors[i % colors.length],
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: colors[i % colors.length].withOpacity(0.8), blurRadius: 6)],
            ),
          ),
        ),
      );
    });
  }
}