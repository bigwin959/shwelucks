import 'package:flutter/material.dart';
import '../widgets/game_provider_grid.dart';
import '../widgets/live_winners_ticker.dart';
import '../widgets/loyalty_banner.dart';
import '../widgets/payment_methods.dart';
import '../widgets/promo_banner.dart';
import '../widgets/user_header.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Dashboard Header ──────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: UserHeader(),
            ),

            // ── Daily Claim Banner ────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LoyaltyBanner(),
            ),
            const SizedBox(height: 10),

            // ── Live Winners Ticker ───────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LiveWinnersTicker(),
            ),
            const SizedBox(height: 16),

            // ── Featured Promo ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PromoBanner(),
            ),
            const SizedBox(height: 20),

            // ── Play Now Banner ───────────────────────────────────────────
            _buildPlayNowBanner(context),
            const SizedBox(height: 20),

            // ── Game Providers ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 10),
              child: Text(
                'Game Providers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GameProviderGrid(),
            ),
            const SizedBox(height: 24),

            // ── Payment Methods ───────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 10),
              child: Text(
                'Payment Methods',
                style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PaymentMethods(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayNowBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the game tab
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap the 🎰 Play tab below!'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.amber,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A00), Color(0xFF1A0D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            const Text('🎰', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lucky Slots',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Win up to x50 your bet!',
                    style: TextStyle(color: Colors.amber[300], fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFCC00), Color(0xFFFF8800)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PLAY NOW',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                _miniStat('🏆', 'Jackpot'),
                const Text(
                  'x50',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
