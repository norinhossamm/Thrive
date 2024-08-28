import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menu.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart' as pdfPackage;
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart' as pdfWidgets;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'UserSelection.dart';


class PricingPredictionScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String selectedItem;

  const PricingPredictionScreen({
    required this.startDate,
    required this.endDate,
    required this.selectedItem,
  });

  @override
  _PricingPredictionScreenState createState() => _PricingPredictionScreenState();
}

class _PricingPredictionScreenState extends State<PricingPredictionScreen> {
  late Future<void> _fetchDataFuture;

  //Forecast graph
  Map<String, dynamic> forecastGraph = {};
  List<FOBData> FOBForecastData = [];
  double maxYAxisValue = 0;

  //Forecast data
  List<Map<String, dynamic>> forecastData = [];
  String forecastTitle = "";

  //History graph
  Map<String, dynamic> FOBHistoryGraph = {}; // Dictionary that has inner properties year yield
  // List to hold year and mean yield data for history graph
  List<HistoryData> FOBHistoryData = [];

  //Average yield for date range
  double average_FOB = 0;
  double max_FOB = 0;
  double min_FOB = 0;

  //Report content
  final PdfService mypdf = PdfService(); //Class name
  List<Map<String, dynamic>> PDFdata = [];


  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  Future<void> logAction(String actionType, Map<String, dynamic> requestData, Map<String, dynamic> responseData, String selectedItem) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference logs = FirebaseFirestore.instance.collection('Logs');
      await logs.add({
        'userId': user.uid,
        'farmName': Provider.of<SelectedFarm>(context, listen: false).selectedFarm,
        'actionType': actionType,
        'requestData': requestData,
        'responseData': responseData,
        'CropType': selectedItem,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> fetchData() async {
    try {
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(widget.startDate);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(widget.endDate);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/Price'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {

          //Forecast graph
          forecastGraph = data['forecast_graph_data'];
          List<dynamic> daymonth = forecastGraph['daymonth'];
          List<dynamic> FOB = forecastGraph['FOB'];
          FOBForecastData = List.generate(
            daymonth.length,
                (index) => FOBData(daymonth[index], FOB[index].toDouble()),
          );
          maxYAxisValue = FOBForecastData.map((data) => data.FOB).reduce((value, element) => value > element ? value : element);
          maxYAxisValue = maxYAxisValue.ceil().toDouble();

          //Forecast data
          forecastTitle = data['forecast_title'];
          forecastData = List<Map<String, dynamic>>.from(data['forecast_data']);

          //History area graph content - GRAPH
          FOBHistoryGraph = data['FOB_history_graph_data'];
          List<dynamic> Year = FOBHistoryGraph['Year'];
          List<dynamic> Mean_FOB = FOBHistoryGraph['Mean FOB'];
          //Combine year and mean yield into yieldHistoryData
          FOBHistoryData = List.generate(
            Year.length,
                (index) => HistoryData(Year[index], Mean_FOB[index]),
          );

          //Statistics for date range (average, max , min)
          average_FOB = data['average_FOB'];
          max_FOB = data['max_FOB'];
          min_FOB = data['min_FOB'];

          //Report content
          PDFdata = List<Map<String, dynamic>>.from(data['pdf_data']);
        });
        //Add to logs
        await logAction('PricePrediction', {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
          data,
          widget.selectedItem,
        );


      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {// Calculate the interval dynamically
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Price Forecast',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF344E41),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16), // Add padding from the left side
                      child: Row(
                        children: [
                          Icon(Icons.area_chart_rounded, size: 24, color: Colors.black), // Icon for the forecast graph
                          SizedBox(width: 8), // Space between the icon and the title
                          Text(
                            'FORECAST GRAPH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    //Area forecast graph
                    Container(
                      padding: EdgeInsets.all(10.0), //Padding of 10
                      height: 280, //Graph height
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0), // Hide vertical grid lines
                            labelPlacement: LabelPlacement.onTicks, // To have labels on every tick
                            // Specify interval for the x-axis to ensure exactly 5 ticks
                            interval: (FOBForecastData.length / 5).ceil().toDouble(),
                          ),
                          primaryYAxis: NumericAxis( //Y axis options
                            maximum: maxYAxisValue, //The extent of y axis [max+5]
                            // interval: (maxYAxisValue + 2) / 2,
                            majorTickLines: MajorTickLines(width: 0), // Remove tick lines on y
                          ),
                          tooltipBehavior: TooltipBehavior( // Touch tool options
                            enable: true,
                            tooltipPosition: TooltipPosition.pointer,
                            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                              return Container(
                                color: Colors.white, // Set the color of the tooltip to white
                                child: Padding(
                                  padding: EdgeInsets.all(8.0), // Padding between values in tooltip
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Date: ${forecastGraph['tooltip'][pointIndex]}',
                                        style: TextStyle(color: Colors.black), // Set the text color to black
                                      ), // Display the date from the tooltip variable
                                      SizedBox(height: 5), // Spacing of 5 between date and yield
                                      Text(
                                        'FOB: ${data.FOB.toStringAsFixed(2)} ',
                                        style: TextStyle(color: Colors.black), // Set the text color to black
                                      ), // Display the yield value with 2 decimal places
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          series: <CartesianSeries>[
                            AreaSeries<FOBData, String>( //Area graph
                              animationDuration: 0.0,
                              dataSource: FOBForecastData,
                              xValueMapper: (FOBData data, _) => data.daymonth,
                              yValueMapper: (FOBData data, _) => data.FOB,
                              color: Colors.green,
                              opacity:0.3, // Lighter shade with reduced opacity
                            ),
                            LineSeries<FOBData, String>( //Line graph
                              animationDuration: 0.0,
                              dataSource: FOBForecastData,
                              xValueMapper: (FOBData data, _) => data.daymonth,
                              yValueMapper: (FOBData data, _) => data.FOB,
                              color: Colors.green.shade600, // Darker color for the line graph
                              width: 3.5, // Width of the line
                            ),
                          ]
                      ),
                    ),


                    SizedBox(height: 25),

                    //Top 10 / All records data
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: forecastData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (index == 0) ...[
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today_sharp, size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  forecastTitle.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(height: 8, color: Colors.transparent),
                                          ],
                                          if (index != 0)
                                            Divider(height: 8, color: Colors.transparent),
                                          Divider(height: 1, color: Colors.black.withOpacity(0.2)),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                data['Date'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                '${data['FOB']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    Padding(
                      padding: EdgeInsets.only(left: 16), // Add padding from the left side
                      child: Row(
                        children: [
                          Icon(Icons.show_chart_sharp, size: 24, color: Colors.black), // Icon for the forecast graph
                          SizedBox(width: 8), // Space between the icon and the title
                          Text(
                            'HISTORY GRAPH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    //Area history graph
                    Container(
                      padding: EdgeInsets.all(10.0), //Padding of 10
                      height: 300, //Graph height
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0), // Hide vertical grid lines
                            labelPlacement: LabelPlacement.onTicks, //To have value of x axis on every tick
                            //Specify interval for the x axis
                            interval: (FOBHistoryData.length / 5).ceil().toDouble() > 0
                                ? (FOBHistoryData.length / 5).ceil().toDouble()
                                : null, // Ensure labels are positioned directly on the ticks
                          ),
                          primaryYAxis: NumericAxis(
                            //Min and max values on y axis
                            minimum: 1,
                            maximum: 1.8,
                            majorTickLines: MajorTickLines(width: 0), // Remove y-axis major tick lines
                          ),
                          tooltipBehavior: TooltipBehavior( //Touch tool options
                            color:Colors.white,
                            enable: true,
                            tooltipPosition: TooltipPosition.pointer,
                            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                              return Padding(
                                padding: EdgeInsets.all(8.0), //Padding between text in touch tool
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [ //Text in touch tool
                                    Text('Year: ${FOBHistoryGraph['Year'][pointIndex]}', style: TextStyle(color: Colors.black)), // Display the date from tooltip variable
                                    SizedBox(height: 5), //Spacing of 5
                                    Text('Yield: ${data.Mean_FOB.toStringAsFixed(2)}', style: TextStyle(color: Colors.black)), // Display the yield value with 2 decimal places
                                  ],
                                ),
                              );
                            },
                          ),
                          series: <CartesianSeries>[
                            LineSeries<HistoryData, String>( //Line graph
                              dataSource: FOBHistoryData,
                              xValueMapper: (HistoryData data, _) => data.Year,
                              yValueMapper: (HistoryData data, _) => data.Mean_FOB,
                              color: Colors.green.shade600, // Darker color for the line graph
                              width: 3.5, // Width of the line
                              markerSettings: MarkerSettings(isVisible: true), // Show markers at each data point
                            ),
                          ]
                      ),
                    ),

                    SizedBox(height: 25),

                    //Report
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final data = await mypdf.generatepdf(PDFdata, average_FOB, max_FOB, min_FOB);
                          mypdf.savepdfile("PriceReport", data);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Report',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 5), // Adjust spacing between text and icon
                            Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                          ],
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
            );
          }
        },
      ),
    );
  }
}

