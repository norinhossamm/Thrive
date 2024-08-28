import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mobileapp/menu_farmer.dart';
import 'dart:convert';
import 'menu.dart';
import 'history.dart' as history;

class CropHealthFarmer extends StatefulWidget {
  const CropHealthFarmer({super.key});

  @override
  State<CropHealthFarmer> createState() => _CropHealthFarmerState();
}

class _CropHealthFarmerState extends State<CropHealthFarmer> {
  String? _selectedCropType;
  String? _selectedSoilType;
  String? _selectedPesticideUseCategory;
  final TextEditingController _insectCountController = TextEditingController();
  List<String> cropTypes = [];
  List<String> soilTypes = [];
  List<String> pesticideCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCropTypes();
    fetchSoilTypes();
    fetchPesticideCategories();
  }

  Future<void> fetchCropTypes() async {
    try {
      CollectionReference dropdown = FirebaseFirestore.instance.collection('Dropdown');
      DocumentSnapshot snapshot = await dropdown.doc('Crops').get();
      if (snapshot.exists) {
        setState(() {
          cropTypes = List<String>.from(snapshot['cropCategories']);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSoilTypes() async {
    try {
      CollectionReference dropdown = FirebaseFirestore.instance.collection('Dropdown');
      DocumentSnapshot snapshot = await dropdown.doc('Soil').get();
      if (snapshot.exists) {
        setState(() {
          soilTypes = List<String>.from(snapshot['SoilType']);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPesticideCategories() async {
    try {
      CollectionReference dropdown = FirebaseFirestore.instance.collection('Dropdown');
      DocumentSnapshot snapshot = await dropdown.doc('Pesticide').get();
      if (snapshot.exists) {
        setState(() {
          pesticideCategories = List<String>.from(snapshot['PesticideCategories']);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _insectCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Health',
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
      drawer: NavDrawer2(),
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
                      controller: _insectCountController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Estimated Insects Count',
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
                      value: _selectedCropType,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCropType = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFFFFFFFF),
                      items: cropTypes
                          .map<DropdownMenuItem<String>>((String value) {
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
                        labelText: 'Crop Type',
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
                      value: _selectedSoilType,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSoilType = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFFFFFFFF),
                      items: soilTypes
                          .map<DropdownMenuItem<String>>((String value) {
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
                        labelText: 'Soil Type',
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
                      value: _selectedPesticideUseCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPesticideUseCategory = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFFFFFFFF),
                      items: pesticideCategories
                          .map<DropdownMenuItem<String>>((String value) {
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
                        labelText: 'Pesticide Use Category',
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_insectCountController.text.isEmpty ||
                            _selectedCropType == null ||
                            _selectedSoilType == null ||
                            _selectedPesticideUseCategory == null) {
                          _showAlert3(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CropHealth2(
                                  insectCount: _insectCountController.text,
                                  cropType: _selectedCropType!,
                                  soilType: _selectedSoilType!,
                                  pesticideUseCategory:
                                  _selectedPesticideUseCategory!,
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
                          const Color(0xFF344E41),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropHealth2 extends StatefulWidget {
  final String insectCount;
  final String cropType;
  final String soilType;
  final String pesticideUseCategory;

  const CropHealth2({
    super.key,
    required this.insectCount,
    required this.cropType,
    required this.soilType,
    required this.pesticideUseCategory,
  });

  @override
  State<CropHealth2> createState() => _CropHealth2State();
}

class _CropHealth2State extends State<CropHealth2> {
  String? _selectedSeason;
  final _numberDosesController = TextEditingController();
  final _numberWeeksUsedController = TextEditingController();
  final _numberWeeksQuitController = TextEditingController();
  String? _cropDamageResult;
  List<String> seasonNames = [];

  @override
  void initState() {
    super.initState();
    fetchSeasonNames();
  }

  Future<void> fetchSeasonNames() async {
    try {
      CollectionReference dropdown = FirebaseFirestore.instance.collection('Dropdown');
      DocumentSnapshot snapshot = await dropdown.doc('SeasonsTypes').get();
      if (snapshot.exists) {
        setState(() {
          seasonNames = List<String>.from(snapshot['seasonNames']);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _numberDosesController.dispose();
    _numberWeeksUsedController.dispose();
    _numberWeeksQuitController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    final apiUrl = 'http://10.0.2.2:5000/CropHealth';
    final data = {
      "Estimated_Insects_Count": widget.insectCount,
      "Crop_Type": widget.cropType,
      "Soil_Type": widget.soilType,
      "Pesticide_Use_Category": widget.pesticideUseCategory,
      "Number_Doses_Week": _numberDosesController.text,
      "Number_Weeks_Used": _numberWeeksUsedController.text,
      "Number_Weeks_Quit": _numberWeeksQuitController.text,
      "Season": _selectedSeason
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print("inside status code 200");
      final result = jsonDecode(response.body);
      print(result);
      setState(() {
        _cropDamageResult = result['crop_damage'];
      });
      _Output_crop_health(context, _cropDamageResult!);
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Error",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          backgroundColor: Colors.white,
          content: const Text("Failed to get a response from the server."),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crop Health',
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
                  MaterialPageRoute(builder: (context) => const history.history()),
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
        drawer: NavDrawer2(),
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
                        controller: _numberDosesController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number Doses Week',
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                        controller: _numberWeeksUsedController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number Weeks Used',
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                        controller: _numberWeeksQuitController,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number Weeks Quit',
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                        value: _selectedSeason,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSeason = newValue!;
                          });
                        },
                        dropdownColor: const Color(0xFFFFFFFF),
                        items: seasonNames
                            .map<DropdownMenuItem<String>>((String value) {
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
                          labelText: 'Season',
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CropHealthFarmer()),
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
                            if (_numberDosesController.text.isEmpty ||
                                _numberWeeksUsedController.text.isEmpty ||
                                _numberWeeksQuitController.text.isEmpty ||
                                _selectedSeason == null) {
                              _showAlert3(context);
                            } else {
                              _submitData();
                            }
                          },
                          child: const Text(
                            'Submit',
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

  void _Output_crop_health(BuildContext context, String cropDamageResult) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Level of crop damage:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  cropDamageResult,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              builder: (context) => const CropHealthFarmer()),
                        );
                      },
                      child: const Text(
                        'Back',
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
                        _saveData(
                          widget.insectCount,
                          widget.cropType,
                          widget.soilType,
                          widget.pesticideUseCategory,
                          _numberDosesController.text,
                          _numberWeeksUsedController.text,
                          _numberWeeksQuitController.text,
                          _selectedSeason!,
                          cropDamageResult,
                        );
                        _showAlert(context);
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
        );
      },
    );
  }

  void _saveData(
      String insectCount,
      String cropType,
      String soilType,
      String pesticideUseCategory,
      String numberDoses,
      String numberWeeksUsed,
      String numberWeeksQuit,
      String season,
      String cropDamageResult) {
    FirebaseFirestore.instance.collection('CropHealth').add({
      'Estimated_Insects_Count': insectCount,
      'Crop_Type': cropType,
      'Soil_Type': soilType,
      'Pesticide_Use_Category': pesticideUseCategory,
      'Number_Doses_Week': numberDoses,
      'Number_Weeks_Used': numberWeeksUsed,
      'Number_Weeks_Quit': numberWeeksQuit,
      'Season': season,
      'Crop_Damage': cropDamageResult,
    });
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
              fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF344E41)),
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
