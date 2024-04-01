// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../pages/loginpage.dart';
import 'FullViewIMG.dart';
import 'show_attendance_report.dart';

class Add_Attendance extends StatefulWidget {
  const Add_Attendance({super.key});

  @override
  State<Add_Attendance> createState() => _Add_AttendanceState();
}

class _Add_AttendanceState extends State<Add_Attendance> {
  var backendIP = ApiConstants.backendIP;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
     month = DateFormat('MMMM').format(DateTime.now());
  }

  String whoIs = '';
  String Atndtitle = '';
  String user_id = '';
  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var Atndtitle1 = sharedPreferences.getString('Atndtitle');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        Atndtitle = Atndtitle1!;
        user_id = user_id1!;
        whoIs == 'ADMIN'
        ? getSTFdata()
        :whoIs == 'STAFF'
        ?staffAttendList(user_id)
        :null;
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  List fetchstfdata = [];
  Future<void> getSTFdata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/STAFF-dtls.php');
      var response = await http
          .post(apiUrl, body: {'action': 'STAFF-LIST', 'whois': "STAFF"});
      if (response.statusCode == 200) {
        setState(() {
          fetchstfdata = json.decode(response.body);
          print(fetchstfdata);
           isloading = true ;

        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  bool isloading = false;
  List stfdata = [];
List filteredStfData = [];

List<String> proofDates = []; 
List<String> outproofDates = [];

  Future<void> staffAttendList(user_id) async {
    try {
      print(whoIs);
      print(user_id);
      var apiUrl = Uri.parse('$backendIP/Stf_attendance.php');
      var response = await http.post(apiUrl,
          body: {'action': 'STF-ATTND-LIST','stf_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
       stfdata = json.decode(response.body);
          print(stfdata);
          isloading = true ;
           proofDates = List<String>.from(stfdata.map((data) => data['in_date']));
            outproofDates = List<String>.from(stfdata.map((data) => data['out_date']));
        });
      }
    } catch (e) {
      print('error: $e');
    }
  }




  bool togle = false;

// List filtter = [];
  String Searching = '';
  void serchdata() {
      if (Searching.isNotEmpty) {
       setState(() {
          fetchstfdata = fetchstfdata
            .where((stf) => stf['name']
                .toString()
                .toLowerCase()
                .contains(Searching.toLowerCase()))
            .toList();
       });
      } else {
       setState(() {
          getSTFdata();
       });
      }
  
  }

  int _getTotalDaysInMonth(DateTime dateTime) {
    final beginningOfMonth = DateTime(dateTime.year, dateTime.month, 1);
    final beginningOfNextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
    final lastDayOfMonth = beginningOfNextMonth.subtract(Duration(days: 1));
    return lastDayOfMonth.day;
  }

String _getAttendanceProofForDate(DateTime date) {
  final matchingRecord = stfdata.firstWhere(
    (record) {
      final recordDate = DateTime.parse(record['in_date']);
      return recordDate.day == date.day &&
          recordDate.month == date.month &&
          recordDate.year == date.year;
    },
    orElse: () => null,
  );
  return matchingRecord != null ? matchingRecord['in_proof'] ?? '' : '';
}



ImagePicker picker = ImagePicker();
XFile? _pickedImage;
 bool uploadpic = false;
void _pickImagecam() async {
  final pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
    setState(() {
      _pickedImage = pickedImage;
      uploadpic = true;
     _AddAttendProof();

    });
  }
}


void _AddAttendProof() async {

DateTime now = DateTime.now();
String year = now.year.toString();
String month = now.month.toString().padLeft(2, '0'); // Ensure two digits for month
String day = now.day.toString().padLeft(2, '0'); // Ensure two digits for day
String hour = now.hour.toString().padLeft(2, '0'); // Ensure two digits for hour
String minute = now.minute.toString().padLeft(2, '0'); // Ensure two digits for minute
String second = now.second.toString().padLeft(2, '0'); // Ensure two digits for second

String date = '$year-$month-$day';
String time = '$hour:$minute:$second';

  if (_pickedImage != null) {
    List<int> imageBytes = await File(_pickedImage!.path).readAsBytes();

    var imageFile = http.MultipartFile.fromBytes(
      'user_image',
      imageBytes,
      filename: 'user_image.jpg', 
    );

    var apiUrl = '$backendIP/Add_staff_attendance.php'; // Replace with your server's API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['user_id'] = user_id;
    request.fields['date'] = date;
    request.fields['time'] = time;
    request.files.add(imageFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Upload successful, handle the response if needed
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Response: $responseString');
        
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(child: Text('Attendance Added',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
        ));
        setState(() {
           checkLoginStatus();
        });
       
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(child: Text('Error')),
        ));
      }
    } catch (e) {
      // Handle network-related errors
      print('Network Error: $e');
    }
  }
}

void _pickImagecamout() async {
  final pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
    setState(() {
      _pickedImage = pickedImage;
      uploadpic = true;
     _OUTAttendProof();

    });
  }
}

void _OUTAttendProof() async {

DateTime now = DateTime.now();
String year = now.year.toString();
String month = now.month.toString().padLeft(2, '0'); // Ensure two digits for month
String day = now.day.toString().padLeft(2, '0'); // Ensure two digits for day
String hour = now.hour.toString().padLeft(2, '0'); // Ensure two digits for hour
String minute = now.minute.toString().padLeft(2, '0'); // Ensure two digits for minute
String second = now.second.toString().padLeft(2, '0'); // Ensure two digits for second

String date = '$year-$month-$day';
String time = '$hour:$minute:$second';

  if (_pickedImage != null) {
    List<int> imageBytes = await File(_pickedImage!.path).readAsBytes();

    var imageFile = http.MultipartFile.fromBytes(
      'user_image',
      imageBytes,
      filename: 'user_image.jpg', 
    );

    var apiUrl = '$backendIP/Add_out_addedance.php'; // Replace with your server's API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['user_id'] = user_id;
    request.fields['date'] = date;
    request.fields['time'] = time;
    request.files.add(imageFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Upload successful, handle the response if needed
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Response: $responseString');
        
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(child: Text('Attendance Added',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
        ));
        setState(() {
           checkLoginStatus();
        });
       
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(child: Text('Error')),
        ));
      }
    } catch (e) {
      // Handle network-related errors
      print('Network Error: $e');
    }
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


