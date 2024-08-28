import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'UserSelection.dart';
import 'Leaf_farmer.dart';
import 'Ripe_farmer.dart';
import 'WelcomeScreen.dart';
import 'crop_health_farmer.dart';
import 'homeScreenfarmer.dart';

class NavDrawer2 extends StatefulWidget {
  const NavDrawer2({Key? key}) : super(key: key);

  @override
  State<NavDrawer2> createState() => _NavDrawer2State();
}

class _NavDrawer2State extends State<NavDrawer2> {
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
          .collection('Farmers')
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

  void _showSelectFarmAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selection Required",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        backgroundColor: Colors.white,
        content: const Text("Please select a farm to proceed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK",
              style: TextStyle(
                  fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? selectedFarm = context.watch<SelectedFarm>().selectedFarm;

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
                  builder: (context) => const homeScreenfarmer(),
                ),
              );
            },
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
                onTap: () {
                  if (selectedFarm != null) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadAndTake2(),
                      ),
                    );
                  } else {
                    _showSelectFarmAlert();
                  }
                },
              ),
              ListTile(
                title: const Text('Leaf Disease Detection'),
                onTap: () {
                  if (selectedFarm != null) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => upload_and_take_farmer(),
                      ),
                    );
                  } else {
                    _showSelectFarmAlert();
                  }
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
            onTap: () {
              if (selectedFarm != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropHealthFarmer(),
                  ),
                );
              } else {
                _showSelectFarmAlert();
              }
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
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
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
