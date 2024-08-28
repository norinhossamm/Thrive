import 'package:flutter/material.dart';
import 'crop_and_fertilizer_dataentry.dart';
import 'after_login.dart';
import 'WelcomeScreen.dart';
import 'crop_health_dataentry.dart';
import 'YieldandPriceDataEntryScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'homescreendataentry.dart';

// ignore: use_key_in_widget_constructors
class NavDrawer3 extends StatefulWidget {
  @override
  State<NavDrawer3> createState() => _NavDrawer3State();
}

class _NavDrawer3State extends State<NavDrawer3> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }


  Future<void> _fetchUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name'];
          userEmail = user.email;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName ?? 'Loading...'),
            accountEmail: Text(userEmail ?? 'Loading...'),
            decoration: const BoxDecoration(
              color: Color(0xFF344E41),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/leaves.jpeg'),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            iconColor: const Color.fromARGB(255, 67, 63, 63),
            title: const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const homeScreendataentry(),
                ),
              );
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.trending_up),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Decision Support System',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                title: const Text('Yield And Price Forecast'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const YieldAndPriceDataEntryScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Crop And Fertilizer Data'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const crop_fertilizer_dataentry(),
                    ),
                  );
                },
              ),
            ],
          ),
          /*ExpansionTile(
            leading: const Icon(Icons.camera_alt),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Vision System',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                title: const Text('Ripeness Level Detection'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => upload_and_take2(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Leaf Disease Detection'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => upload_and_take(),
                    ),
                  );
                },
              ),
            ],
          ),*/
          ListTile(
            leading: const Icon(Icons.energy_savings_leaf_sharp),
            iconColor: const Color.fromARGB(255, 67, 63, 63),
            title: const Text(
              'Crop Health',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropHealthdataentry(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            iconColor: const Color.fromARGB(255, 67, 63, 63),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