void Show_Attend(stfId) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Show_Attendance_Report()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('stfId', stfId);
  }


  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = generateDatesForSelectedMonth();

    return 
    isloading
    ?Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          elevation: 10,
          shadowColor: Colors.grey,
          toolbarHeight: 100,
          centerTitle: true,
          title: 
          whoIs == 'STAFF'
          ?Text('Add Proof', style: TextStyle(color: Colors.white))
          :Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              togle
                  ? Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: 200,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      Searching = value;
                                      serchdata();
                                    });
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
              
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    hintText: "Seach Here....",
                                    hintStyle:
                                        TextStyle(color: Colors.black),
                                    filled: true,
                                    //fillColor: const Color.fromARGB(255, 223, 217, 217),
                                  ),
                                ),
                              ),
                              // IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(
                              //       Icons.search,
                              //       size: 40,
                              //   ),
                              // )
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Staff $Atndtitle',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
              togle
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          togle = false;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_circle_up,
                        size: 30,
                        color: Colors.white,
                      ))
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          togle = true;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Colors.white,
                        size: 30,
                      ))
            ],
          ),
        ),

        body: 
        
         whoIs == 'ADMIN'
          ? Column(
           children: [
             SizedBox(
               height: 15,
             ),
         Expanded(
               child: ListView.builder(
                 itemCount: fetchstfdata.length,
                 itemBuilder: (context, index) {
                   String Stf_us_id = fetchstfdata[index]['ad_nm'];
                  // String Stf_id = fetchstfdata[index]['id'].toString();
                   String Stf_name = fetchstfdata[index]['name'];
                   String Stf_num = fetchstfdata[index]['phn'];
        
                   return Padding(
                     padding: const EdgeInsets.only(
                         left: 20.0, right: 20, top: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             CircleAvatar(
                               radius: 25,
                               backgroundImage:
                                   AssetImage('assets/images/emt.jpg'),
                             ),
                             SizedBox(
                               width: 20,
                             ),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   '$Stf_name'.toUpperCase(),
                                   style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 Text(
                                   Stf_num,
                                   style: TextStyle(
                                     fontSize:
                                         14, // Change the fontSize as needed
                                     // Add other styles as needed
                                   ),
                                 ),
                               ],
                             ),
                             SizedBox(width: 10,),
                             Spacer(),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Inside the ListView.builder item
                                 Container(
                                     decoration: BoxDecoration(
                                         color: Colors.transparent),
                                     height: 40,
                                     child: IconButton(
                                         onPressed: () {
                                          setState(() {
                                             Show_Attend(
                                                   Stf_us_id);
                                          });
                                         },
                                         icon: Icon(Icons.event_note_sharp,
                                             size: 30,color: Color.fromARGB(255, 209, 119, 0),))),
                               ],
                             ),
                           ],
                         ),
                         SizedBox(height: 10),
                         Divider()
                       ],
                     ),
                   );
                 },
               ),
             )
             ],
            )



             : whoIs == 'STAFF'
             ?SingleChildScrollView(
               child: Column(
                 children: [
                  Card(
                  child: Container(
                 decoration: BoxDecoration(border: Border.all()),
                 height: 80,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text('CHECK IN',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,letterSpacing: 2,wordSpacing: 2),),
                       SizedBox(height: 5,),
                        Row(
            children: [
              Text(
                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 20),
              ), // Display current date
              Spacer(),
              if (proofDates.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
                Text('Today\'s proof already added'), // Display message if proof already added for today
              if (!proofDates.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
                IconButton(
                  onPressed: () {
                    // Handle attendance marking
                    _pickImagecam();
                    print('Attendance marked for ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
                  },
                  icon: Icon(
                    Icons.add,
                    size: 40,
                  ),
                )
            ],
          ),
                     ],
                   ),
                 ),
               ),
                       ),
              if (proofDates.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
                 Card(
                child: Container(
                 decoration: BoxDecoration(border: Border.all()),
                 height: 80,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text('CHECK OUT',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,letterSpacing: 2,wordSpacing: 2),),
                       SizedBox(height: 5,),
                       Row(
                         children: [
                           Text(
                             DateFormat('dd-MM-yyyy').format(DateTime.now()),
                             style: TextStyle(fontSize: 20),
                           ), // Display current date
                           Spacer(),
                          
                           if (outproofDates.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
                             Text('Today\'s proof already added'), // Display message if proof already added for today
                           if (!outproofDates.contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
                             IconButton(
                               onPressed: () {
                                       _pickImagecamout();
                                       print(
                              'Attendance marked for ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
                               },
                               icon: Icon(
                                       Icons.add,
                                       size: 40,
                               ),
                             ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
                       ),
               
               
                    SingleChildScrollView(
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
                                      staffAttendList(user_id);
                                   });
                                  } else {
                                   
                                    staffAttendList(user_id);
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
                                DataCell( 
                                  
                                data['out_proof']!=null && data['out_proof'].isNotEmpty 
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
                 ],
               ),
             )
             :Container()
           
         
            
      )
      : Scaffold(
        body: Center(child: CircularProgressIndicator()));
  }



}

