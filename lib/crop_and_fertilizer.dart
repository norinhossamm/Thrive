import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'history.dart';
import 'menu.dart';

class CropFertilizer extends StatefulWidget {
  const CropFertilizer({Key? key}) : super(key: key);

  @override
  State<CropFertilizer> createState() => _CropFertilizerState();
}

class _CropFertilizerState extends State<CropFertilizer> {
  String? _selectedDistrict_Name;
  String? _selectedSoil_color;
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  List<String> districtNames = [];
  List<String> soilColors = [];

  @override
  void initState() {
    super.initState();
    fetchDistrictNames();
    fetchSoilColors();
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    super.dispose();
  }

  Future<void> fetchDistrictNames() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Dropdown')
          .doc('Districts')
          .get();

      if (snapshot.exists) {
        List<dynamic> names = snapshot['Names'];
        setState(() {
          districtNames = List<String>.from(names);
        });
      }
    } catch (e) {
      print('Error fetching district names: $e');
    }
  }

  Future<void> fetchSoilColors() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Dropdown')
          .doc('Soil')
          .get();

      if (snapshot.exists) {
        List<dynamic> colors = snapshot['SoilColors'];
        setState(() {
          soilColors = List<String>.from(colors);
        });
      }
    } catch (e) {
      print('Error fetching soil colors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crop and fertilizer recommendation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
        drawer: NavDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/nora10.jpeg",
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrict_Name,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDistrict_Name = newValue!;
                          });
                        },
                        dropdownColor: Colors.white,
                        items: districtNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'District Name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
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
                        value: _selectedSoil_color,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSoil_color = newValue!;
                          });
                        },
                        dropdownColor: Colors.white,
                        items: soilColors.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Soil Color',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: _nitrogenController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nitrogen',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: _phosphorusController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Phosphorus',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        if (_nitrogenController.text.isEmpty ||
                            _selectedDistrict_Name == null ||
                            _selectedSoil_color == null ||
                            _phosphorusController.text.isEmpty) {
                          _showAlert3(context);
                        } else if (!isNumeric(_nitrogenController.text) ||
                            !isNumeric(_phosphorusController.text)) {
                          _showNonNumericAlert(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CropFertilizerRecommendationResult(
                                district: _selectedDistrict_Name,
                                soilColor: _selectedSoil_color,
                                nitrogen: _nitrogenController.text,
                                phosphorus: _phosphorusController.text,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF344E41),
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

class CropFertilizerRecommendationResult extends StatelessWidget {
  final String? district;
  final String? soilColor;
  final String? nitrogen;
  final String? phosphorus;

  const CropFertilizerRecommendationResult({
    Key? key,
    required this.district,
    required this.soilColor,
    required this.nitrogen,
    required this.phosphorus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CropFertilizer2(
      district: district,
      soilColor: soilColor,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
    );
  }
}

class CropFertilizer2 extends StatefulWidget {
  final String? district;
  final String? soilColor;
  final String? nitrogen;
  final String? phosphorus;

  const CropFertilizer2({
    Key? key,
    required this.district,
    required this.soilColor,
    required this.nitrogen,
    required this.phosphorus,
  }) : super(key: key);

  @override
  State<CropFertilizer2> createState() => _CropFertilizer2State();
}

class _CropFertilizer2State extends State<CropFertilizer2> {
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  @override
  void dispose() {
    _potassiumController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop and fertilizer recommendation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF344E41),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/nora10.jpeg",
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _potassiumController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Potassium',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _phController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'pH',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _rainfallController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Rainfall',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: _temperatureController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Temperature',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF344E41),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () {
                          if (_potassiumController.text.isEmpty ||
                              _phController.text.isEmpty ||
                              _rainfallController.text.isEmpty ||
                              _temperatureController.text.isEmpty) {
                            _showAlert3(context);
                          } else if (!isNumeric(_potassiumController.text) ||
                              !isNumeric(_phController.text) ||
                              !isNumeric(_rainfallController.text) ||
                              !isNumeric(_temperatureController.text)) {
                            _showNonNumericAlert(context);
                          } else {
                            _submitData(context);
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF344E41),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitData(BuildContext context) async {
    final String potassium = _potassiumController.text;
    final String ph = _phController.text;
    final String rainfall = _rainfallController.text;
    final String temperature = _temperatureController.text;

    final Map<String, String> inputData = {
      'District_Name': widget.district!,
      'Soil_color': widget.soilColor!,
      'Nitrogen': widget.nitrogen!,
      'Phosphorus': widget.phosphorus!,
      'Potassium': potassium,
      'pH': ph,
      'Rainfall': rainfall,
      'Temperature': temperature,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/CropandFertilizer'),
      body: jsonEncode(inputData),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String crop = responseData['predicted_crop'];
      String fertilizer = responseData['predicted_fertilizer'];

      _showOutputModal(context, crop, fertilizer);
    } else {
      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to fetch data. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> getDownloadUrl(String crop) async {
    String imageUrl = '';
    try {
      // Convert the crop name to lowercase
      String lowerCaseCrop = crop.toLowerCase();

      // Fetch the document from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Cropandimages')
          .where('Crop', isEqualTo: lowerCaseCrop)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No document found for crop: $lowerCaseCrop');
      }

      // Get the first document from the query result
      DocumentSnapshot document = querySnapshot.docs.first;

      // Get the gs:// URL from the document
      String gsUrl = document['ImageURL'];
      print('gsUrl: $gsUrl');  // Debug print

      // Convert gs:// URL to download URL
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      imageUrl = await ref.getDownloadURL();
      print('Download URL: $imageUrl');  // Debug print
    } catch (e) {
      print('Failed to get download URL: $e');
      imageUrl = 'https://your-cloud-storage-url/default.jpg'; // Default image if failed to get URL
    }
    return imageUrl;
  }

  void _showOutputModal(BuildContext context, String crop, String fertilizer) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<String>(
          future: Future.delayed(Duration(seconds: 6), () => getDownloadUrl(crop)),
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.waiting) {
              child = Container(
                width: 150,
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              child = Container(
                width: 150,
                height: 150,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else {
              String imageUrl = snapshot.data ?? 'https://your-cloud-storage-url/default.jpg';
              child = Image.network(
                imageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              );
            }
            return SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        child,
                        const SizedBox(height: 20),
                        Text(
                          'Crop: $crop',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Fertilizer: $fertilizer',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF344E41),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        ElevatedButton(
                          onPressed: () {
                            _saveData(context, crop, fertilizer);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF344E41),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveData(BuildContext context, String crop, String fertilizer) async {
    final String potassium = _potassiumController.text;
    final String ph = _phController.text;
    final String rainfall = _rainfallController.text;
    final String temperature = _temperatureController.text;

    final Map<String, dynamic> data = {
      'District_Name': widget.district,
      'Soil_color': widget.soilColor,
      'Nitrogen': widget.nitrogen,
      'Phosphorus': widget.phosphorus,
      'Potassium': potassium,
      'pH': ph,
      'Rainfall': rainfall,
      'Temperature': temperature,
      'Predicted_Crop': crop,
      'Predicted_Fertilizer': fertilizer,
    };

    await FirebaseFirestore.instance.collection('Crop&Fertilizer').add(data);

    _showAlert(context);
  }

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Saved Data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF344E41),
            ),
          ),
          backgroundColor: Colors.white,
          content: const Text("Your Data is Saved."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF344E41),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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

void _showNonNumericAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Invalid Input",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text("Please enter a number (integer or float)."),
        actions: [
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

bool isNumeric(String str) {
  if (str.isEmpty) {
    return false;
  }
  return double.tryParse(str) != null;
}
