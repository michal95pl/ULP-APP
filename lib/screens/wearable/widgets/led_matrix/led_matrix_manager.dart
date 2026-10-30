import 'package:mobile_app/model/display_target.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_controller.dart';

class LedMatrixManager {
  LedMatrixManager._internal();
  static final LedMatrixManager instance = LedMatrixManager._internal();

  final LedMatrixController backController = LedMatrixController( target: DisplayTarget.backDisplay, width: 8, height: 8, maxPages: 4);
}