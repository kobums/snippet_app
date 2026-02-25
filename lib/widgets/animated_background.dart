import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F0F5), // lg-bg-1
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Stack(
            children: [
              // Purple orb #c8b6ff
              Positioned(
                top: -50 + sin(t * 2 * pi) * 30,
                left: -50 + cos(t * 2 * pi) * 30,
                child: _buildOrb(const Color(0xFFC8B6FF), 500),
              ),
              // Blue orb #a8d8ea
              Positioned(
                bottom: -20 + cos(t * 2 * pi) * -20,
                right: -20 + sin(t * 2 * pi) * -20,
                child: _buildOrb(const Color(0xFFA8D8EA), 400),
              ),
              // Pink orb #ffc8dd
              Positioned(
                top: 200 + sin(t * 2 * pi + pi) * 20,
                left: 150 + cos(t * 2 * pi + pi) * 20,
                child: _buildOrb(const Color(0xFFFFC8DD), 300),
              ),
              // Filter overlay for blur (to simulate Next.js blur-3xl)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}
