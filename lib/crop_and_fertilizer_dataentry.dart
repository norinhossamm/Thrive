import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menudataentry.dart';
import 'historydataentry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const crop_fertilizer_dataentry());
}

class crop_fertilizer_dataentry extends StatefulWidget {
  const crop_fertilizer_dataentry({super.key});

  @override
  State<crop_fertilizer_dataentry> createState() => _CropFertilizerDataEntryState();
}

class _CropFertilizerDataEntryState extends State<crop_fertilizer_dataentry> {
  String? _selectedDistrictName;
  String? _selectedSoilColor;
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crop and Fertilizer Data',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrictName,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDistrictName = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFFFFFFFF),
                        items: <String>[
                          'Kolhapur',
                          'Satara',
                          'Sangli',
                          'Solapur',
                          'Pune'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'District Name',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                        value: _selectedSoilColor,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSoilColor = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFFFFFFFF),
                        items: <String>[
                          'Black',
                          'Red',
                          'Dark Brown',
                          'Reddish Brown',
                          'Light Brown',
                          'Medium Brown'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Soil Color',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                        controller: _potassiumController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Potassium',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nitrogenController.text.isEmpty ||
                              _potassiumController.text.isEmpty ||
                              _selectedDistrictName == null ||
                              _selectedSoilColor == null ||
                              _phosphorusController.text.isEmpty) {
                            _showAlert3(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CropFertilizerDataEntry2(
                                        districtName: _selectedDistrictName!,
                                        soilColor: _selectedSoilColor!,
                                        nitrogen: _nitrogenController.text,
                                        phosphorus: _phosphorusController.text,
                                        potassium: _potassiumController.text,
                                      )),
                            );
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

class CropFertilizerDataEntry2 extends StatefulWidget {
  final String districtName;
  final String soilColor;
  final String nitrogen;
  final String phosphorus;
  final String potassium;

  const CropFertilizerDataEntry2({
    Key? key,
    required this.districtName,
    required this.soilColor,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  }) : super(key: key);

  @override
  State<CropFertilizerDataEntry2> createState() =>
      _CropFertilizerDataEntry2State();
}

class _CropFertilizerDataEntry2State extends State<CropFertilizerDataEntry2> {
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  String? _selectedCrop;
  String? _selectedFertilizer;

  @override
  void dispose() {
    _phController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    await FirebaseFirestore.instance.collection('Crop&FertilizerData').add({
      'District_Name': widget.districtName,
      'Soil_color': widget.soilColor,
      'Nitrogen': widget.nitrogen,
      'Phosphorus': widget.phosphorus,
      'Potassium': widget.potassium,
      'pH': _phController.text,
      'Rainfall': _rainfallController.text,
      'Temperature': _temperatureController.text,
      'Predicted_Crop': _selectedCrop,
      'Predicted_Fertilizer': _selectedFertilizer,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crop and Fertilizer Data',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF344E41),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.black,
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
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                        value: _selectedCrop,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCrop = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFFFFFFFF),
                        items: <String>[
                          'Sugarcane',
                          'Wheat',
                          'Cotton',
                          'Jowar',
                          'Maize',
                          'Rice',
                          'Groundnut',
                          'Tur',
                          'Ginger',
                          'Grapes',
                          'Urad',
                          'Moong',
                          'Gram',
                          'Turmeric',
                          'Soybean',
                          'Masoor'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Crop',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                        value: _selectedFertilizer,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedFertilizer = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFFFFFFFF),
                        items: <String>[
                          '10:10:10 NPK',
                          '10:26:26 NPK',
                          '12:32:16 NPK',
                          '13:32:26 NPK',
                          '18:46:00 NPK',
                          '19:19:19 NPK',
                          '20:20:20 NPK',
                          '50:26:26 NPK',
                          'Ammonium Sulphate',
                          'Chilated Micronutrient',
                          'DAP',
                          'Ferrous Sulphate',
                          'Hydrated Lime',
                          'MOP',
                          'Magnesium Sulphate',
                          'SSP',
                          'Sulphur',
                          'Urea',
                          'White Potash'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Fertilizer',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      crop_fertilizer_dataentry()),
                            );
                          },
                          child: const Text(
                            '  Back  ',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF344E41)),
                          ),
                        ),
                        const SizedBox(width: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_phController.text.isEmpty ||
                                _rainfallController.text.isEmpty ||
                                _temperatureController.text.isEmpty ||
                                _selectedCrop == null ||
                                _selectedFertilizer == null) {
                              _showAlert3(context);
                            } else {
                              _saveData();
                              _showAlert(context);
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF344E41)),
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
      ),
    );
  }
}

void _showAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Saved data",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF344E41)),
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
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
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
