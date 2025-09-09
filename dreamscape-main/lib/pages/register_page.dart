import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../pages/auth_service.dart';
import 'login_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _bgCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(username, email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully! Please login.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            "Register",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
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
          // Drifting translucent clouds
          AnimatedBuilder(
            animation: _cloudCtrl,
            builder: (context, _) {
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              final dx = (math.sin(_cloudCtrl.value * 2 * math.pi) * w * 0.12);
              return Stack(
                children: [
                  _CloudBlob(offset: Offset(dx - w * 0.25, h * 0.18), size: Size(w * 0.75, 180)),
                  _CloudBlob(offset: Offset(-dx + w * 0.35, h * 0.60), size: Size(w * 0.85, 230)),
                ],
              );
            },
          ),
          // Twinkling stars
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(painter: _StarsPainter(animation: _bgAnim), size: Size.infinite),
          ),

          // Form content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: usernameController,
                            hintText: "Username",
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            hintText: "Email",
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: passwordController,
                            hintText: "Password",
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: _isLoading ? 'Registering...' : 'Register',
                      backgroundColor: Colors.deepPurple,
                      textColor: Colors.white,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _isLoading ? null : _register,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
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

// Shared visuals (same helpers used across screens)

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
