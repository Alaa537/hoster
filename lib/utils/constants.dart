import 'package:flutter/material.dart';

class C {
  // Primary palette — cyan neon
  static const primary    = Color(0xFF00E5FF);
  static const primaryDim = Color(0xFF00B8D4);
  static const primaryLo  = Color(0xFF00838F);

  // Accent — magenta / pink
  static const accent     = Color(0xFFFF4ECD);
  static const accentDim  = Color(0xFFD5009B);
  static const accentLo   = Color(0xFF9C006B);

  // Semantic
  static const success    = Color(0xFF00E676);
  static const warning    = Color(0xFFFFD740);
  static const danger     = Color(0xFFFF5252);
  static const info       = Color(0xFF40C4FF);

  // Neutrals
  static const muted      = Color(0xFF8A8A9A);
  static const mutedLo    = Color(0xFF5A5A6A);

  // Surfaces
  static const bg         = Color(0xFF07070F);
  static const surface    = Color(0xFF12121E);
  static const surfaceHi  = Color(0xFF1A1A2A);
  static const surfaceHi2 = Color(0xFF222236);
  static const border     = Color(0xFF2C2C42);
  static const borderHi   = Color(0xFF3A3A55);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
  );

  static const gradientDanger = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
  );

  static const gradientSurface = LinearGradient(
    colors: [Color(0xFF1A1A2A), Color(0xFF12121E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

const String kApiBaseDefault = 'http://api.alaa-dev.kdns.fr:20314';
