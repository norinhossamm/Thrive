import 'package:flutter/material.dart';
import 'menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

void main() => runApp(upload_and_take());

class upload_and_take extends StatefulWidget {
  upload_and_take({super.key});

  @override
  State<upload_and_take> createState() => _upload_and_takeState();
}

class _upload_and_takeState extends State<upload_and_take> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _saveToDatabase = false;
  bool _isLoading = false;
  bool _showCheckbox = false; // Flag to control the visibility of the checkbox

  void _showPictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PictureOptions(
        onPictureSelected: (XFile image, bool showCheckbox) {
          setState(() {
            _image = image;
            _showCheckbox = showCheckbox;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
        _showCheckbox = true; // Show checkbox when image is taken from camera
      });
    }
  }

  void _navigateToGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _showCheckbox = false; // Hide checkbox when image is selected from gallery
      });
    }
  }

  void _handleSubmit() async {
    if (_image == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Missing Information',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red),
          ),
          backgroundColor: Colors.white,
          content: const Text('Please upload or take a photo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      String? predictionResult = await _sendImageForPrediction(File(_image!.path));

      if (predictionResult != null) {
        _showPredictionResult(predictionResult);
        if (_saveToDatabase) {
          await _saveImageToFirebase(File(_image!.path));
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _sendImageForPrediction(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:5000/LeafDisease'), // Adjust the URL accordingly
      );
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['prediction']; // Assuming 'prediction' is the key in the response
      } else {
        print('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<void> _saveImageToFirebase(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('LeafDisease_ForEnhancement/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      print('Image uploaded to Firebase Storage');
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  void _showPredictionResult(String predictionResult) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SizedBox(
          height: 235,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Leaf Disease Classification:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  predictionResult,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => upload_and_take()),
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload or Take picture',
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
      drawer: NavDrawer(),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        onTap: _showPictureOptions,
                        child: Container(
                          width: 500,
                          height: 350,
                          child: _image != null
                              ? Image.file(
                            File(_image!.path),
                            fit: BoxFit.contain,
                            width: 500,
                            height: 350,
                          )
                              : Image.asset(
                            "assets/13.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_image != null)
                    Text(
                      _image!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF344E41),
                        ),
                        child: IconButton(
                          onPressed: _navigateToCamera,
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF344E41),
                        ),
                        child: IconButton(
                          onPressed: _navigateToGallery,
                          icon: const Icon(Icons.photo_library),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_showCheckbox)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _saveToDatabase,
                          onChanged: (value) {
                            setState(() {
                              _saveToDatabase = value!;
                            });
                          },
                          activeColor: const Color(0xFF344E41),
                        ),
                        const Text(
                          'Allow this image to be used for enhancing the model',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 20, color: Colors.white),
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class PictureOptions extends StatefulWidget {
  final Function(XFile, bool) onPictureSelected;

  PictureOptions({required this.onPictureSelected});

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
            leading: const Icon(Icons.camera_alt),
            iconColor: const Color(0xFF344E41),
            title: const Text('Take from Camera'),
            onTap: () async {
              XFile? image =
              await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                widget.onPictureSelected(image, true);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            iconColor: const Color(0xFF344E41),
            title: const Text('Select from Gallery'),
            onTap: () async {
              XFile? image =
              await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                widget.onPictureSelected(image, false);
              }
            },
          ),
        ],
      ),
    );
  }
}

void _showAlert1(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Saved Image",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF344E41)),
        ),
        backgroundColor: Colors.white,
        content: const Text("Your Image is Saved."),
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
