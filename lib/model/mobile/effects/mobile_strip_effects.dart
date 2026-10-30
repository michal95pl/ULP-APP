import 'package:mobile_app/model/strip_effects.dart';

enum MobileStripEffect implements StripEffects {
  color,
  rainbow,
  gradient;

  @override
  bool needsDualColorPicker() {
    switch (this) {
      case MobileStripEffect.color:
        return false;
      case MobileStripEffect.rainbow:
      case MobileStripEffect.gradient:
        return true;
    }
  }
}