import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_health_dataentry.dart';
import 'crop_and_fertilizer_dataentry.dart';
import 'historydataentry.dart';
import 'menudataentry.dart';
import 'YieldandPriceDataEntryScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'UserSelection.dart'; // Import the state management class

class homeScreendataentry extends StatefulWidget {
  const homeScreendataentry({super.key});

  @override
  State<homeScreendataentry> createState() => _HomeScreenDataEntryState();
}

class _HomeScreenDataEntryState extends State<homeScreendataentry> {
  User? currentUser;
  List<String> farms = [];

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Farms')
            .get();

        List<String> fetchedFarmNames = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('Name')) {
            fetchedFarmNames.add(data['Name']);
          }
        }

        setState(() {
          farms = fetchedFarmNames;
          if (farms.isNotEmpty) {
            context.read<SelectedFarm>().setSelectedFarm(farms[0]); // Select the first farm by default
          } else {
            context.read<SelectedFarm>().setSelectedFarm(null);
          }
        });
      } catch (e) {
        print("Error fetching farms: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedFarm = context.watch<SelectedFarm>().selectedFarm;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF344E41),
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
              "assets/nora10.jpeg",
              fit: BoxFit.fill,
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      "Please select a farm",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 8.0), // Add some space between label and dropdown
                    Container(
                      width: 300,
                      height: 50, // Adjust the width as needed
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: farms.isNotEmpty
                          ? DropdownButton<String>(
                        value: selectedFarm,
                        items: farms.map<DropdownMenuItem<String>>((farmName) {
                          return DropdownMenuItem<String>(
                            value: farmName,
                            child: Center(
                              child: Text(
                                farmName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0, // Adjust font size here
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          context.read<SelectedFarm>().setSelectedFarm(newValue);
                        },
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        underline: const SizedBox(), // Removes the underline
                      )
                          : const Center(
                        child: Text(
                          "No farms available",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0, // Adjust font size here
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70.0),
                _buildIconWithText(
                  icon: Icons.trending_up,
                  color: Colors.white,
                  text: "Decision Support System",
                  onTap: () {
                    if (selectedFarm != null) {
                      _showPictureOptions(context, "Decision Support System");
                    } else {
                      _showSelectFarmAlert();
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                _buildIconWithText(
                  icon: Icons.energy_savings_leaf_sharp,
                  color: Colors.white,
                  text: "Crop Health",
                  onTap: () {
                    if (selectedFarm != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CropHealthdataentry()),
                      );
                    } else {
                      _showSelectFarmAlert();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithText({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
    TextStyle? style,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(40.0),
          color: const Color(0xFF344E41),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCircularIcon(icon, color),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: style ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIcon(IconData icon, Color color) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 36.0,
          color: const Color(0xFF344E41),
        ),
      ),
    );
  }

  void _showPictureOptions(BuildContext context, String optionType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return PictureOptions(optionType: optionType);
      },
    );
  }

  void _showSelectFarmAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selection Required",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        backgroundColor: Colors.white,
        content: const Text("Please select a farm to proceed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "OK",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class PictureOptions extends StatelessWidget {
  final String optionType;

  const PictureOptions({Key? key, required this.optionType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.attach_money),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Yield And Price Forecast',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const YieldAndPriceDataEntryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.grass),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Crop And Fertilizer Data',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const crop_fertilizer_dataentry()),
              );
            },
          ),
        ],
      ),
    );
  }
}
