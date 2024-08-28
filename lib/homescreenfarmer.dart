import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'UserSelection.dart';
import 'Leaf_farmer.dart';
import 'Ripe_farmer.dart';
import 'crop_health_farmer.dart';
import 'menu_farmer.dart';

class homeScreenfarmer extends StatefulWidget {
  const homeScreenfarmer({super.key});

  @override
  State<homeScreenfarmer> createState() => _homeScreenfarmerState();
}

class _homeScreenfarmerState extends State<homeScreenfarmer> {
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
            .where('Farmers', arrayContains: currentUser!.uid)
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

  void _showAlert() {
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
      drawer: NavDrawer2(),
      body: Container(
        padding: const EdgeInsets.all(70.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/nora10.jpeg"),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 150.0),
                Text(
                  "Please select a farm",
                  style: TextStyle(
                    color: Colors.black, // Change this to white
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 8.0), // Add some space between label and dropdown
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0, // Adjust font size here
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        context.read<SelectedFarm>().setSelectedFarm(newValue);
                      });
                    },
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    underline: SizedBox(), // Removes the underline
                  )
                      : Center(
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
            Spacer(), // Add a spacer to push the remaining content to the center
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconWithText(
                  icon: Icons.camera_alt,
                  color: const Color(0xFFFFFFFF),
                  text: "Vision System",
                  onTap: () {
                    if (selectedFarm != null) {
                      _showPictureOptions(context, "Vision System");
                    } else {
                      _showAlert();
                    }
                  },
                ),
                const SizedBox(height: 50.0), // Reduce the space between buttons
                _buildIconWithText(
                  icon: Icons.energy_savings_leaf_sharp,
                  color: const Color(0xFFffffff),
                  text: "Crop Health",
                  onTap: () {
                    if (selectedFarm != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CropHealthFarmer(),
                        ),
                      );
                    } else {
                      _showAlert();
                    }
                  },
                ),
              ],
            ),
            Spacer(flex: 2), // Adjust the flex value to move items up
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithText({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(40.0),
          color:  Color(0xFF344E41),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCircularIcon(icon, color),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
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
          color:  Color(0xFF344E41),
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
            leading: const Icon(Icons.scatter_plot_outlined),
            iconColor: const  Color(0xFF344E41),
            title: const Text(
              'Ripeness Level Detection',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              if (Provider.of<SelectedFarm>(context, listen: false).selectedFarm != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadAndTake2(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.energy_savings_leaf),
            iconColor: const Color(0xFF344E41),
            title: const Text(
              'Leaf Disease Detection',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onTap: () {
              if (Provider.of<SelectedFarm>(context, listen: false).selectedFarm != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => upload_and_take_farmer(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

