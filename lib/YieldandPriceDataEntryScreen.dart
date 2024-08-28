import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'historydataentry.dart';
import 'menudataentry.dart';

class YieldAndPriceDataEntryScreen extends StatefulWidget {
  const YieldAndPriceDataEntryScreen({Key? key}) : super(key: key);

  @override
  _YieldAndPriceDataEntryScreenState createState() =>
      _YieldAndPriceDataEntryScreenState();
}

class _YieldAndPriceDataEntryScreenState
    extends State<YieldAndPriceDataEntryScreen> {
  bool _isExpanded = false;
  TextEditingController yieldController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Future<void> saveYieldData() async {
    if (yieldController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Missing Information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const Text(
            "Please fill Yield field.",
            style: TextStyle(fontSize: 15),
          ),
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
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('YieldData').add({
        'yield': yieldController.text,
        'date': DateTime.now(),
      });
      yieldController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yield data saved successfully!')),
      );
    }
  }

  Future<void> savePriceData() async {
    if (priceController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Missing Information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const Text(
            "Please fill Price field.",
            style: TextStyle(fontSize: 15),
          ),
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
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('PriceData').add({
        'price': priceController.text,
        'date': DateTime.now(),
      });
      priceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Price data saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Yield and Price Data',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/nora10.jpeg"),
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF344E41),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.grass,
                      color: _isExpanded ? Color(0xFF344E41) : Colors.white,
                    ),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    title: const Text(
                      'Enter Yield Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isExpanded = value;
                      });
                    },
                    children: [
                      ListTile(
                        iconColor: Colors.white,
                        title: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: yieldController,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.grass,
                              color: Colors.white,
                            ),
                            hintText: "Enter Yield in Pounds",
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: saveYieldData,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, // Text color
                            side:
                            BorderSide(color: Colors.black), // Border color
                            elevation: _isExpanded
                                ? 4
                                : 0, // Apply elevation and shadow when clicked
                            shadowColor:
                            Color(0xFF344E41), // Shadow color when clicked
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF344E41),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: _isExpanded ? Color(0xFF344E41) : Colors.white,
                    ),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    title: const Text(
                      'Enter Price Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isExpanded = value;
                      });
                    },
                    children: [
                      ListTile(
                        title: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: priceController,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.white,
                            ),
                            hintText: "Enter price per Pounds",
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: savePriceData,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, // Text color
                            side:
                            BorderSide(color: Colors.black), // Border color
                            elevation: _isExpanded
                                ? 4
                                : 0, // Apply elevation and shadow when clicked
                            shadowColor:
                            Color(0xFF344E41), // Shadow color when clicked
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
