import 'package:flutter/material.dart';
import 'package:mobile_app/data/pixel_storage.dart';
import 'package:mobile_app/data/settings_file.dart';
import 'package:mobile_app/utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState(); 

}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _gradientAnimationController;
  late Animation _gradientAnimation;

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _gradientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3)
    );

    _gradientAnimation = Tween(
      begin: 0.0,
      end: 1.0
    ).animate(_gradientAnimationController..addListener(() {
      setState(() {});
    }));

    _gradientAnimationController.repeat(reverse: true);
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    await SettingsFile.openFile('settings.json');
    await PixelStorage.init();

    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash_background.bmp"),
            fit: BoxFit.cover
          )
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) =>
                      LinearGradient(
                        colors: const [Color.fromARGB(255, 123, 183, 255), Color.fromARGB(255, 255, 255, 255)],
                        stops: [_gradientAnimation.value - 0.5, _gradientAnimation.value]
                      ).createShader(rect),
                    child: const Text(
                      "ULP",
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const Text(
                    "Made and designed by Michal Lichtarski\nfor wypas impry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isDataLoaded)
                    ElevatedButton(
                      onPressed: () {
                        AppRoutes.navigateTo(context, AppRoutes.settings);
                      },
                      child: const Text('    open    '),
                    )
                ],
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: SafeArea(
                child: Text(
                  "v3.0",
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            )
          ]
        ) 
      ),
    ); 
  }

}