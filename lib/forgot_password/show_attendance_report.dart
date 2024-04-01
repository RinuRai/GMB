// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';
import '../pages/loginpage.dart';

class Show_Attendance_Report extends StatefulWidget {
  const Show_Attendance_Report({super.key});

  @override
  State<Show_Attendance_Report> createState() => _Show_Attendance_ReportState();
}

class _Show_Attendance_ReportState extends State<Show_Attendance_Report> {
  var backendIP = ApiConstants.backendIP;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    month = DateFormat('MMMM').format(DateTime.now());
    print(month);
  }

  String stfId = '';
  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var stfId1 = sharedPreferences.getString('stfId');
    if (stfId1 != null) {
      setState(() {
        stfId = stfId1;
        staffAttendList(stfId);
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  bool isloading = false;
  List stfdata = [];
  List filteredStfData = [];

  List<String> proofDates = [];

  Future<void> staffAttendList(stfId11) async {
    try {
      print(stfId);
      var apiUrl = Uri.parse('$backendIP/Stf_attendance.php');
      var response = await http
          .post(apiUrl, body: {'action': 'STF-ATTND-LIST', 'stf_id': stfId11});
      if (response.statusCode == 200) {
        setState(() {
          stfdata = json.decode(response.body);

        
          print(stfdata);
          print(filteredStfData); // Print filtered data for debugging
          isloading = true;
        });
      }
    } catch (e) {
      print('error: $e');
    }
  }


  String month = 'All';
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<DateTime> generateDatesForSelectedMonth() {
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    return List.generate(daysInMonth,
        (index) => DateTime(selectedYear, selectedMonth, index + 1));
  }

 String selectedMonthYear = '';
  void updateSelectedMonthYear() {
    setState(() {
      selectedMonthYear =
          DateFormat('MMMM').format(DateTime(selectedMonth));
    });
  }



  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = generateDatesForSelectedMonth();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 31, 70, 85),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        elevation: 10,
        shadowColor: Colors.grey,
        toolbarHeight: 100,
        title: Text(
          'Staff Attendance Report',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isloading
          ? SingleChildScrollView(
            child: Column(
                children: [
                  Card(
                    elevation: 10,
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: DropdownButton<String>(
                          value: month,
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              setState(() {
                                month = newValue;
                                if (newValue != 'All') {
                                  int selectedMonthIndex =
                                      months.indexOf(newValue) +
                                          1; // Convert month name to index

                                 setState(() {
                                 selectedMonth = selectedMonthIndex;
                                 print(selectedMonth);
                                    updateSelectedMonthYear();
                                    staffAttendList(stfId);
                                 });
                                } else {
                                 
                                  staffAttendList(stfId);
                                }
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Container(
                                width: 150,
                                child: Text(
                                  'Select Month',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .grey, // You can set a different color to indicate it's disabled
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap:
                                  null, // Set onTap to null to make it not clickable
                            ),
                            ...Set<String>.from(months.map((data) => data))
                                .where((value) => value.isNotEmpty)
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Container(
                                        width:
                                            250, // Set the maximum width you prefer
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: month == value
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                          underline: Container(),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 30,
                         dataRowHeight: 70,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Color.fromARGB(255, 31, 70, 85),
                          
                        ),
                        headingTextStyle: TextStyle(color: Colors.white),
                        border: TableBorder.all(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          width: 0.4,
                        ),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text('S.No',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Date',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Day',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('In',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Out',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: List.generate(dates.length, (index) {
                          DateTime date = dates[index];
            
                          Map<String, dynamic>? data = stfdata.firstWhere(
                            (data) {
                              if (data['in_date'] != null) {
                                DateTime? fromDt =
                                    DateTime.tryParse(data['in_date']);
                                return fromDt != null &&
                                    fromDt.day == date.day &&
                                    fromDt.month == date.month;
                              }
                              return false;
                            },
                            orElse: () => {'status': 'Missed to clock in'},
                          );
                          Color rowColor = data!['status'] == 'Missed to clock in'
                              ? Color.fromARGB(255, 223, 222, 222)
                              : Colors.white;
                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                              (states) => rowColor,
                            ),
                            cells: <DataCell>[
                              DataCell(Text((index + 1).toString())),
                              DataCell(
                                  Text(DateFormat('dd/MM/yyyy').format(date))),
                              DataCell(Text(DateFormat('EEEE').format(date))),
                              DataCell(
                                 data['in_proof']!=null && data['in_proof'].isNotEmpty 
                                  ?Column(
                                    children: [
                                      InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullPageImage(
                                              imageUrl: '$backendIP/attend_proof/' +
                                                  data['in_proof'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                          image: NetworkImage(
                                              '$backendIP/attend_proof/' +
                                                  data['in_proof']),
                                          height: 50,
                                        ),
                                        height: 50, // Show image widget
                                      ),
                                     ),
                                     Text(data['in_time'])
                                    ],
                                  ):Text('Missed Clock in')
                                ),
                              DataCell( data['out_proof']!=null && data['out_proof'].isNotEmpty 
                                  ?Column(
                                    children: [
                                      InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullPageImage(
                                              imageUrl: '$backendIP/attend_proof/' +
                                                  data['out_proof'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                          image: NetworkImage(
                                              '$backendIP/attend_proof/' +
                                                  data['out_proof']),
                                          height: 50,
                                        ),
                                        height: 50, // Show image widget
                                      ),
                                     ),
                                     Text(data['out_time'])
                                    ],
                                  ):Text('Missed Clock Out')),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  
                ],
              ),
          )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
