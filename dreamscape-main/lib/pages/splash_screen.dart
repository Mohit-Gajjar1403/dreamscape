import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dreamscape/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animations
  late final AnimationController _twinkleCtrl;   // stars
  late final AnimationController _glowCtrl;      // title glow (subtle pulse)

  // Audio
  final AudioPlayer _player = AudioPlayer();

  // UI state
  bool _started = false;

  @override
  void initState() {
    super.initState();

    // Slow, dreamy star twinkle
    _twinkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Gentle title glow (not full fade-out)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _start() async {
    setState(() => _started = true);

    // Looping audio; allowed on web only after this user tap
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    await _player.play(AssetSource('sounds/crickets.mp3'));
  }

  Future<void> _enter() async {
    // Stop audio (fast + reliable). If you want fade, see comment below.
    try {
      await _player.stop();
    } catch (_) {}
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    _twinkleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E0854), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            if (_started)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _twinkleCtrl,
                  builder: (_, __) =>
                      CustomPaint(painter: _StarPainter(_twinkleCtrl.value)),
                ),
              ),
            Center(
              child: _started
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: glow,
                    builder: (context, _) {
                      return Opacity(
                        opacity: glow.value,
                        child: const Text(
                          'DreamScape',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 30,
                                color: Colors.purpleAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _enter,
                    child: const Text('Enter'),
                  ),
                ],
              )
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _start, // user interaction → audio allowed
                child: const Text('Tap to Begin', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.t);
  final double t;
  static const int _starCount = 140;

  static final Random _rng = Random(2025);
  static List<Offset>? _cachedPositions;
  static Size? _lastSize;

  List<Offset> _positionsFor(Size size) {
    if (_cachedPositions == null || _lastSize != size) {
      _lastSize = size;
      _cachedPositions = List.generate(
        _starCount,
            (_) => Offset(
          _rng.nextDouble() * size.width,
          _rng.nextDouble() * size.height,
        ),
      );
    }
    return _cachedPositions!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final positions = _positionsFor(size);

    final twinkle = 0.35 + 0.55 * (0.5 * (1 - math.cos(t * 2 * math.pi)));
    for (final pos in positions) {
      final r = 0.6 + (_rng.nextDouble() * 1.1);
      paint.color = Colors.white.withOpacity(twinkle);
      canvas.drawCircle(pos, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => oldDelegate.t != t;
}
