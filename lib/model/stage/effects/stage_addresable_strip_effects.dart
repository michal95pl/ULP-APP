import 'package:mobile_app/model/strip_effects.dart';

enum StageAddresableStripEffects implements StripEffects {
  color,
  rainbow,
  gradient;

  @override
  bool needsDualColorPicker() {
    switch (this) {
      case StageAddresableStripEffects.color:
        return false;
      case StageAddresableStripEffects.rainbow:
      case StageAddresableStripEffects.gradient:
        return true;
    }
  }
}