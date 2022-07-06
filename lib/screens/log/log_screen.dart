import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contron/models/chart/chartdaymodel.dart';
import 'package:flutter_contron/models/chart/chartrangemodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final Color primaryColors = Color.fromARGB(255, 0, 140, 255);
  List<SalesDetails1> sales1 = [];
  List<SalesDetails2> sales2 = [];
  ChartDayModel? _chartDayModel;
  ChartRangeModel? _chartRangeModel;

  int sum_count = 0;
  double sum_avg = 0;
  DateTime? _dateTimeSeleceted;
  DateTimeRange? _selectedDateRange;
  void loadSalesData() {
    sum_count = 0;
    sum_avg = 0;
    sales1.clear();
    for (var item in _chartDayModel!.message) {
      sales1.add(SalesDetails1(
          //  DateFormat('yyyy-MM-dd – kk:mm').format(item.datalogTime).toString(),
          DateFormat('HH:mm').format(item.datalogTime).toString(),
          item.datalogTempavg.toString(),
          item.datalogCount.toString(),
          item.compair.toString()));
      sum_count = sum_count + item.datalogCount;
      sum_avg = sum_avg + item.datalogTempavg;
    }
    setState(() {});
  }

  void loadSalesRangeData() {
    sum_count = 0;
    sum_avg = 0;
    sales2.clear();
    for (var item in _chartRangeModel!.message) {
      sales2.add(SalesDetails2(
          DateFormat('yyyy-MM-dd').format(item.datalogTime).toString(),
          // DateFormat('HH:mm').format(item.datalogTime).toString(),

          item.datalogTempavg.toString(),
          item.datalogCount.toString(),
          item.compair.toString()));
      sum_count = sum_count + item.datalogCount;
      sum_avg = sum_avg + item.datalogTempavg;
    }
    setState(() {});
  }

  Future<void> getDataDay(dateTimeStart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userid = await prefs.getString('userId').toString();
    final data = {"date": "${dateTimeStart}"};

    final url =
        Uri.parse("https://sttslife-api.sttslife.co/datalog/date/date/$userid");

    try {
      var res = await http.post(url, body: data);
      if (res.statusCode == 200) {
        setState(() {
          _chartDayModel = chartDayModelFromJson(res.body);
        });
        print(jsonEncode(_chartDayModel!.message));
        loadSalesData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getDataRange(startdate, enddate) async {
    //final datastart_end = {"startdate": "${dateTimeStart}", "enddate": "${dateTimeend}"};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userid = await prefs.getString('userId').toString();
    final data = {"startdate": "${startdate}", "enddate": "${enddate}"};
    //final datastart_end = {"startdate": "${dateTimeStart}", "enddate": "${dateTimeend}"};
    print('data ======= ${data}');
    final url = Uri.parse(
        "https://sttslife-api.sttslife.co/datalog/range/daterange/$userid");
    try {
      var res = await http.post(url, body: data);
      if (res.statusCode == 200) {
        setState(() {
          _chartRangeModel = chartRangeModelFromJson(res.body);
        });

        loadSalesRangeData();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    sales1.clear();
    sales2.clear();
    super.dispose();
  }

  DateTime timeBackPressed = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWaring = difference >= Duration(seconds: 2);
        if (isExitWaring) {
          final message = 'Press back again to exit';
          Fluttertoast.showToast(msg: message, fontSize: 18);
          return false;
        } else {
          Fluttertoast.cancel();
          return true;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColors,
            centerTitle: true,
            bottom: const TabBar(
              // ส่วนของ tab
              tabs: [
                Tab(
                  icon: Icon(Icons.feed),
                  text: 'รายวัน',
                ),
                Tab(
                  icon: Icon(Icons.calendar_month_outlined),
                  text: 'กำหนดเอง',
                ),
              ],
            ),
            title: Text('ข้อมูลย้อนหลัง'),
          ),
          body: TabBarView(children: [
            tab1(),
            tab2(),
          ]),
        ),
      ),
    );
  }

  SingleChildScrollView tab1() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          SelectDay1(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ข้อมูลวันที่: '),
              Text(_dateTimeSeleceted != null
                  ? '${DateFormat('dd-MM-yyyy').format(_dateTimeSeleceted!).toString()}'
                  : 'คุณยังไม่ได้เลือกวันที่'),
            ],
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Text('จำนวนครั้ง = $sum_count'),
          //     // _chartDayModel != null
          //     //     ? Text(
          //     //         'AVG = ${(sum_avg / _chartDayModel!.message.length).toStringAsFixed(2)}')
          //     //     : Text('AVG = 0'),
          //     _chartDayModel != null
          //         ? Text(_chartDayModel!.message.length > 0
          //             ? 'อุณหภูมิเฉลี่ย = ${(sum_avg / _chartDayModel!.message.length).toStringAsFixed(2)}'
          //             : 'อุณหภูมิเฉลี่ย = 0')
          //         : Text('อุณหภูมิเฉลี่ย = 0'),
          //   ],
          // ),

          // Divider(
          //   thickness: 1,
          // ),
          // Padding(
          //     padding: const EdgeInsets.only(top: 15),
          //     child: SizedBox(
          //       height: 40,
          //       child: _chartDayModel == null
          //           ? Text(
          //               'ไม่มีข้อมูล',
          //               style: TextStyle(
          //                 color: Colors.red,
          //               ),
          //             )
          //           : Text(
          //               _chartDayModel!.message.length < 1 ? 'ไม่มีข้อมูล' : '',
          //               style: TextStyle(
          //                 color: Colors.red,
          //               ),
          //             ),
          //     )),
          _buildChart1(
            sales: sales1,
            dateTimeSeleceted: _dateTimeSeleceted.toString(),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView tab2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          SelectDay2(),
          _buildChart2(
            sales: sales2,
            dateTimeSeleceted: _dateTimeSeleceted.toString(),
          ),
        ],
      ),
    );
  }

  Padding SelectDay1() => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                ).then(
                  (value) {
                    if (value != null) {
                      setState(() {
                        _dateTimeSeleceted = value;
                      });
                      getDataDay(value);
                    }
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    'เลือกวันที่',
                    style: TextStyle(
                        color: primaryColors,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.date_range,
                    color: primaryColors,
                    size: 24,
                  )
                ],
              ),
            ),
          ],
        ),
      );
  Padding SelectDay2() => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                DateTimeRange? result = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2022, 1, 1), // the earliest allowable
                  lastDate: DateTime(2030, 12, 31), // the latest allowable
                  currentDate: DateTime.now(),
                  saveText: 'Done',
                );

                if (result != null) {
                  // Rebuild the UI
                  print(result.start.toString());
                  setState(() {
                    _selectedDateRange = result;
                  });
                }
                print(_selectedDateRange);
                if (_selectedDateRange!.start != _selectedDateRange!.end) {
                  print(_selectedDateRange);
                  final start = DateTime(
                      _selectedDateRange!.start.year,
                      _selectedDateRange!.start.month,
                      _selectedDateRange!.start.day);
                  final end = DateTime(
                      _selectedDateRange!.end.year,
                      _selectedDateRange!.end.month,
                      _selectedDateRange!.end.day);
                  getDataRange(start, end);
                }
              },
              child: Row(
                children: [
                  Text(
                    'เลือกวันที่',
                    style: TextStyle(
                        color: primaryColors,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.date_range,
                    color: primaryColors,
                    size: 24,
                  )
                ],
              ),
            ),
            // Text('Weak'),
            // Text('Month'),
            // Text('Year'),
          ],
        ),
      );
}

