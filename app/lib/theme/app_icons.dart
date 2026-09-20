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
}
