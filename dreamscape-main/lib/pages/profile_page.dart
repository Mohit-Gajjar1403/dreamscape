import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({Key? key, this.username = 'Guest'}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _cloudCtrl;
  late final Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    _cloudCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0726),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 12, color: Colors.black54, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated nebula gradient
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) {
              final t = _bgAnim.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.3),
                    radius: 1.2,
                    colors: [
                      Color.lerp(const Color(0xFF221055), const Color(0xFF3D1E8A), t)!,
                      Color.lerp(const Color(0xFF0B0726), const Color(0xFF160D3A), 1 - t)!,
                    ],
                  ),
                ),
              );
            },
          ),
          // Drifting translucent “clouds”
          AnimatedBuilder(
            animation: _cloudCtrl,
            builder: (context, _) {
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              final dx = (math.sin(_cloudCtrl.value * 2 * math.pi) * w * 0.12);
              return Stack(
                children: [
                  _CloudBlob(offset: Offset(dx - w * 0.2, h * 0.20), size: Size(w * 0.7, 180)),
                  _CloudBlob(offset: Offset(-dx + w * 0.3, h * 0.58), size: Size(w * 0.8, 220)),
                ],
              );
            },
          ),
          // Twinkling stars
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(painter: _StarsPainter(animation: _bgAnim), size: Size.infinite),
          ),
          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glassy profile card
                    Container
                      (
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Gradient avatar coin
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const SweepGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFF80DEEA), Color(0xFF7C4DFF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEEF1FF),
                                ),
                                child: const Icon(Icons.bedtime, size: 22, color: Color(0xFF6A50FF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Username',
                                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(
                                  widget.username,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.purple.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared visual helpers (no external assets):

class _CloudBlob extends StatelessWidget {
  final Offset offset;
  final Size size;
  const _CloudBlob({Key? key, required this.offset, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.height),
            gradient: const LinearGradient(
              colors: [Color(0x55FFFFFF), Color(0x2240B0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(blurRadius: 60, color: Color(0x553C1E99), spreadRadius: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final Animation<double> animation;
  _StarsPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    const count = 120;
    for (int i = 0; i < count; i++) {
      final x = (i * 97) % size.width;
      final y = (i * 53) % size.height;
      final twinkle = 0.45 + 0.55 * (0.5 * (1 - math.cos((t + i / count) * 2 * math.pi)));
      paint.color = Colors.white.withOpacity(twinkle);
      final r = 0.6 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}
