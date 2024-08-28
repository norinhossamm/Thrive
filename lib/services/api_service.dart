import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/bounding_box.dart';

Future<List<BoundingBox>> fetchBoundingBoxes(File imageFile) async {
  var uri = Uri.parse('http://10.0.2.2:5000/detect'); // Replace with your API URL
  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    List<dynamic> boxesJson = jsonDecode(responseData) as List<dynamic>;
    return boxesJson.map((json) => BoundingBox.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bounding boxes');
  }
}
