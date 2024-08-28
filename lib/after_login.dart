import 'package:flutter/material.dart';
import 'homeScreen.dart';
import 'homescreendataentry.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const After_login());

class After_login extends StatefulWidget {
  const After_login({super.key});

  @override
  State<After_login> createState() => _After_loginState();
}

class _After_loginState extends State<After_login> {
  // ignore: non_constant_identifier_names
  String? _selectedwhat_do;
  String? _selectedcode;
  User? currentUser;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
      });
      if (user != null) {
        print('Current user email: ${user.email}');
      } else {
        print('No user is currently logged in.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/after_log_in.jpg",
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Display the current user's email if available
                    if (currentUser != null)
                      Text(
                        'Logged in as: ${currentUser!.email}',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: _selectedwhat_do,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedwhat_do = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFF344E41),
                        items: <String>['Data Entry', 'Data Predicted']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'what do',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: _selectedcode,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedcode = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFF344E41),
                        items: <String>['1000', '1001']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Your Code',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedcode == null ||
                              _selectedwhat_do == null) {
                            _showAlert3(context);
                          } else {
                            if (_selectedwhat_do == 'Data Entry') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const homeScreendataentry()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const homeScreen()),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF344E41)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          // Generate a random number between 1000 and 1010
                          int randomCode = Random().nextInt(11) + 1002;

                          // Show an alert dialog with the random code
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Farm Code Added',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF344E41)),
                                ),
                                content: Text(
                                  'You successfully added a new farm with code: $randomCode',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF344E41),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Add new farm Code',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF344E41)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAlert3(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Missing Information",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        backgroundColor: Colors.white,
        content: const Text("Please fill all the fields."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "OK",
              style: TextStyle(
                  fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
