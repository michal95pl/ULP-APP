import 'package:mobile_app/screens/stage/models/strip_effects.dart';

enum AnalogStripEffects implements StripEffects {
  color,
  rainbow;

  @override
  bool needsDualColorPicker() {
    switch (this) {
      case AnalogStripEffects.color:
        return false;
      case AnalogStripEffects.rainbow:
        return true;
    }
  }
}