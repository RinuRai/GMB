import 'dart:convert';
 // Added
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Disable_Function/staff_list_pg.dart';
import '../config.dart';
import '../forgot_password/Change_Password.dart';
import '../forgot_password/Client_profile.dart';
import '../forgot_password/add_attendance.dart';
import '../forgot_password/add_supervisor.dart';
import '../forgot_password/profile.dart';

import '../forgot_password/qt_control.dart';
import '../plan_list/add_plans.dart';
import '../plan_list/add_staff.dart';
import '../plan_list/add_user.dart';
import '../plan_list/agreement.dart';
//import '../plan_list/electricalplan.dart';
//import 'bottom_navigate.dart';
import '../plan_list/layout_works.dart';
import '../plan_list/payment_dtls.dart';
import 'loginpage.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import FlutterLocalNotificationsPlugin

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

 late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin; // Declare FlutterLocalNotificationsPlugin

  var backendIP = ApiConstants.backendIP;

  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Initialize FlutterLocalNotificationsPlugin
    initializeNotifications(); // Initialize notifications
    checkLoginStatus();
    _pageController = PageController(); // Initialize the PageController
    
  }


@override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isloading = false;
  String whoIs = '';
  String user_id = '';

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        isloading = true;
       if(whoIs == 'CLIENT') {
          getTodatShedule(user_id);
          getTdypendingList(user_id);
       }else{
        null;
       }
        
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
//////////////////////////////////////////////////////////////////////////////////////

List fetchTodayList = [];
  Future<void> getTodatShedule(id) async {

      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(Duration(days: 1));

      String year = tomorrow.year.toString();
      String month = tomorrow.month.toString().padLeft(2, '0');
      String day = tomorrow.day.toString().padLeft(2, '0');
      String tomorrowDate = '$year-$month-$day';

      print(tomorrowDate);

    try {
      var apiUrl = Uri.parse('$backendIP/Today_Shedule.php');
      var response = await http.post(apiUrl, body: {
        'action': 'Fetch-Today-Shedule',
        'cli_id' :id,
        'date': tomorrowDate,
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchTodayList = json.decode(response.body);
          isloading = true;
          print(fetchTodayList);

          List<String> userNames = fetchTodayList.map((item) => item['us_nm'].toString()).toList();
           setState(() {
             getclientdatalist(userNames,);
           });

        });
      }
    } catch (e) {
      print('error $e');
    }
  }
////////////////////////////////////////////////////////////////////////////////////////

List clientdatalist = [];
Future<void> getclientdatalist(List<String> userNames) async {
  try {
    var apiUrl = Uri.parse('$backendIP/Notification_cli_data.php');
    var response = await http.post(apiUrl, body: {
      'action': 'Fetch-Shedule_Cli-data', // Update the action if needed
      'userNames': jsonEncode(userNames), // Serialize the list to JSON format
    });
    if (response.statusCode == 200) {
      setState(() {
        clientdatalist = json.decode(response.body);
        isloading = true;
        print(clientdatalist);
          if (clientdatalist.isNotEmpty) {
            initializeNotifications();
            clientdatalist.forEach((item) {
              sendsheduleNotification(item['id'].toString(), 'Shedule','Tomorrow Your Shedule As Ended');
            });
          }
      });
    }
  } catch (e) {
    print('errors $e');
  }
}


/////////////////////////////////////////////////////////////////////////////////////

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings); // Initialize notifications
  }

Future<void> sendsheduleNotification(String clientId, String title, String body) async {
  print('Sending notification to client ID: $clientId');
  print('Title: $title');
  print('Body: $body');

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'GM',
    'Green Marvel Construction',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    int.parse(clientId), // Use client ID as notification ID
    title,
    body,
    platformChannelSpecifics,
  );
  print('Notification sent to client ID: $clientId');
}


//////////////////////////////////////////////////////////////////////////////////

List fetchTodayPendingList = [];
  Future<void> getTdypendingList(id) async {

      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(Duration(days: 1));

      String year = tomorrow.year.toString();
      String month = tomorrow.month.toString().padLeft(2, '0');
      String day = tomorrow.day.toString().padLeft(2, '0');
      String tomorrowDate = '$year-$month-$day';

      print(tomorrowDate);

    try {
      var apiUrl = Uri.parse('$backendIP/Today_Shedule.php');
      var response = await http.post(apiUrl, body: {
        'action': 'Fetch-Today-Pending',
        'cli_id' :id,
        'date': tomorrowDate,
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchTodayPendingList = json.decode(response.body);
          isloading = true;
          print(fetchTodayPendingList);

          List<String> userNames = fetchTodayPendingList.map((item) => item['us_nm'].toString()).toList();
           setState(() {
             pendingclientdatalist(userNames,);
           });

        });
      }
    } catch (e) {
      print('error $e');
    }
  }
