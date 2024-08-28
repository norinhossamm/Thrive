import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'menu.dart';
import 'history.dart' as history;

class UploadAndTake2 extends StatefulWidget {
  UploadAndTake2({super.key});

  @override
  State<UploadAndTake2> createState() => _UploadAndTake2State();
}

class _UploadAndTake2State extends State<UploadAndTake2> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageName;
  img.Image? _displayImage;
  bool _saveToDatabase = false;
  bool _showCheckbox = false; // Flag to control the visibility of the checkbox
  List<dynamic>? _detections;
  bool _isLoading = false; // Flag to control the loading animation

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  void _showPictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PictureOptions(
        onPictureSelected: (XFile image, bool showCheckbox) {
          setState(() {
            _image = image;
            _imageName = image.name;
            _displayImage = img.decodeImage(File(image.path).readAsBytesSync());
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
        _imageName = image.name;
        _displayImage = img.decodeImage(File(image.path).readAsBytesSync());
        _showCheckbox = true; // Show checkbox when image is taken from camera
      });
    }
  }

  void _navigateToGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _imageName = image.name;
        _displayImage = img.decodeImage(File(image.path).readAsBytesSync());
        _showCheckbox = false; // Hide checkbox when image is selected from gallery
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading animation
    });

    final request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/Ripeness'));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      setState(() {
        _detections = decodedResponse;
        _isLoading = false; // Hide loading animation
      });

      if (_detections != null && _detections!.isNotEmpty) {
        _drawBoundingBoxes();

        if (_saveToDatabase) {
          await _uploadToFirebase();
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              image: _displayImage!,
              imageName: _imageName!,
              detections: _detections!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No detections found.')),
        );
      }
    } else {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
      print('Failed to upload image');
    }
  }

  Future<void> _uploadToFirebase() async {
    try {
      if (_image != null) {
        File file = File(_image!.path);
        await FirebaseStorage.instance
            .ref('Ripeness_ForEnhancement/${DateTime.now().millisecondsSinceEpoch}.jpg')
            .putFile(file);
      }
    } catch (e) {
      print('Failed to upload to Firebase: $e');
    }
  }

  void _drawBoundingBoxes() {
    if (_displayImage == null || _detections == null) return;

    img.Image drawImage = img.copyResize(_displayImage!, width: _displayImage!.width, height: _displayImage!.height);

    for (var detection in _detections!) {
      var box = detection['box'];
      if (box.length == 1 && box[0].length == 4) {
        box = box[0]; // Flatten the nested list
      }
      if (box.length == 4) {
        var x1 = box[0];
        var y1 = box[1];
        var x2 = box[2];
        var y2 = box[3];
        var color = detection['color'];

        // Convert color to the correct format
        int colorValue = img.getColor(color[0], color[1], color[2]);

        // Draw thinner bounding box by drawing fewer rectangles
        for (int i = 0; i < 30; i++) {
          img.drawRect(drawImage, x1.toInt() - i, y1.toInt() - i, x2.toInt() + i, y2.toInt() + i, colorValue);
        }
      } else {
        print('Invalid bounding box format: $box');
      }
    }

    setState(() {
      _displayImage = drawImage;
    });
  }

  void _handleSubmit() {
    _uploadImage();
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
                  if (_imageName != null)
                    Text(
                      _imageName!,
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
                          style: TextStyle(fontSize: 14),
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
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
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
              XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
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
              XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
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

class ResultScreen extends StatelessWidget {
  final img.Image image;
  final String imageName;
  final List<dynamic> detections;

  ResultScreen({required this.image, required this.imageName, required this.detections});

  @override
  Widget build(BuildContext context) {
    // Create a set to store unique classes
    final uniqueClasses = detections.map((d) => d['class']).toSet();

    // Create a map to store class colors
    final classColors = {
      for (var detection in detections) detection['class']: detection['color']
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detection Result',
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.memory(Uint8List.fromList(img.encodeJpg(image))),
              const SizedBox(height: 20),
              Text(
                imageName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: uniqueClasses.map((className) => Row(
                    children: <Widget>[
                      Container(
                        width: 20,
                        height: 20,
                        color: Color.fromARGB(
                          255,
                          classColors[className][0],
                          classColors[className][1],
                          classColors[className][2],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(className, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500)),
                    ],
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF344E41)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
