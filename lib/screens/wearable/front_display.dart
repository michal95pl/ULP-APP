import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/bottom_nav.dart';
import 'package:mobile_app/widgets/pixel_painter.dart';
import 'package:mobile_app/widgets/effect_dropdown_button.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';
import 'package:mobile_app/widgets/text_vertical_slider.dart';

class FrontDisplay extends StatefulWidget {
  const FrontDisplay({super.key});

  @override
  State<FrontDisplay> createState() => FrontDisplayState();
}

class FrontDisplayState extends State<FrontDisplay> {

  static final PixelPainter pixelPainter = PixelPainter(8, 8, 1, ValueNotifier<bool>(false));
  static final TextVerticalSlider brightnessSlider = TextVerticalSlider("Brightness", 100, const Color.fromARGB(255, 243, 32, 250));

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // drawer: DrawerNav.getDrawerNav(context),
      appBar: StatisticsAppBar(isMobileConnected: false, isStageConnected: false, isSynchEnabled: false),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(
        children: <Widget>[
          GestureDetector(
            child: CustomPaint(
              painter: pixelPainter,
              size: pixelPainter.getSize(),
            ),
            onTapDown: (details) => {
              pixelPainter.setPixelFromPosition(details.localPosition.dx.toInt(), details.localPosition.dy.toInt(), 255, 0, 0),
            },
          ),
          Row(children: [
            brightnessSlider.getSlider(this, (value) async {}, true, false)
          ])
        ],
        
      ),
    );
  }
}
