import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dreamscape/pages/generate_page.dart';
import 'package:dreamscape/pages/profile_page.dart';
import 'package:dreamscape/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  HomePage({Key? key, this.username = 'Guest'}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  void _goToGenerate() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GeneratePage()),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(username: widget.username)),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
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
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Dreamscape',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'profile') _goToProfile();
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline, size: 20),
                      SizedBox(width: 10),
                      Text('My Profile'),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 8),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              // Unique moon avatar with gradient ring
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF80DEEA), Color(0xFF7C4DFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEF1FF),
                    ),
                    child: const Icon(Icons.bedtime, size: 16, color: Color(0xFF6A50FF)),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    center: Alignment(0.0, -0.3),
                    radius: 1.2,
                    colors: [
                      Color.lerp(const Color(0xFF221055), const Color(0xFF3D1E8A), t)!,
                      Color.lerp(const Color(0xFF0B0726), const Color(0xFF160D3A), 1 - t)!,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              );
            },
          ),
          // Soft drifting “clouds”
          AnimatedBuilder(
            animation: _cloudCtrl,
            builder: (context, _) {
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              final dx = (math.sin(_cloudCtrl.value * 2 * math.pi) * w * 0.12);
              return Stack(
                children: [
                  _CloudBlob(offset: Offset(dx - w * 0.2, h * 0.15), size: Size(w * 0.7, 180)),
                  _CloudBlob(offset: Offset(-dx + w * 0.3, h * 0.55), size: Size(w * 0.8, 220)),
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
                    // Glassy welcome chip with glow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Welcome to Dreamscape! 🌌',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Turn your dreams into AI‑generated art in one tap.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 16,
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 1)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _AnimatedCTA(onPressed: _goToGenerate),
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

// Soft blurred gradient ovals to mimic nebulous clouds
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
      // pseudo-random positions
      final x = (i * 97) % size.width;
      final y = (i * 53) % size.height;
      // gentle twinkle
      final twinkle = 0.45 + 0.55 * (0.5 * (1 - math.cos((t + i / count) * 2 * math.pi)));
      paint.color = Colors.white.withOpacity(twinkle);
      final r = 0.6 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}

class _AnimatedCTA extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedCTA({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<_AnimatedCTA> createState() => _AnimatedCTAState();
}

class _AnimatedCTAState extends State<_AnimatedCTA> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hover ? 1.03 : 1.0);
    final glow = _hover || _pressed ? 0.42 : 0.22;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(glow),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Generate Dream Image',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
