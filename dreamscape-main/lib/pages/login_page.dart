// lib/pages/login_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../pages/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscure = true;
  String? _usernameError;
  String? _passwordError;

  // Animations (match Dreamscape style)
  late final AnimationController _bgCtrl;
  late final AnimationController _cloudCtrl;
  late final Animation<double> _bgAnim;

  bool get _canSubmit =>
      !_isLoading &&
          _username.text.trim().isNotEmpty &&
          _password.text.trim().length >= 1 &&
          _usernameError == null &&
          _passwordError == null;

  @override
  void initState() {
    super.initState();
    _username.addListener(_validateUsername);
    _password.addListener(_validatePassword);

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    _cloudCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  void dispose() {
    _username
      ..removeListener(_validateUsername)
      ..dispose();
    _password
      ..removeListener(_validatePassword)
      ..dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();

    _bgCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  void _validateUsername() {
    final v = _username.text.trim();
    String? err;
    if (v.isEmpty) {
      err = 'Username is required';
    } else if (v.length < 3) {
      err = 'At least 3 characters';
    }
    setState(() => _usernameError = err);
  }

  void _validatePassword() {
    final v = _password.text;
    String? err;
    if (v.isEmpty) {
      err = 'Password is required';
    } else if (v.length < 1) {
      err = 'At least 1 character';
    }
    setState(() => _passwordError = err);
  }

  Future<void> _login() async {
    _validateUsername();
    _validatePassword();
    if (!_canSubmit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors to continue')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = await AuthService.login(
        _username.text.trim(),
        _password.text,
      );

      if (!mounted) return;

      final display = (data['username'] ?? _username.text.trim()).toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, $display')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(username: display)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
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
            'Login',
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
                    // Glass card for inputs
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
                            controller: _username,
                            hintText: 'Username',
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            focusNode: _usernameFocus,
                            onSubmitted: (_) => _passwordFocus.requestFocus(),
                            errorText: _usernameError,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _password,
                            hintText: 'Password',
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            focusNode: _passwordFocus,
                            onSubmitted: (_) => _login(),
                            errorText: _passwordError,
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscure = !_obscure),
                              tooltip: _obscure ? 'Show password' : 'Hide password',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: _isLoading ? 'Logging in...' : 'Login',
                      backgroundColor:
                      _canSubmit ? Colors.deepPurple : theme.disabledColor.withOpacity(0.3),
                      textColor: Colors.white,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _canSubmit ? _login : null,
                      leading: _isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Colors.deepPurple),
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

// Visual helpers (same style as other screens)

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
