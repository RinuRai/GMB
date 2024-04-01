import 'dart:convert';
import 'package:greenmarvelbuilders/pages/bottom_navigate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';
import 'adding_plans.dart';

class Add_GMPlans extends StatefulWidget {
  const Add_GMPlans({super.key});

  @override
  State<Add_GMPlans> createState() => _Add_GMPlansState();
}

class _Add_GMPlansState extends State<Add_GMPlans> {
  var backendIP = ApiConstants.backendIP;
  String whoIs = '';
  String user_id = '';
  String title = '';
  List fetchalldata = [];
  String fetchdataLength = '';

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var title11 = sharedPreferences.getString('plantitle');
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null ) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        title = title11!;
        getUserdata();
         whoIs =='STAFF'
            ?loadDisableList()
            :null;
        print(whoIs);
        print(user_id);
         print(title);
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home_Navigator()),
      );
    }
  }


  Future<void> getUserdata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response =
          await http.post(apiUrl, body: {'action': whoIs, 'user_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchalldata = json.decode(response.body);
          fetchdataLength = fetchalldata.length.toString();
          isloading = true;
          print(fetchalldata);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

 List fetchDisablelist = [];
  void loadDisableList() async {
    List disableList = await APIService.disableList(user_id);
    setState(() {
      fetchDisablelist = disableList;
    });
  }

  void add_ag(id, usid, file) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GM_plan_Upload()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('plan_title2', title);
    sharedPreferences.setString('id', id);
    sharedPreferences.setString('cli_id', usid);
    sharedPreferences.setString('who', whoIs);
    sharedPreferences.setString('clFile', file);
  }

  void _launchURL(String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      print('Error launching URL: $e');
      // Handle the error gracefully, perhaps showing a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fetchalldata.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              'assets/images/bg1.jpg', // Replace with your background image path
              fit: BoxFit.cover,
            ),
            title: Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            centerTitle: true,
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          toolbarHeight: 80,
          elevation: 10,
          shadowColor: Colors.grey,
        ),
        body: Container(
            decoration: BoxDecoration(color: Colors.white),
            height: MediaQuery.of(context).size.height - 80,
            child: whoIs == 'ADMIN' ||whoIs == 'STAFF'
                ? ListView.builder(
                    itemCount: fetchalldata.length,
                    itemBuilder: (context, index) {
                      Color getColor(int i) {
                          return i % 2 == 0
                              ? Color.fromARGB(255, 255, 255, 255)
                              : Color.fromARGB(255, 235, 235, 235);// Alternates between black and grey
                        }
                      Color containerColor = getColor(index);

                      String name = fetchalldata[index]['nm'];
                      String number = fetchalldata[index]['phn'];
                      String plan = '';
                      String date = '';
                       bool isDisabled = fetchDisablelist.any((disableItem) => disableItem['cli_id'] == fetchalldata[index]['us_id']);
                               if(whoIs == 'STAFF'){
                                 if (isDisabled) {
                                  return SizedBox.shrink(); // Skip rendering this item
                                }
                               } 
                               else{null;}

                       if(title =='Section Plan'){
                       plan = fetchalldata[index]['sec_plan'];
                       date = fetchalldata[index]['sec_dt'];
                        }
                       else if(title =='Floor Plan'){
                       plan = fetchalldata[index]['floor_plan'];
                       date = fetchalldata[index]['floor_dt'];
                        }
                        else if(title =='Electrical Plan'){
                       plan = fetchalldata[index]['elec_plan'];
                       date = fetchalldata[index]['elec_dt'];
                        }
                        else if(title =='Plumbing Plan'){
                       plan = fetchalldata[index]['plumb_plan'];
                       date = fetchalldata[index]['plumb_dt'];
                        }
                        else if(title =='Center Line Plan'){
                       plan = fetchalldata[index]['cl_plan'];
                       date = fetchalldata[index]['cl_dt'];
                        }
                        else{
                        plan = '';
                        }
                      // Extract data for each person
                     
                      return Card(
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        AssetImage('assets/images/emt.jpg'),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$name',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        number,
                                        style: TextStyle(
                                          fontSize:
                                              14, // Change the fontSize as needed
                                          // Add other styles as needed
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Inside the ListView.builder item
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent),
                                        height: 80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            plan.isEmpty
                                                ? 
                                              whoIs == 'STAFF'
                                               ? Container()
                                               : ElevatedButton(
                                                    onPressed: () {
                                                      
                                                      add_ag(
                                                          fetchalldata[index]
                                                                  ['id']
                                                              .toString(),
                                                          fetchalldata[index]
                                                                  ['us_id']
                                                              .toString(),plan);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Container(
                                                          width: 100,
                                                          child: Text(
                                                            'Add $title',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white),
                                                            overflow: TextOverflow.ellipsis,        
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                              255, 209, 101, 0),
                                                    ),
                                                  )
                                                : 
                                                ElevatedButton(
                                                    onPressed: () {
                                                     
                                                      add_ag(
                                                          fetchalldata[index]['id'].toString(),
                                                          fetchalldata[index]['us_id'].toString(),
                                                           plan  
                                                          );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.verified_user,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Container(
                                                          width: 100,
                                                          child: Text(
                                                            whoIs == 'STAFF'
                                                            ?'View $title'
                                                            :'change $title',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            date != '0000-00-00'
                                                ? Text(
                                                    'Last updated on '+ (DateFormat('dd-MM-yyyy').format(DateTime.parse(date))) ,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.green,
                                                    ),
                                                  )
                                                : Text(
                                                    'No attachments',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : 
                
               title == 'Floor Plan'
                ? Container(
                    width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
                   
                    child: Center(
                      child: Card(
                         elevation: 20,
                         shadowColor: Colors.white,
                        child: Container(
                           height: 500,
                            width: 300,
                             decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/bg5.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(
                            .1), // Adjust the opacity value (0.5 in this case)
                        BlendMode.dstATop,
                      ),
                    )),
                          child: SingleChildScrollView(
                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(image: AssetImage('assets/images/logo_gm3.png'),width: 100,),
                                // Text(
                                //   fetchalldata[0]['nm'],
                                //   style: TextStyle(fontSize: 30),
                                // ),
                                SizedBox(
                                  height: 10,
                                ),
                                fetchalldata[0]['floor_dt'] != '0000-00-00'
                                    ? Text('Last Date On Update ' +
                                        (DateFormat('dd-MM-yyyy').format(DateTime.parse( fetchalldata[0]['floor_dt']))) )
                                    :Container(
                                            color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15.0, vertical: 8),
                                              child: Text(
                                                ' * No Any Attachments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                    width: 250, // Set the width to control the size
                                    height: 200, // Set the height to control the size
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Color.fromARGB(255, 209, 101, 0),
                                    )),
                                    child: InkWell(
                                      onTap: () {
                                       // viewDocDialog(context, 'Floor Plan');
                                      },
                                      child: Center(
                                        child: getFileWidget(title),
                                      ),
                                    )),
                                SizedBox(
                                  height: 40,
                                ),
                                fetchalldata[0]['floor_plan'].isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          String agreementUrl =
                                              '$backendIP/uploads/${fetchalldata[0]['floor_plan']}';
                                          _launchURL(agreementUrl);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          child: Card(
                                            color: Color.fromARGB(255, 209, 101, 0),
                                            elevation: 10,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                 
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )

                 :
                 title == 'Electrical Plan'
                 ? Container(
                    width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
                   
                    child: Center(
                      child: Card(
                         elevation: 20,
                         shadowColor: Colors.white,
                        child: Container(
                           height: 500,
                            width: 300,
                             decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/bg7.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(
                            .05), // Adjust the opacity value (0.5 in this case)
                        BlendMode.dstATop,
                      ),
                    )),
                          child: SingleChildScrollView(
                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Image(image: AssetImage('assets/images/logo_gm3.png'),width: 100,),
                                // Text(
                                //   fetchalldata[0]['nm'],
                                //   style: TextStyle(fontSize: 30),
                                // ),
                                
                                fetchalldata[0]['elec_dt'] != '0000-00-00'
                                    ? Text('Last Date On Update ' +
                                        (DateFormat('dd-MM-yyyy').format(DateTime.parse( fetchalldata[0]['elec_dt']))) )
                                    :Container(
                                            color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15.0, vertical: 8),
                                              child: Text(
                                                ' * No Any Attachments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    width: 250, // Set the width to control the size
                                    height: 200, // Set the height to control the size
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Color.fromARGB(255, 209, 101, 0),
                                    )),
                                    child: InkWell(
                                      onTap: () {
                                        
                                       // viewDocDialog(context, 'Electrical Plan');
                                    
                                      },
                                      child: Center(
                                        child: getFileWidget(title),
                                      ),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                fetchalldata[0]['elec_plan'].isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          String agreementUrl =
                                              '$backendIP/uploads/${fetchalldata[0]['elec_plan']}';
                                          _launchURL(agreementUrl);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          child: Card(
                                            color: Color.fromARGB(255, 209, 101, 0),
                                            elevation: 10,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                 
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                 
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                :
                title == 'Plumbing Plan'
                 ? Container(
                    width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
                   
                    child: Center(
                      child: Card(
                         elevation: 20,
                         shadowColor: Colors.white,
                        child: Container(
                           height: 500,
                            width: 300,
                             decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/bg10.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(
                            .05), // Adjust the opacity value (0.5 in this case)
                        BlendMode.dstATop,
                      ),
                    )),
                          child: SingleChildScrollView(
                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(image: AssetImage('assets/images/logo_gm3.png'),width: 100,),
                                // Text(
                                //   fetchalldata[0]['nm'],
                                //   style: TextStyle(fontSize: 30),
                                // ),
                               
                                fetchalldata[0]['plumb_dt'] != '0000-00-00'
                                    ? Text('Last Date On Update ' +
                                        (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['plumb_dt']))))
                                    :Container(
                                            color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15.0, vertical: 8),
                                              child: Text(
                                                ' * No Any Attachments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    width: 250, // Set the width to control the size
                                    height: 200, // Set the height to control the size
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Color.fromARGB(255, 209, 101, 0),
                                    )),
                                    child: InkWell(
                                      onTap: () {
                                         // viewDocDialog(context, 'Plumbing Plan');
                                      },
                                      child: Center(
                                        child: getFileWidget(title),
                                      ),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                fetchalldata[0]['plumb_plan'].isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          String agreementUrl =
                                              '$backendIP/uploads/${fetchalldata[0]['plumb_plan']}';
                                          _launchURL(agreementUrl);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          child: Card(
                                            color: Color.fromARGB(255, 209, 101, 0),
                                            elevation: 10,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                 
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                :
                title == 'Center Line Plan'
                 ? Container(
                    width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
                   
                    child: Center(
                      child: Card(
                         elevation: 20,
                         shadowColor: Colors.white,
                        child: Container(
                           height: 500,
                            width: 300,
                             decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/bg4.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(
                            .1), // Adjust the opacity value (0.5 in this case)
                        BlendMode.dstATop,
                      ),
                    )),
                          child: SingleChildScrollView(
                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(image: AssetImage('assets/images/logo_gm3.png'),width: 100,),
                                // Text(
                                //   fetchalldata[0]['nm'],
                                //   style: TextStyle(fontSize: 30),
                                // ),
                               
                                fetchalldata[0]['cl_dt'] != '0000-00-00'
                                    ? Text('Last Date On Update ' +
                                        (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['cl_dt']))) )
                                    :Container(
                                            color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15.0, vertical: 8),
                                              child: Text(
                                                ' * No Any Attachments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    width: 250, // Set the width to control the size
                                    height: 200, // Set the height to control the size
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Color.fromARGB(255, 209, 101, 0),
                                    )),
                                    child: InkWell(
                                      onTap: () {
                                         // viewDocDialog(context, 'Center Line Plan');
                                      },
                                      child: Center(
                                        child: getFileWidget(title),
                                      ),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                fetchalldata[0]['cl_plan'].isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          String agreementUrl =
                                              '$backendIP/uploads/${fetchalldata[0]['cl_plan']}';
                                          _launchURL(agreementUrl);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          child: Card(
                                            color: Color.fromARGB(255, 209, 101, 0),
                                            elevation: 10,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                 
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )


                  : 
                
               title == 'Section Plan'
                ? Container(
                    width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
                   
                    child: Center(
                      child: Card(
                         elevation: 20,
                         shadowColor: Colors.white,
                        child: Container(
                           height: 500,
                            width: 300,
                             decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/bg11.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(
                            .1), // Adjust the opacity value (0.5 in this case)
                        BlendMode.dstATop,
                      ),
                    )),
                          child: SingleChildScrollView(
                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(image: AssetImage('assets/images/logo_gm3.png'),width: 100,),
                                // Text(
                                //   fetchalldata[0]['nm'],
                                //   style: TextStyle(fontSize: 30),
                                // ),
                                
                                fetchalldata[0]['sec_dt'] != '0000-00-00'
                                    ? Text('Last Date On Update ' +
                                        (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['sec_dt']))))
                                    :Container(
                                            color: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15.0, vertical: 8),
                                              child: Text(
                                                ' * No Any Attachments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    width: 250, // Set the width to control the size
                                    height: 200, // Set the height to control the size
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Color.fromARGB(255, 209, 101, 0),
                                    )),
                                    child: InkWell(
                                      onTap: () {
                                         // viewDocDialog(context, 'Section Plan');
                                      },
                                      child: Center(
                                        child: getFileWidget(title),
                                      ),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                fetchalldata[0]['sec_plan'].isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          String agreementUrl =
                                              '$backendIP/uploads/${fetchalldata[0]['sec_plan']}';
                                          _launchURL(agreementUrl);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          child: Card(
                                            color: Color.fromARGB(255, 209, 101, 0),
                                            elevation: 10,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )

                
                :Container()
                )
                  
      );
    } else {
      // Handle the case when fetchalldata is empty
      return Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(), // or any other placeholder or message
        ),
      );
    }
  }

Widget getFileWidget(title) {
String agreement = '';
if(title =='Floor Plan'){
 agreement = fetchalldata[0]['floor_plan'];
}
else if(title =='Electrical Plan'){
 agreement = fetchalldata[0]['elec_plan'];
}
else if(title =='Plumbing Plan'){
 agreement = fetchalldata[0]['plumb_plan'];
}
else if(title =='Center Line Plan'){
 agreement = fetchalldata[0]['cl_plan'];
}
else if(title =='Section Plan'){
 agreement = fetchalldata[0]['sec_plan'];
}
else{
 agreement = '';
}
    if (agreement.isNotEmpty) {
      if (agreement.toLowerCase().endsWith('.pdf')) {
        // Display PDF
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.picture_as_pdf, size: 70), 
          Text(agreement)],
        );
      } else if (agreement.toLowerCase().endsWith('.jpg') ||
          agreement.toLowerCase().endsWith('.jpeg') ||
          agreement.toLowerCase().endsWith('.png')) {
        // Display Image
        return InkWell(
         onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullPageImage(
                      imageUrl: '$backendIP/uploads/$agreement',
                    ),
                  ),
                );
              },
          child: Image(
              image: NetworkImage('$backendIP/uploads/$agreement'),
              fit: BoxFit.cover),
        );
      } else if (agreement.toLowerCase().endsWith('.doc') ||
          agreement.toLowerCase().endsWith('.docx')) {
        // Display Document - Use WebView for documents
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.description, size: 70), 
          Text(agreement)],
        );
      } else {
        // For other file types, display a generic icon or placeholder
        return Icon(Icons.insert_drive_file, size: 70);
      }
    } else {
      return Text('Empty');
    }
  }




// Future<dynamic> viewDocDialog(BuildContext context,  String title) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         content: getFileWidget(title),
//       );
//     },
//   );
// }



}