//Class for forecast graph
class FOBData {
  final String daymonth;
  final double FOB;

  FOBData(this.daymonth, this.FOB);
}

//Class for history graph
class HistoryData {
  HistoryData(this.Year, this.Mean_FOB);
  final String Year;
  final dynamic Mean_FOB;
}

//Class for PDF
class PdfService {
  Future<Uint8List> generatepdf(List<Map<String, dynamic>> pdfData, double averageFOB, double maxFOB, double minFOB) async {
    final pdf = pdfWidgets.Document();

    // Format average, max, and min yield values to two decimal places
    String formattedAverageFOB = averageFOB.toStringAsFixed(2);
    String formattedMaxFOB = maxFOB.toStringAsFixed(2);
    String formattedMinFOB = minFOB.toStringAsFixed(2);

    // Define table headers
    List<String> headers = ['Date', 'FOB'];

    // Add header with title, date, average, max, and min yield values at the top of the first page
    pdf.addPage(
      pdfWidgets.MultiPage(
        pageFormat: pdfPackage.PdfPageFormat.a4,
        build: (context) {
          return [
            pdfWidgets.Container(
              margin: pdfWidgets.EdgeInsets.only(top: 5),
              child: pdfWidgets.Column(
                crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                children: [
                  pdfWidgets.Row(
                    crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                    mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                    children: [
                      // Title with words stacked vertically
                      pdfWidgets.Column(
                        crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                        children: [
                          pdfWidgets.SizedBox(height: 20),
                          pdfWidgets.Text(
                            'Daily Price',
                            style: pdfWidgets.TextStyle(fontSize: 40, fontWeight: pdfWidgets.FontWeight.bold, color: pdfWidgets.PdfColors.black),
                          ),
                          pdfWidgets.Text(
                            'Report',
                            style: pdfWidgets.TextStyle(fontSize: 40, fontWeight: pdfWidgets.FontWeight.bold, color: pdfWidgets.PdfColors.black),
                          ),
                        ],
                      ),
                      // Spacing between title and date, average, max, and min yield values
                      pdfWidgets.SizedBox(width: 20),
                      // Date, average, max, and min yield values positioned on top of each other to the right of the title
                      pdfWidgets.Column(
                        crossAxisAlignment: pdfWidgets.CrossAxisAlignment.end,
                        children: [
                          pdfWidgets.SizedBox(height: 50),
                          pdfWidgets.Text('Average FOB: $formattedAverageFOB', style: pdfWidgets.TextStyle(fontSize: 19, fontWeight: pdfWidgets.FontWeight.bold)),
                          pdfWidgets.Text('Maximum FOB: $formattedMaxFOB', style: pdfWidgets.TextStyle(fontSize: 19, fontWeight: pdfWidgets.FontWeight.bold)),
                          pdfWidgets.Text('Minimum FOB: $formattedMinFOB', style: pdfWidgets.TextStyle(fontSize: 19, fontWeight: pdfWidgets.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  pdfWidgets.SizedBox(height: 20), // Add spacing
                ],
              ),
            ),
            pdfWidgets.Table.fromTextArray(
              border: pdfWidgets.TableBorder.all(color: pdfWidgets.PdfColors.black),
              headerDecoration: pdfWidgets.BoxDecoration(color: pdfWidgets.PdfColors.grey300),
              data: [headers, ...pdfData.take(18).map((data) => [data['Date'], data['FOB']])], // Display first 18 rows of data
              cellAlignment: pdfWidgets.Alignment.center,
              headerStyle: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold, color: pdfWidgets.PdfColors.black), // Increase font size and add bold to table headers
              cellStyle: pdfWidgets.TextStyle(fontSize: 16, color: pdfWidgets.PdfColors.black), // Increase font size for table cells
            ),
          ];
        },
      ),
    );

    // Calculate the number of pages needed to display all data
    int remainingRowCount = pdfData.length - 18;
    int pageCount = (remainingRowCount / 23).ceil();

    // Add subsequent pages with table data (23 rows per page)
    for (var i = 0; i < pageCount; i++) {
      pdf.addPage(
        pdfWidgets.MultiPage(
          pageFormat: pdfPackage.PdfPageFormat.a4,
          build: (context) {
            return [
              pdfWidgets.Table.fromTextArray(
                border: pdfWidgets.TableBorder.all(color: pdfWidgets.PdfColors.black),
                headerDecoration: pdfWidgets.BoxDecoration(color: pdfWidgets.PdfColors.grey300),
                data: [headers, ...pdfData.skip(18 + i * 23).take(23).map((data) => [data['Date'], data['FOB']])], // Skip rows already displayed on previous pages
                cellAlignment: pdfWidgets.Alignment.center,
                headerStyle: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold, color: pdfWidgets.PdfColors.black), // Increase font size and add bold to table headers
                cellStyle: pdfWidgets.TextStyle(fontSize: 16, color: pdfWidgets.PdfColors.black), // Increase font size for table cells
              ),
            ];
          },
        ),
      );
    }
    return pdf.save();
  }

  Future<void> savepdfile(String filename, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filepath = "${output.path}/$filename.pdf";
    final file = File(filepath);
    await file.writeAsBytes(byteList);
    await OpenFile.open(filepath);
  }
}