class _buildChart1 extends StatelessWidget {
  const _buildChart1({
    Key? key,
    required this.sales,
    required this.dateTimeSeleceted,
  }) : super(key: key);
  final String dateTimeSeleceted;
  final List<SalesDetails1> sales;

  @override
  Widget build(BuildContext context) {
    Future<bool?>? showWarning(context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure ?'),
              content: Text('do you want to exit an App'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Yes'),
                ),
              ],
            ));

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.width * 0.7,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
                labelRotation: 90, labelStyle: TextStyle(fontSize: 10)),
            enableSideBySideSeriesPlacement: false,
            series: [
              LineSeries<SalesDetails1, String>(
                dataSource: sales,
                xValueMapper: (SalesDetails1 details, _) => details.month,
                yValueMapper: (SalesDetails1 details, _) =>
                    double.parse(details.salesCount),
                width: 3, opacity: 0.9,
                // spacing: 0.2,
                name: 'จำนวนครั้ง',
                enableTooltip: true,
                markerSettings: MarkerSettings(isVisible: true),
              ),
              LineSeries<SalesDetails1, String>(
                dataSource: sales,
                xValueMapper: (SalesDetails1 details, _) => details.month,
                yValueMapper: (SalesDetails1 details, _) =>
                    int.parse(details.salesavg),
                opacity: 0.9,
                width: 3,
                name: 'อุณหภูมิเฉลี่ย',
                enableTooltip: true,
                markerSettings: MarkerSettings(isVisible: true),
              ),
              LineSeries<SalesDetails1, String>(
                dataSource: sales,
                xValueMapper: (SalesDetails1 details, _) => details.month,
                yValueMapper: (SalesDetails1 details, _) =>
                    int.parse(details.compair),
                opacity: 0.9,
                width: 3,
                name: 'จำนวนครั้งที่แอร์ทำงาน',
                enableTooltip: true,
                markerSettings: MarkerSettings(isVisible: true),
              ),
            ],
            tooltipBehavior: TooltipBehavior(
                enable: true,
                canShowMarker: false,
                header: '',
                format: 'point.y marks in point.x'),
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
          ),
        ),
      ),
    );
  }

  void showDatePicker(context) {
    showDialog(
      context: context,
      builder: (context) => DateTimePicker(
        initialValue: DateTime.now().toString(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        dateLabelText: 'Date',
        onChanged: (val) => print(val),
        validator: (val) {
          print(val);
          return null;
        },
        onSaved: (val) => print(val),
      ),
    );
  }
}