////////////////////////////////////////////////////////////////////////////////////////

List peningclientdatalist = [];
Future<void> pendingclientdatalist(List<String> userNames) async {
  try {
    var apiUrl = Uri.parse('$backendIP/Notification_cli_data.php');
    var response = await http.post(apiUrl, body: {
      'action': 'Fetch-Shedule_Cli-data', // Update the action if needed
      'userNames': jsonEncode(userNames), // Serialize the list to JSON format
    });
    if (response.statusCode == 200) {
      setState(() {
        peningclientdatalist = json.decode(response.body);
        isloading = true;
        print(peningclientdatalist);
          if (peningclientdatalist.isNotEmpty) {
            initializeNotifications();
            peningclientdatalist.forEach((item) {
              sendsheduleNotification(item['id'].toString(), 'Payment Detail','Your Payment is pending,\nTomorrow is your last Date');
            });
          }
      });
    }
  } catch (e) {
    print('errors $e');
  }
}





///////////////////////////////////////////////////////////////////////////////
  Future<void> logout() async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.remove('whoIs');
      sharedPreferences.remove('user_id');
      sharedPreferences.remove('us_log_dt');
      sharedPreferences.remove('us_dt_ln');

      // Navigate to LoginPage after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      SnackBar(content: Text("Your Account Logout Successfully"));
      // Get the current time
      // DateTime now = DateTime.now();
      // // Extract date and time components
      // String year = now.year.toString();
      // String month = now.month.toString();
      // String day = now.day.toString();
      // String hour = now.hour.toString();
      // String minute = now.minute.toString();
      // String second = now.second.toString();

      // String time_date = '$year-$month-$day $hour:$minute:$second';
      // String date = '$year-$month-$day';
      // var url = "$backendIP/logout_time_update.php";
      // var response = await http.post(Uri.parse(url), body: {
      //   "user_id": session_Id,
      //   "user_time":session_time,
      //   "logout_time": formattedTime,
      //   "logout_time_date": time_date,
      //   "logout_date": date,
      // });
      // if (response.statusCode == 200) {
      //   print('logout update successfully');
      // } else {
      //   print('Error occurred during update logout: ${response.body}');
      // }
    } catch (e) {
      print('the error is $e');
    }
  }

  void agree() async {
// if(title =='Flor Plan'){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Agreement()));
    // final SharedPreferences sharedPreferences =
    //     await SharedPreferences.getInstance();
    // sharedPreferences.setString('plantitle', title);
  }

  void add_plan(title) async {
// if(title =='Flor Plan'){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Add_GMPlans()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('plantitle', title);
  }

  void layout_work(title) async {
// if(title =='Flor Plan'){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Layout_Works()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('layouttitle', title);
  }

  void paymnt_dtl(title) async {
// if(title =='Flor Plan'){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Payment_Dtls()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('paytitle', title);
  }

  void quality(title) async {
  // if(title =='Flor Plan'){
    Navigator.push(context, MaterialPageRoute(builder: (context) => qc_Cntl()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('qctitle', title);
  }


  void Attendance(title) async {
 
   Navigator.push(context, MaterialPageRoute(builder: (context) => Add_Attendance()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('Atndtitle', title);
  }

  void addSupervisor(title) async {
  // if(title =='Flor Plan'){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Add_Supervisor()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('supertitle', title);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isloading
            ? SingleChildScrollView(
                child: Column(children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2 + 10,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg7.jpg'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      //Positioned(child: IconButton(onPressed: (){}, icon: Icon(icons)))
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(80),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // Spread radius
                                  blurRadius: 6, // Blur radius
                                  offset: Offset(
                                      0, 1), // Offset in x and y direction
                                ),
                              ],
                            ),
                            height: 100,
                            width: MediaQuery.of(context).size.width,
                            child: Image(
                              image: AssetImage('assets/images/logo_gm3.png'),
                            ),
                          )),
                      Positioned(
                          bottom: MediaQuery.of(context).size.height / 3 + 40,
                          left: MediaQuery.of(context).size.width - 60,
                          child: popupicon()),
                    ],
                  ),
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 280,
                              width: MediaQuery.of(context).size.width,
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (int page) {
                                  setState(() {
                                    _currentPage = page;
                                  });
                                },
                                children: [
                                  buildCardOne(),
                                  buildCardTwo(),
                                  buildCardThree(),
                                  whoIs == 'ADMIN'
                                      ? buildCardFour()
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      buildIndicator(0),
                      Card()
                    ],
                  ),
                ]),
              )
            : Center(
                child: Image(
                image: AssetImage('assets/images/logo_gm3.png'),
                width: 100,
              )));
  }

  Widget buildCardOne() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          height: 250,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Add_User()));
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/user.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Add User'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            add_plan('Section Plan');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image:
                                      AssetImage('assets/images/section.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Section Plan'),
                              ],
                            ),
                          ),
                        ),
                  whoIs == 'STAFF'
                      ? InkWell(
                          onTap: () {
                            quality('Quality Control');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/qc.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('QC'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            agree();
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/agree.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Agreement'),
                              ],
                            ),
                          ),
                        ),
                  InkWell(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>FlorPlan_page()));
                      add_plan('Floor Plan');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/flor.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Floor Plans'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Electrical_Plan()));
                      add_plan('Electrical Plan');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/electrical.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Electrical Plan'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      add_plan('Plumbing Plan');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/plumb.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Plumbing Plan'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      add_plan('Center Line Plan');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/plan.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Center Line Plan'),
                        ],
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
  }

  Widget buildCardTwo() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      layout_work('Plot Layout');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/plot.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Plot Layout'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      layout_work('Elevation');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/elevator.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Elevation'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      layout_work('Brick Work Layout');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/brick.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Brick work\nLayout'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      layout_work('Shade Layout');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/shade.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Shade Layout'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      layout_work('Structural Drawing');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image:
                                AssetImage('assets/images/png/structural.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Structural\nDrawing'),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      layout_work('Window Drawing');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/window.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Window\nDrawing'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardThree() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      layout_work('Door Drawing');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/door.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Door Drawing'),
                        ],
                      ),
                    ),
                  ),
                  whoIs == 'STAFF'
                      ? InkWell(
                          onTap: () {
                            paymnt_dtl('Check List');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image:
                                      AssetImage('assets/images/png/list.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Check List'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            paymnt_dtl('Payment Details');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/images/png/payment.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Payment Details'),
                              ],
                            ),
                          ),
                        ),
                  InkWell(
                    onTap: () {
                      paymnt_dtl('Shedule');
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/png/shedule.png'),
                            width: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Shedule'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  whoIs == 'STAFF'
                      ? InkWell(
                          onTap: () {
                            Attendance('Attendance Report');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/attendance.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Attendance'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            paymnt_dtl('Check List');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image:
                                      AssetImage('assets/images/png/list.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Check List'),
                              ],
                            ),
                          ),
                        ),
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            add_plan('Section Plan');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image:
                                      AssetImage('assets/images/section.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Section Plan'),
                              ],
                            ),
                          ),
                        )
                      : whoIs == 'CLIENT'
                          ? InkWell(
                              onTap: () {
                                quality('Quality Control');
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          'assets/images/png/qc.png'),
                                      width: 40,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('QC'),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(),
                            ),
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Add_Staff()));
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/images/png/addstaff.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Add Staff'),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardFour() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            quality('Quality Control');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/qc.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('QC'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                          ),
                        ),
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            Attendance('Attendance Report');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/attendance.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Attendance'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                          ),
                        ),
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                           addSupervisor('Add Supervisor');
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/supervisor.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Add Supervisor'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                          ),
                        ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Diable_Staff_list()));
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/png/disable.png'),
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Disable'),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(),
                          ),
                        ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 0
                  ? Color.fromARGB(255, 209, 101, 0)
                  : Colors.grey,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 1
                  ? Color.fromARGB(255, 209, 101, 0)
                  : Colors.grey,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 2
                  ? Color.fromARGB(255, 209, 101, 0)
                  : Colors.grey,
            ),
          ),
          whoIs == 'ADMIN'
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == 3
                        ? Color.fromARGB(255, 209, 101, 0)
                        : Colors.grey,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> popupicon() {
    return PopupMenuButton(
        color: Colors.white,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: Column(
                children: [
                  whoIs == 'STAFF'
                      ? InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Profile_View()));
                          },
                          child: Container(
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(Icons.person_pin),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )))
                      : Container(),

                   whoIs == 'CLIENT'
                      ? InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Client_Profile()));
                          },
                          child: Container(
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(Icons.person_pin),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )))
                      : Container(),   

                   whoIs == 'ADMIN'
                      ? InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Change_Password()));
                          },
                          child: Container(
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(Icons.person_pin),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Change Password',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )))
                      : Container(),      

                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        logoutdialog(context);
                      },
                      child: Container(
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Row(
                              children: [
                                Icon(Icons.logout),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Logout',
                                   style: TextStyle(
                                   color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            ),
          ];
        },
        child: Container(
            child: Icon(
          Icons.menu,
          size: 35,
          color: Colors.white,
        )));
  }

  Future<dynamic> logoutdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            content: Container(
              height: 150,
              // decoration: BoxDecoration(
              //   color: Colors.red
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_sharp,
                    color: Colors.white,
                    size: 50,
                  ),
                  Text(
                    "Are you sure Logout\nthis account?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 255, 255,
                              255), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          logout();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 255, 252,
                              251), // Change the background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                0), // Set the border radius to 0
                          ),
                        ),
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
