import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState(); 

}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController _gradientAnimationController;
  late Animation _gradientAnimation;

  @override
  void initState() {

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/splash_background.bmp"),
          fit: BoxFit.cover
        )
      ),
      child: Center(
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
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),

            const Text(
              "Made and designed by Michal Lichtarski",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white
              ),
            ),

            const Text(
              "for wypas impry",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: const Text('    open    '),
              )
            
          ],
        ) 
      )
    )
      )
    );
    
  }

}