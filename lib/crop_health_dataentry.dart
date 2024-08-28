import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menudataentry.dart';
import 'historydataentry.dart';

void main() => runApp(const CropHealthdataentry());

class CropHealthdataentry extends StatefulWidget {
  const CropHealthdataentry({super.key});

  @override
  State<CropHealthdataentry> createState() => _CropHealthdataentryState();
}

class _CropHealthdataentryState extends State<CropHealthdataentry> {
  String? _selectedCropType;
  String? _selectedSoilType;
  String? _selectedPesticideUseCategory;
  final TextEditingController _insectCountController = TextEditingController();

  @override
  void dispose() {
    _insectCountController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (_insectCountController.text.isNotEmpty &&
        _selectedCropType != null &&
        _selectedSoilType != null &&
        _selectedPesticideUseCategory != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropHealthdataentry2(
            cropType: _selectedCropType!,
            soilType: _selectedSoilType!,
            pesticideUseCategory: _selectedPesticideUseCategory!,
            insectCount: _insectCountController.text,
          ),
        ),
      );
    } else {
      _showAlert3(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Health Data',
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
                      items: <String>['Rabi', 'Kharif']
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
                      items: <String>['Alluvial', 'Black-Cotton']
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
                      dropdownColor: const Color(0xFFFFFFFFF),
                      items: <String>[
                        'Herbicides',
                        'Bactericides',
                        'Insecticides'
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _navigateToNextScreen,
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

class CropHealthdataentry2 extends StatefulWidget {
  final String cropType;
  final String soilType;
  final String pesticideUseCategory;
  final String insectCount;

  const CropHealthdataentry2({
    super.key,
    required this.cropType,
    required this.soilType,
    required this.pesticideUseCategory,
    required this.insectCount,
  });

  @override
  State<CropHealthdataentry2> createState() => _CropHealthdataentry2State();
}

class _CropHealthdataentry2State extends State<CropHealthdataentry2> {
  String? _selectedSeason;
  String? _selectedCropDamage;
  final _numberDosesController = TextEditingController();
  final _numberWeeksUsedController = TextEditingController();
  final _numberWeeksQuitController = TextEditingController();

  @override
  void dispose() {
    _numberDosesController.dispose();
    _numberWeeksUsedController.dispose();
    _numberWeeksQuitController.dispose();
    super.dispose();
  }

  Future<void> _saveDataToFirestore() async {
    if (_numberDosesController.text.isNotEmpty &&
        _numberWeeksUsedController.text.isNotEmpty &&
        _numberWeeksQuitController.text.isNotEmpty &&
        _selectedSeason != null &&
        _selectedCropDamage != null) {
      await FirebaseFirestore.instance.collection('CropHealthData').add({
        'crop_type': widget.cropType,
        'estimated_insects_count': widget.insectCount,
        'soil_type': widget.soilType,
        'pesticide_use_category': widget.pesticideUseCategory,
        'number_doses_week': _numberDosesController.text,
        'number_weeks_used': _numberWeeksUsedController.text,
        'number_weeks_quit': _numberWeeksQuitController.text,
        'season': _selectedSeason,
        'crop_damage': _selectedCropDamage,
      });
      _showAlert(context);
    } else {
      _showAlert3(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Health Data',
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
                    child: TextFormField(
                      controller: _numberDosesController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number Doses Week',
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
                      controller: _numberWeeksUsedController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number Weeks Used',
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
                      controller: _numberWeeksQuitController,
                      enableInteractiveSelection: false,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number Weeks Quit',
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
                      value: _selectedSeason,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSeason = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFFFFFFFF),
                      items: <String>['Summer', 'Monsoon', 'Winter']
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
                      value: _selectedCropDamage,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCropDamage = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFFFFFFFF),
                      items: <String>[
                        'Minimal Damage',
                        'Partial Damage',
                        'Significant Damage'
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
                        labelText: 'Crop Damage',
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
                                const CropHealthdataentry()),
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
                        onPressed: _saveDataToFirestore,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CropHealthdataentry()),
              );
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red),
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
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
