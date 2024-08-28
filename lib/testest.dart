import 'package:flutter/material.dart';
import 'menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'history.dart';

void main() => runApp(upload_and_take2());

class upload_and_take2 extends StatefulWidget {
  upload_and_take2({super.key});

  @override
  State<upload_and_take2> createState() => _upload_and_take2State();
}

class _upload_and_take2State extends State<upload_and_take2> {
  // ignore: unused_field
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _saveToDatabase = false;

  void _showPictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PictureOptions(
        onPictureSelected: (XFile image) {
          setState(() {
            _image = image;
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
      });
    }
  }

  void _navigateToGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _handleSubmit() {
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
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => output_ripe(imagePath: _image?.path)),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const history()),
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
                          color: const Color(0xFF344E41),
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
                          color: const Color(0xFF344E41),
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
                        'Allow this image to be used for echancing the model',
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
        ],
      ),
    );
  }
}

class PictureOptions extends StatefulWidget {
  final Function(XFile) onPictureSelected;

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
                widget.onPictureSelected(image);
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
                widget.onPictureSelected(image);
              }
            },
          ),
        ],
      ),
    );
  }
}

class output_ripe extends StatefulWidget {
  final String? imagePath;

  output_ripe({this.imagePath, super.key});

  @override
  State<output_ripe> createState() => _output_ripeState();
}

class _output_ripeState extends State<output_ripe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ripeness Level Detection',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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
                  MaterialPageRoute(builder: (context) => const history()),
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
                        Container(
                          width: 500,
                          height: 350,
                          child: widget.imagePath != null
                              ? Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.contain,
                            width: 500,
                            height: 350,
                          )
                              : const Text('No image selected'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ripe: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Unripe: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Half-ripe: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                  builder: (context) => upload_and_take2()),
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
                            _showAlert1(context);
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
