import 'package:flutter/material.dart';

/// Design tokens 0.2.0, hand-copied from `design/library/tokens.json` in the
/// product-design role. Change the source first, then this file.
class AppColors {
  const AppColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderDefault,
    required this.borderStrong,
    required this.actionBg,
    required this.actionFg,
    required this.actionPressed,
    required this.focusRing,
    required this.dangerFg,
    required this.dangerSolid,
    required this.dangerOnSolid,
    required this.warningFg,
    required this.scrim,
  });

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderDefault;
  final Color borderStrong;
  final Color actionBg;
  final Color actionFg;
  final Color actionPressed;
  final Color focusRing;
  final Color dangerFg;
  final Color dangerSolid;
  final Color dangerOnSolid;
  final Color warningFg;
  final Color scrim;

  static const light = AppColors(
    surfaceBase: Color(0xFFFAF7F2),
    surfaceRaised: Color(0xFFF1ECE3),
    textPrimary: Color(0xFF2B2622),
    textSecondary: Color(0xFF665D54),
    borderDefault: Color(0xFFDDD4C7),
    borderStrong: Color(0xFF8A7F73),
    actionBg: Color(0xFF4F6F5E),
    actionFg: Color(0xFFFFFFFF),
    actionPressed: Color(0xFF3F5A4B),
    focusRing: Color(0xFF4F6F5E),
    dangerFg: Color(0xFFA83A2E),
    dangerSolid: Color(0xFFA83A2E),
    dangerOnSolid: Color(0xFFFFFFFF),
    warningFg: Color(0xFF8A5A00),
    scrim: Color(0xFF000000),
  );

  static const dark = AppColors(
    surfaceBase: Color(0xFF1B1815),
    surfaceRaised: Color(0xFF25211D),
    textPrimary: Color(0xFFEDE6DC),
    textSecondary: Color(0xFFA99F93),
    borderDefault: Color(0xFF3A342E),
    borderStrong: Color(0xFF7C7267),
    actionBg: Color(0xFF8FB09E),
    actionFg: Color(0xFF14201A),
    actionPressed: Color(0xFFA6C4B3),
    focusRing: Color(0xFF8FB09E),
    dangerFg: Color(0xFFE5806F),
    dangerSolid: Color(0xFFE5806F),
    dangerOnSolid: Color(0xFF14201A),
    warningFg: Color(0xFFE0B060),
    scrim: Color(0xFF000000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class AppSpace {
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s24 = 24, s32 = 32, s48 = 48, s64 = 64;
  static const double screenMargin = 24;
  static const double touchMin = 48;
  static const double buttonHeight = 52;
  static const double fieldHeight = 56;
}

class AppRadius {
  static const double sm = 8, md = 12, lg = 20;
}

class AppType {
  static const String ui = 'Inter';
  static const String journalFont = 'Lora';

  static const display = TextStyle(fontFamily: ui, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w600);
  static const title = TextStyle(fontFamily: ui, fontSize: 22, height: 30 / 22, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontFamily: ui, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontFamily: ui, fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontFamily: ui, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400);
  static const journal =
      TextStyle(fontFamily: journalFont, fontSize: 17, height: 28 / 17, fontWeight: FontWeight.w400);
}

class AppDuration {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 200);
}