class _buildChart2 extends StatelessWidget {
  const _buildChart2({
    Key? key,
    required this.sales,
    required this.dateTimeSeleceted,
  }) : super(key: key);
  final String dateTimeSeleceted;
  final List<SalesDetails2> sales;

  @override
  Widget build(BuildContext context) {
    Future<bool?>? showWarning(context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure ?'),
              content: Text('do you want to exit an App'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Yes'),
                ),
              ],
            ));

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.width * 0.7,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
                labelRotation: 90, labelStyle: TextStyle(fontSize: 10)),
            enableSideBySideSeriesPlacement: true,
            series: [
              ColumnSeries<SalesDetails2, String>(
                opacity: 0.9,
                width: 0.7,
                dataSource: sales,
                name: 'อุณหภูมิเฉลี่ย',
                xValueMapper: (SalesDetails2 data, _) => data.month,
                yValueMapper: (SalesDetails2 data, _) => double.parse(
                  data.salesCount,
                ),
              ),
              ColumnSeries<SalesDetails2, String>(
                opacity: 0.9,
                width: 0.7,
                dataSource: sales,
                name: 'โหมด\nประหยัด\nพลังงาน',
                xValueMapper: (SalesDetails2 data, _) => data.month,
                yValueMapper: (SalesDetails2 data, _) => int.parse(
                  data.salesavg,
                ),
              ),
              ColumnSeries<SalesDetails2, String>(
                opacity: 0.9,
                width: 0.7,
                dataSource: sales,
                name: 'จำนวนครั้ง\nที่แอร์ทำงาน',
                xValueMapper: (SalesDetails2 data, _) => data.month,
                yValueMapper: (SalesDetails2 data, _) => int.parse(
                  data.compair,
                ),
              )
            ],
            tooltipBehavior: TooltipBehavior(
                enable: true,
                canShowMarker: false,
                header: '',
                format: 'point.y marks in point.x'),
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
          ),
        ),
      ),
    );
  }

  void showDatePicker(context) {
    showDialog(
      context: context,
      builder: (context) => DateTimePicker(
        initialValue: DateTime.now().toString(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        dateLabelText: 'Date',
        onChanged: (val) => print(val),
        validator: (val) {
          print(val);
          return null;
        },
        onSaved: (val) => print(val),
      ),
    );
  }
}

class SalesDetails1 {
  final String month;
  final String salesCount;
  final String salesavg;
  final String compair;
  SalesDetails1(this.month, this.salesCount, this.salesavg, this.compair);
}

class SalesDetails2 {
  final String month;
  final String salesCount;
  final String salesavg;
  final String compair;
  SalesDetails2(this.month, this.salesCount, this.salesavg, this.compair);
}
