import 'package:mobile_app/screens/stage/models/strip_effects.dart';

enum AddresableStripEffects implements StripEffects {
  color,
  rainbow,
  gradient;

  @override
  bool needsDualColorPicker() {
    switch (this) {
      case AddresableStripEffects.color:
        return false;
      case AddresableStripEffects.rainbow:
      case AddresableStripEffects.gradient:
        return true;
    }
  }
}