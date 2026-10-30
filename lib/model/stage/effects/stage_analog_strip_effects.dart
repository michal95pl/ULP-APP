import 'package:mobile_app/model/strip_effects.dart';

enum StageAnalogStripEffects implements StripEffects {
  color,
  rainbow;

  @override
  bool needsDualColorPicker() {
    switch (this) {
      case StageAnalogStripEffects.color:
        return false;
      case StageAnalogStripEffects.rainbow:
        return true;
    }
  }
}