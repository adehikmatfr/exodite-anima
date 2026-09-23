import 'package:flutter/widgets.dart';

/// The icons the app uses, from the Lucide icon font (ISC licence, `lucide-static`
/// 1.47.0, bundled as `assets/fonts/Lucide.ttf`; the licence text is next to it).
/// Code points come from the font's own `info.json`. Add an icon here, never
/// inline, so the register of assets stays complete
/// (`.assist/product-design/docs/asset-register.md`).
class AppIcons {
  static const back = IconData(0xe048, fontFamily: 'Lucide'); // arrow-left
  static const add = IconData(0xe13d, fontFamily: 'Lucide'); // plus
  static const search = IconData(0xe151, fontFamily: 'Lucide'); // search
  static const close = IconData(0xe1b2, fontFamily: 'Lucide'); // x
  static const alert = IconData(0xe077, fontFamily: 'Lucide'); // circle-alert
  static const chevronRight = IconData(0xe06f, fontFamily: 'Lucide'); // chevron-right
  static const radioOn = IconData(0xe345, fontFamily: 'Lucide'); // circle-dot
  static const radioOff = IconData(0xe076, fontFamily: 'Lucide'); // circle

  // FEAT-010 mood scale (Great, Good, Okay, Bad, Awful), in that order. Code
  // points verified 2026-09-23 against `lucide-static@1.47.0`'s own
  // `font/info.json` (the version this project bundles), not guessed.
  static const moods = [laugh, smile, meh, frown, angry];
  static const laugh = IconData(0xe300, fontFamily: 'Lucide');
  static const smile = IconData(0xe164, fontFamily: 'Lucide');
  static const meh = IconData(0xe114, fontFamily: 'Lucide');
  static const frown = IconData(0xe0db, fontFamily: 'Lucide');
  static const angry = IconData(0xe2fc, fontFamily: 'Lucide');

  // FEAT-011 photos. Code points verified 2026-09-23 against
  // `lucide-static@1.47.0`'s own `font/info.json`, not guessed.
  static const camera = IconData(0xe064, fontFamily: 'Lucide');
  static const image = IconData(0xe0f6, fontFamily: 'Lucide'); // photo placeholder / thumbnail fallback
  static const trash = IconData(0xe18e, fontFamily: 'Lucide'); // trash-2
}
