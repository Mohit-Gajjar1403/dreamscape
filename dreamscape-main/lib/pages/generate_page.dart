import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_page.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> with TickerProviderStateMixin {
  final TextEditingController promptController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? generatedImageUrl;
  String? lastPrompt;
  bool isLoading = false;

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
    promptController.dispose();
    _scrollCtrl.dispose();
    _bgCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  Future<void> generateImage() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      lastPrompt = prompt;
      generatedImageUrl = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      isLoading = false;
      generatedImageUrl =
      'https://placehold.co/800x480?text=Image+for:\n${Uri.encodeComponent(prompt)}';
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
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
        leading: IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: _goHome,
        ),
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Dream Generator',
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
        actions: [
          IconButton(
            tooltip: 'New',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                lastPrompt = null;
                generatedImageUrl = null;
                promptController.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
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
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(painter: _StarsPainter(animation: _bgAnim), size: Size.infinite),
          ),

          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (lastPrompt != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(14),
                                constraints: const BoxConstraints(maxWidth: 680),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  lastPrompt!,
                                  style: const TextStyle(color: Colors.white, fontSize: 15.5),
                                ),
                              ),
                            ),

                          if (isLoading)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Creating your dream...',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),

                          if (!isLoading && generatedImageUrl != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Generated Image',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 1)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(generatedImageUrl!, fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.25),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: TextField(
                                controller: promptController,
                                style: const TextStyle(color: Colors.white),
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Describe your dream...',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.newline,
                                onSubmitted: (_) => generateImage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Tooltip(
                            message: isLoading ? 'Generating...' : 'Send',
                            child: GestureDetector(
                              onTap: isLoading ? null : generateImage,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLoading ? Colors.deepPurple.shade200 : Colors.deepPurple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurpleAccent.withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.send, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
