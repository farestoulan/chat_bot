import 'package:flutter/material.dart';

/// Circular bot avatar with a solid ring (the asset itself has a dashed ring).
class BotCircularAvatar extends StatelessWidget {
  const BotCircularAvatar({super.key, required this.size});

  final double size;

  static const Color _ringColor = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: _ringColor, width: (size * 0.04).clamp(1.0, 2.0)),
      ),
      child: ClipOval(
        child: Transform.scale(
          scale: 1.16,
          child: Image.asset(
            'assets/images/singleclic_icon_circular.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
