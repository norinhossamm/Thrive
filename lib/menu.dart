import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'crop_and_fertilizer.dart';
import 'Leaf_disease_detection.dart';
import 'Ripeness_level_detection.dart';
import 'after_login.dart';
import 'WelcomeScreen.dart';
import 'crop_health.dart';
import 'DateRangeScreen.dart';
import 'homeScreen.dart';
import 'UserSelection.dart'; // Import the state management class

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
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
          .collection('Owners')
          .doc(user.uid)
          .get();
      print('/////////////////${user.email}');
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name '];
          userEmail = user.email;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedFarm = Provider.of<SelectedFarm>(context).selectedFarm;

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
                  builder: (context) => const homeScreen(),
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
                      builder: (context) => const DateRangeScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Crop And Fertilizer Recommendation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CropFertilizer(),
                    ),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.camera_alt),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Vision System',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                title: const Text('Ripeness Level Detection'),
                onTap: selectedFarm != null
                    ? () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadAndTake2(),
                    ),
                  );
                }
                    : () {
                  _showErrorDialog(context, "Please select a farm first.");
                },
              ),
              ListTile(
                title: const Text('Leaf Disease Detection'),
                onTap: selectedFarm != null
                    ? () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => upload_and_take(),
                    ),
                  );
                }
                    : () {
                  _showErrorDialog(context, "Please select a farm first.");
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.energy_savings_leaf_sharp),
            iconColor: const Color.fromARGB(255, 67, 63, 63),
            title: const Text(
              'Crop Health',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: selectedFarm != null
                ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropHealth(),
                ),
              );
            }
                : () {
              _showErrorDialog(context, "Please select a farm first.");
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
