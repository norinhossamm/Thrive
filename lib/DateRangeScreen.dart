import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'YieldPredictionScreen.dart';
import 'PricingPredictionScreen.dart';
import 'menu.dart';
import 'history.dart';

DateTime selectedDateTimeStart = DateTime(2023, 1, 1);
DateTime selectedDateTimeEnd = DateTime(2023, 1, 1);

class DateRangeScreen extends StatefulWidget {
  const DateRangeScreen({Key? key});

  @override
  _DateRangeScreenState createState() => _DateRangeScreenState();
}

class _DateRangeScreenState extends State<DateRangeScreen> {
  List<String> items1 = ["Yield Forecast", "Price Forecast"];
  String selectedItem1 = "Yield Forecast";

  List<String> items2 = [];
  String? selectedItem2;  // Change to nullable type

  DateTime tempDateTimeStart = selectedDateTimeStart;
  DateTime tempDateTimeEnd = selectedDateTimeEnd;

  @override
  void initState() {
    super.initState();
    fetchCropNames();
  }

  Future<void> fetchCropNames() async {
    try {
      CollectionReference dropdown = FirebaseFirestore.instance.collection('Dropdown');
      DocumentSnapshot snapshot = await dropdown.doc('Crops').get();
      if (snapshot.exists) {
        setState(() {
          items2 = List<String>.from(snapshot['cropNames']);
          selectedItem2 = items2.first;  // Set the first item as the default selection
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yield and Price Forecast',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/nora10.jpeg'),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 220,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      color: Colors.transparent, // Set the background color to transparent
                    ),
                    child: DropdownButton(
                      value: selectedItem1,
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.black, // Set the icon color to white
                      ),
                      iconSize: 20,
                      elevation: 16,
                      underline: Container(), // Remove the underline
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black, // Set text color to white
                      ),
                      dropdownColor: Colors.white, // Set dropdown menu background color to green
                      items: items1.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black, // Set text color to white
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedItem1 = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Container(
                alignment: Alignment.center,
                width: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  color: Colors.transparent, // Set the background color to transparent
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    'Crop Type',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  value: selectedItem2,
                  icon: Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Colors.black, // Set the icon color to white
                  ),
                  iconSize: 20,
                  elevation: 16,
                  underline: Container(), // Remove the underline
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black, // Set text color to white
                  ),
                  dropdownColor: Colors.white, // Set dropdown menu background color to green
                  items: items2.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black, // Set text color to white
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItem2 = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: Container(
                      height: 55, // Increase the height of the container
                      child: TextFormField(
                        readOnly: true,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                        controller: TextEditingController(
                            text: '${selectedDateTimeStart.day} - ${selectedDateTimeStart.month} - ${selectedDateTimeStart.year}'
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              content: Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 1.0,
                                      height: MediaQuery.of(context).size.height * 0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: CupertinoDatePicker(
                                        backgroundColor: Colors.white,
                                        initialDateTime: selectedDateTimeStart,
                                        onDateTimeChanged: (DateTime newTimeStart) {
                                          setState(() {
                                            tempDateTimeStart = newTimeStart;
                                          });
                                        },
                                        use24hFormat: true,
                                        mode: CupertinoDatePickerMode.date,
                                        minimumYear: 2023,
                                        maximumYear: 2024,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedDateTimeStart = tempDateTimeStart;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Set',
                                            style: TextStyle(
                                              color: Color(0xFF344E41),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Start Date',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                          contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0), // Adjust content padding
                          // Adjust text alignment
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: Container(
                      height: 55, // Increase the height of the container
                      child: TextFormField(
                        readOnly: true,
                        enableInteractiveSelection: false,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                        controller: TextEditingController(
                            text: '${selectedDateTimeEnd.day} - ${selectedDateTimeEnd.month} - ${selectedDateTimeEnd.year}'
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              content: Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 1.0,
                                      height: MediaQuery.of(context).size.height * 0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: CupertinoDatePicker(
                                        backgroundColor: Colors.white,
                                        initialDateTime: selectedDateTimeEnd,
                                        onDateTimeChanged: (DateTime newTimeEnd) {
                                          setState(() {
                                            tempDateTimeEnd = newTimeEnd;
                                          });
                                        },
                                        use24hFormat: true,
                                        mode: CupertinoDatePickerMode.date,
                                        minimumYear: 2023,
                                        maximumYear: 2024,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedDateTimeEnd = tempDateTimeEnd;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Set',
                                            style: TextStyle(
                                              color: Color(0xFF344E41),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'End Date',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                          contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0), // Adjust content padding
                          // Adjust text alignment
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 50,
              ),
              Center(
                child: Container(
                  width: 140,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF344E41), // Text color
                    ),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (selectedItem1 == null || selectedItem2 == null) {
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
                                  child: Text(
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
                      } else if (selectedItem2 == "Raspberry" || selectedItem2 == "Blueberry") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Prediction Unavailable",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              backgroundColor: Colors.white,
                              content: Text(
                                "Incomplete data for the chosen crop. Predictions will be available once the data is updated.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (selectedDateTimeEnd.isBefore(selectedDateTimeStart)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Invalid Date Range",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              content: Text(
                                "Please make sure the end date is after the start date.",
                                style: TextStyle(fontSize: 15),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
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
                      } else {
                        if (selectedItem1 == "Price Forecast") {
                          // Check if start and end dates have different years
                          if (selectedDateTimeStart.year != selectedDateTimeEnd.year) {
                            // Show alert dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Date Range Spans Different Years",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    "The price forecast works with different logics for 2023 and 2024, please input a date range within the same year.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // If start and end dates have the same year, navigate to PricingPredictionScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PricingPredictionScreen(
                                  startDate: selectedDateTimeStart,
                                  endDate: selectedDateTimeEnd,
                                  selectedItem: selectedItem2!,
                                ),
                              ),
                            );
                          }
                        }
                        else if (selectedItem1 == "Yield Forecast") {
                          // If the date range is valid, navigate to YieldPredictionScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YieldPredictionScreen(
                                startDate: selectedDateTimeStart,
                                endDate: selectedDateTimeEnd,
                                selectedItem: selectedItem2!,
                              ),
                            ),
                          );
                        }

                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
