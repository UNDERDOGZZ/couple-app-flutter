import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parejas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _FloatingHeart extends StatelessWidget {
  const _FloatingHeart({
    required this.size,
    required this.opacity,
    required this.offset,
  });

  final double size;
  final double opacity;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F5),
              Color(0xFFFFE4E6),
              Color(0xFFFCE7F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'Momentos en Pareja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Guarda fechas especiales, recuerdos y crea contenido para compartir juntos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.45,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final float = 10 * _controller.value;
                      final sway = 6 * (0.5 - (_controller.value - 0.5).abs());
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 20 + float,
                            left: 30,
                            child: _FloatingHeart(
                              size: 36,
                              opacity: 0.4,
                              offset: Offset(0, sway),
                            ),
                          ),
                          Positioned(
                            top: 80,
                            right: 40,
                            child: _FloatingHeart(
                              size: 24,
                              opacity: 0.6,
                              offset: Offset(0, -sway),
                            ),
                          ),
                          Positioned(
                            bottom: 40 + float,
                            left: 40,
                            child: _FloatingHeart(
                              size: 28,
                              opacity: 0.35,
                              offset: Offset(0, -sway),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 30,
                            child: _FloatingHeart(
                              size: 32,
                              opacity: 0.45,
                              offset: Offset(0, sway),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -8 + float / 2),
                            child: _CoupleIllustration(scale: 1 + float / 120),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Próximamente: inicio de sesión'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Iniciar'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Conecta tus recuerdos con amor',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingHeart extends StatelessWidget {
  const _FloatingHeart({
    required this.size,
    required this.opacity,
    required this.offset,
  });

  final double size;
  final double opacity;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Icon(
        Icons.favorite,
        size: size,
        color: const Color(0xFFF43F5E).withOpacity(opacity),
      ),
    );
  }
}

class _CoupleIllustration extends StatelessWidget {
  const _CoupleIllustration({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
              ),
            ),
            Positioned(
              left: 24,
              child: _PersonAvatar(
                color: const Color(0xFFF97316),
                icon: Icons.face,
              ),
            ),
            Positioned(
              right: 24,
              child: _PersonAvatar(
                color: const Color(0xFF38BDF8),
                icon: Icons.face_2,
              ),
            ),
            const Positioned(
              bottom: 34,
              child: Icon(
                Icons.favorite,
                size: 34,
                color: Color(0xFFE11D48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Icon(
        icon,
        size: 38,
        color: color,
      ),
    );
  }
}
