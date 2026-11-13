import 'dart:convert';
import 'dart:ui';

import 'package:mobile_app/model/stage/stage_strip_data.dart';
import 'package:mobile_app/model/stage/effects/stage_addresable_strip_effects.dart';
import 'package:mobile_app/model/stage/effects/stage_analog_strip_effects.dart';

class StatusStageData {
  
  final List<StageStripData<StageAddresableStripEffects>> addressableStrips;
  final List<StageStripData<StageAnalogStripEffects>> analogStrips;
  bool synchEnabled;

  StatusStageData({
    required this.addressableStrips,
    required this.analogStrips,
    required this.synchEnabled
  })  : assert(addressableStrips.length == 2, 'Addresable strips must have a length of 2'),
        assert(analogStrips.length == 2, 'Analog strips must have a length of 2'); 

  static StatusStageData getStatusData(String data) {
    final Map<String, dynamic> statusData = jsonDecode(data);
    final synch = statusData['synch'] as bool;

    List<StageStripData<StageAddresableStripEffects>> parsedAddressable = [];
    List<StageStripData<StageAnalogStripEffects>> parsedAnalog = [];

    for (var item in statusData['addressableStrips']) {
      parsedAddressable.add(
        StageStripData<StageAddresableStripEffects>(
          brightness: item['brightness'].toInt(),
          effect: StageAddresableStripEffects.values[item['effect'].toInt()],
          senitivity: item['sensitivity'].toInt(),
          treshold: item['threshold'].toInt(),
          smoothness: item['smoothness'].toInt(),
          speedEffect: item['speedEffect'].toInt(),
          color1: Color.fromARGB(
            255,
            item['color1']['r'].toInt(),
            item['color1']['g'].toInt(),
            item['color1']['b'].toInt(),
          ),
          color2: Color.fromARGB(
            255,
            item['color2']['r'].toInt(),
            item['color2']['g'].toInt(),
            item['color2']['b'].toInt(),
          ),
        )
      );
    }

    for (var item in statusData['analogStrips']) {
      parsedAnalog.add(
        StageStripData<StageAnalogStripEffects>(
          brightness: item['brightness'].toInt(),
          effect: StageAnalogStripEffects.values[item['effect'].toInt()],
          senitivity: item['sensitivity'].toInt(),
          treshold: item['threshold'].toInt(),
          smoothness: item['smoothness'].toInt(),
          speedEffect: item['speedEffect'].toInt(),
          color1: Color.fromARGB(
            255,
            item['color1']['r'].toInt(),
            item['color1']['g'].toInt(),
            item['color1']['b'].toInt(),
          ),
          color2: Color.fromARGB(
            255,
            item['color2']['r'].toInt(),
            item['color2']['g'].toInt(),
            item['color2']['b'].toInt(),
          ),
        )
      );
    }
  
    return StatusStageData(
      addressableStrips: parsedAddressable,
      analogStrips: parsedAnalog,
      synchEnabled: synch
    );
  }
}