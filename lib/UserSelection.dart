import 'package:flutter/material.dart';

class SelectedFarm with ChangeNotifier {
  String? _selectedFarm;

  String? get selectedFarm => _selectedFarm;

  void setSelectedFarm(String? farm) {
    _selectedFarm = farm;
    notifyListeners();
  }
}
