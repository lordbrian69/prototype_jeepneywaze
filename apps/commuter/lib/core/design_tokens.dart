import 'package:flutter/material.dart';

/// JeepneyWaze Design System — based on Uber's confident minimalism
/// with Jeepney Yellow as the only accent color. Reference:
/// jeepneywaze_design/uploads/DESIGN-jeepneywaze-prompt.md
class JWColors {
  // Primary (Uber-inherited)
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const bodyGray = Color(0xFF4B4B4B);
  static const mutedGray = Color(0xFFAFAFAF);
  static const chipGray = Color(0xFFEFEFEF);
  static const hoverGray = Color(0xFFE2E2E2);

  // Accent — JeepneyWaze
  static const jeepneyYellow = Color(0xFFF5C400);
  static const yellowDark = Color(0xFFC49A00);
  static const yellowGlow = Color(0x33F5C400); // 20%

  // Semantic
  static const siksikanRed = Color(0xFFE53935);
  static const malwagGreen = Color(0xFF2E7D32);
  static const warningOrange = Color(0xFFF57C00);

  // Shadows
  static const shadowLight = Color(0x1F000000); // 12%
  static const shadowMedium = Color(0x29000000); // 16%
  static const shadowBeacon = Color(0x4DF5C400); // 30%
}

class JWRadius {
  static const small = 8.0;
  static const card = 12.0;
  static const sheet = 20.0;
  static const pill = 999.0;
}

class JWSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0; // screen edge margin
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

class JWShadows {
  static List<BoxShadow> get light => [
        const BoxShadow(
          color: JWColors.shadowLight,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        const BoxShadow(
          color: JWColors.shadowMedium,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get fab => [
        const BoxShadow(
          color: Color(0x29000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get beacon => [
        const BoxShadow(
          color: JWColors.shadowBeacon,
          blurRadius: 12,
          offset: Offset(0, 0),
        ),
      ];
}
