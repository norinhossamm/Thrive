// ignore_for_file: camel_case_types, non_constant_identifier_names, sort_child_properties_last, use_super_parameters

import 'package:flutter/material.dart';
import 'menudataentry.dart';
import 'homescreendataentry.dart';

//after_login

void main() => runApp(const historydataentry());

// ignore: must_be_immutable
class historydataentry extends StatefulWidget {
  const historydataentry({super.key});

  @override
  State<historydataentry> createState() => _historydataentryState();
}

class _historydataentryState extends State<historydataentry> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'History',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF344E41),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const historydataentry()),
                );
              },
            ),
          ],
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: NavDrawer3(),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/frame5.jpg",
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const homeScreendataentry(),
                            ),
                          );
                        },
                        child: const Text(
                          'Back',
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
