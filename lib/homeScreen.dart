import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'Leaf_disease_detection.dart';
import 'Ripeness_level_detection.dart';
import 'crop_health.dart';
import 'history.dart';
import 'menu.dart';
import 'crop_and_fertilizer.dart';
import 'DateRangeScreen.dart';
import 'UserSelection.dart'; // Import the state management class

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
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
            .where('Owners', arrayContains: currentUser!.uid)
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
          }
          else
            context.read<SelectedFarm>().setSelectedFarm(null);
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
          '',
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
      drawer: const NavDrawer(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(60.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/nora10.jpeg"),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            _buildIconWithText(
              icon: Icons.trending_up,
              color: Colors.white,
              text: "Decision Support System",
              onTap: selectedFarm != null
                  ? () {
                _showPictureOptions(context, "Decision Support System");
              }
                  : () {
                _showErrorDialog("Please select a farm first.");
              },
            ),
            _buildIconWithText(
              icon: Icons.camera_alt,
              color: Colors.white,
              text: "Vision System",
              onTap: selectedFarm != null
                  ? () {
                _showPictureOptions2(context, "Vision System");
              }
                  : () {
                _showErrorDialog("Please select a farm first.");
              },
            ),
            _buildIconWithText(
              icon: Icons.energy_savings_leaf_sharp,
              color: Colors.white,
              text: "Crop Health",
              onTap: selectedFarm != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CropHealth()),
                );
              }
                  : () {
                _showErrorDialog("Please select a farm first.");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithText({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0), // Adjust margin to control spacing
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
              style: const TextStyle(
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

  void _showErrorDialog(String message) {
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

class PictureOptions extends StatefulWidget {
  final String optionType;

  const PictureOptions({Key? key, required this.optionType}) : super(key: key);

  @override
  State<PictureOptions> createState() => _PictureOptionsState();
}

class _PictureOptionsState extends State<PictureOptions> {
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DateRangeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.grass),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Crop And Fertilizer Recommendation',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CropFertilizer()),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showPictureOptions2(BuildContext context, String optionType) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return PictureOptions2(optionType: optionType);
    },
  );
}

class PictureOptions2 extends StatefulWidget {
  final String optionType;

  const PictureOptions2({Key? key, required this.optionType}) : super(key: key);

  @override
  State<PictureOptions2> createState() => _PictureOptionsState2();
}

class _PictureOptionsState2 extends State<PictureOptions2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.scatter_plot_outlined),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Ripeness Level Detection',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadAndTake2()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.energy_savings_leaf),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Leaf Disease Detection',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => upload_and_take()),
              );
            },
          ),
        ],
      ),
    );
  }
}
