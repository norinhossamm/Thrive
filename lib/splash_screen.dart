import 'package:flutter/material.dart';
import 'dart:async';
import 'WelcomeScreen.dart'; // Ensure this path is correct

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen())); // Ensure this path is correct
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF344E41)
      ,
      body: Stack(
        children: [
          Positioned(
            top: 130, // Position the text 50 pixels from the top
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate('Welcome to Thrive'.length, (index) {
                    final char = 'Welcome to Thrive'[index];
                    final animation = TweenSequence([
                      TweenSequenceItem(
                        tween: Tween<double>(begin: 0.0, end: 1.0)
                            .chain(CurveTween(curve: Interval(index / 20, 1.0, curve: Curves.easeIn))),
                        weight: 1,
                      ),
                    ]).animate(_animationController);

                    return FadeTransition(
                      opacity: animation,
                      child: Text(
                        char,
                        style: TextStyle(
                          color: Colors.white, // Use the lighter green color from the logo
                          fontSize: 42, // Adjust the font size as needed
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Center(
            child: Image.asset(
              'assets/Picture1.png', // Ensure this path is correct
              width: size.width * 0.9, // Adjust the width relative to screen size
              height: size.width * 0.9, // Adjust the height relative to screen size
              fit: BoxFit.contain, // Ensure the image fits within the given dimensions
            ),
          ),
          Positioned(
            bottom: 50, // Position the text 50 pixels from the bottom
            left: 0,
            right: 0,
            child: Text(
              'Grow with intelligence\nLet Thrive boost your harvests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, // Use the lighter green color from the logo
                fontSize: 20, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}