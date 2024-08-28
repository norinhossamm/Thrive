import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'loginFarmerScreen.dart';
import 'homescreendataentry.dart';
import 'login_admin.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/frame.jpg'),
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,

              ),
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 200.0, bottom: 15.0), // Add padding to move text down
                  child: Text(
                    'Log in as:',
                    style: TextStyle(
                      fontSize: 38,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const loginFarmerScreen()));
                  },
                  child: Container(
                    height: 63,
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white, width: 2), // Make the border bolder
                      gradient: LinearGradient(
                        // Add a faded background
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3), // Faded white color
                          Colors.white
                              .withOpacity(0.1), // Even more faded white color
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Farmer',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  child: Container(
                    height: 63,
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white, width: 2), // Make the border bolder
                      gradient: LinearGradient(
                        // Add a faded background
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3), // Faded white color
                          Colors.white
                              .withOpacity(0.1), // Even more faded white color
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Owner',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const loginAdminScreen()));
                  },
                  child: Container(
                    height: 63,
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white, width: 2), // Make the border bolder
                      gradient: LinearGradient(
                        // Add a faded background
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3), // Faded white color
                          Colors.white
                              .withOpacity(0.1), // Even more faded white color
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
