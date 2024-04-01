import 'dart:convert';
import 'package:greenmarvelbuilders/pages/bottom_navigate.dart';
import 'package:greenmarvelbuilders/plan_list/layout_upload.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';

class Layout_Works extends StatefulWidget {
  const Layout_Works({super.key});

  @override
  State<Layout_Works> createState() => _Layout_WorksState();
}

class _Layout_WorksState extends State<Layout_Works> {
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
    var title11 = sharedPreferences.getString('layouttitle');
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null && title11 != null && title11.isNotEmpty) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        title = title11;
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
        context, MaterialPageRoute(builder: (context) => Layout_Upload()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('plan_title', title);
    sharedPreferences.setString('id', id);
    sharedPreferences.setString('cli_id', usid);
    sharedPreferences.setString('layFile', file);
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
            title: Text(
              title,
              style: TextStyle(
                  color: Colors.white, letterSpacing: 2, wordSpacing: 2),
            ),
            toolbarHeight: 80,
            centerTitle: true,
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
          ),
          body: Container(
              decoration: BoxDecoration(color: Colors.white),
              height: MediaQuery.of(context).size.height - 80,
              child: whoIs == 'ADMIN' || whoIs == 'STAFF'
                  ? ListView.builder(
                      itemCount: fetchalldata.length,
                      itemBuilder: (context, index) {
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
                        if (title == 'Plot Layout') {
                          plan = fetchalldata[index]['plot_lay'];
                          date = fetchalldata[index]['plot_dt'];
                        } else if (title == 'Elevation') {
                          plan = fetchalldata[index]['elev_lay'];
                          date = fetchalldata[index]['elev_dt'];
                        } else if (title == 'Brick Work Layout') {
                          plan = fetchalldata[index]['brick_lay'];
                          date = fetchalldata[index]['brick_dt'];
                        } else if (title == 'Shade Layout') {
                          plan = fetchalldata[index]['shade_lay'];
                          date = fetchalldata[index]['shade_dt'];
                        } else if (title == 'Structural Drawing') {
                          plan = fetchalldata[index]['stru_draw'];
                          date = fetchalldata[index]['stru_dt'];
                        } else if (title == 'Window Drawing') {
                          plan = fetchalldata[index]['wind_draw'];
                          date = fetchalldata[index]['wind_dt'];
                        } else if (title == 'Door Drawing') {
                          plan = fetchalldata[index]['door_draw'];
                          date = fetchalldata[index]['door_dt'];
                        } else {
                          plan = '';
                        }
                        // Extract data for each person

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 10),
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
                                                ?Container()
                                                :ElevatedButton(
                                                    onPressed: () {
                                                      add_ag(
                                                          fetchalldata[index]
                                                                  ['id']
                                                              .toString(),
                                                          fetchalldata[index]
                                                                  ['us_id']
                                                              .toString(),
                                                              plan);
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
                                                                color: Colors
                                                                    .white),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      add_ag(
                                                          fetchalldata[index]
                                                                  ['id']
                                                              .toString(),
                                                          fetchalldata[index]
                                                                  ['us_id']
                                                              .toString(),
                                                              plan);
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
                                                             ?'view $title'
                                                            : 'change $title',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                                     overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                    'Last updated on ' +(DateFormat('dd-MM-yyyy').format(DateTime.parse(date))),
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
                              Divider()
                            ],
                          ),
                        );
                      },
                    )
                  : title == 'Plot Layout'
                      ? Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          //decoration: BoxDecoration(color: Colors.transparent),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage('assets/images/bg5.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(
                                  .2), // Adjust the opacity value (0.5 in this case)
                              BlendMode.dstATop,
                            ),
                          )),
                          child: Center(
                            child: Container(
                              height: 500,
                              width: 300,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          'assets/images/logo_gm3.png'),
                                      width: 100,
                                    ),
                                   
                                    fetchalldata[0]['plot_dt'] != '0000-00-00'
                                        ? Text('Last Date On Update ' +
                                           (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['plot_dt']))) )
                                        : Container(
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
                                        width:
                                            250, // Set the width to control the size
                                        height:
                                            200, // Set the height to control the size
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                          color: Color.fromARGB(255, 209, 101, 0),
                                        )),
                                        child: InkWell(
                                             onTap: () {
                                         // viewDocDialog(context, 'Plot Layout');
                                      },
                                          child: Center(
                                            child: getFileWidget(title),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    fetchalldata[0]['plot_lay'].isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              String agreementUrl =
                                                  '$backendIP/uploads/${fetchalldata[0]['plot_lay']}';
                                              _launchURL(agreementUrl);
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              child: Card(
                                                color: Color.fromARGB(
                                                    255, 209, 101, 0),
                                                elevation: 10,
                                                shadowColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
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
                                                          fontWeight:
                                                              FontWeight.bold,
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
                        )
                      : title == 'Elevation'
                          ? Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              //decoration: BoxDecoration(color: Colors.transparent),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage('assets/images/bg12.jpg'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(
                                      .1), // Adjust the opacity value (0.5 in this case)
                                  BlendMode.dstATop,
                                ),
                              )),
                              child: Center(
                                child: Container(
                                  height: 500,
                                  width: 300,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(
                                              'assets/images/logo_gm3.png'),
                                          width: 100,
                                        ),
                                       
                                        fetchalldata[0]['elev_dt'] != '0000-00-00'
                                            ? Text('Last Date On Update ' +
                                               (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['elev_dt']))) )
                                            : Container(
                                                color: Colors.red,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 15.0,
                                                          vertical: 8),
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
                                            width:
                                                250, // Set the width to control the size
                                            height:
                                                200, // Set the height to control the size
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 209, 101, 0),
                                            )),
                                            child: InkWell(
                                                   onTap: () {
                                          //viewDocDialog(context, 'Elevation');
                                      },
                                              child: Center(
                                                child: getFileWidget(title),
                                              ),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        fetchalldata[0]['elev_lay'].isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  String agreementUrl =
                                                      '$backendIP/uploads/${fetchalldata[0]['elev_lay']}';
                                                  _launchURL(agreementUrl);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 200,
                                                  child: Card(
                                                    color: Color.fromARGB(
                                                        255, 209, 101, 0),
                                                    elevation: 10,
                                                    shadowColor: Colors.black,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Download',
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold,
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
                            )
                          : title == 'Brick Work Layout'
                              ? Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height,
                                  //decoration: BoxDecoration(color: Colors.transparent),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: AssetImage('assets/images/bg11.jpg'),
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(
                                          .2), // Adjust the opacity value (0.5 in this case)
                                      BlendMode.dstATop,
                                    ),
                                  )),
                                  child: Center(
                                    child: Container(
                                      height: 500,
                                      width: 300,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                  'assets/images/logo_gm3.png'),
                                              width: 100,
                                            ),
                                           
                                            fetchalldata[0]['brick_dt'] !=
                                                    '0000-00-00'
                                                ? Text('Last Date On Update ' +
                                                    (DateFormat('dd-MM-yyyy').format(DateTime.parse( fetchalldata[0]['brick_dt']))) )
                                                : Container(
                                                    color: Colors.red,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15.0,
                                                          vertical: 8),
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
                                                width:
                                                    250, // Set the width to control the size
                                                height:
                                                    200, // Set the height to control the size
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 209, 101, 0),
                                                )),
                                                child: InkWell(
                                                            onTap: () {
                                                             // viewDocDialog(context, 'Brick Work Layout');
                                                          },
                                                  child: Center(
                                                    child: getFileWidget(title),
                                                  ),
                                                )),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            fetchalldata[0]['brick_lay']
                                                    .isNotEmpty
                                                ? InkWell(
                                                    onTap: () {
                                                      String agreementUrl =
                                                          '$backendIP/uploads/${fetchalldata[0]['brick_lay']}';
                                                      _launchURL(agreementUrl);
                                                    },
                                                    child: Container(
                                                      height: 50,
                                                      width: 200,
                                                      child: Card(
                                                        color: Color.fromARGB(
                                                            255, 209, 101, 0),
                                                        elevation: 10,
                                                        shadowColor: Colors.black,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                        ),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'Download',
                                                                style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      1,
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
                                )
                              : title == 'Shade Layout'
                                  ? Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      //decoration: BoxDecoration(color: Colors.transparent),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/bg9.jpg'),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(
                                              .1), // Adjust the opacity value (0.5 in this case)
                                          BlendMode.dstATop,
                                        ),
                                      )),
                                      child: Center(
                                        child: Container(
                                          height: 500,
                                          width: 300,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image(
                                                  image: AssetImage(
                                                      'assets/images/logo_gm3.png'),
                                                  width: 100,
                                                ),
                                               
                                                fetchalldata[0]['shade_dt'] !=
                                                        '0000-00-00'
                                                    ? Text(
                                                        'Last Date On Update ' +
                                                            (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['shade_dt']))))
                                                    : Container(
                                                        color: Colors.red,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical: 8),
                                                          child: Text(
                                                            ' * No Any Attachments',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white),
                                                          ),
                                                        )),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Container(
                                                    width:
                                                        250, // Set the width to control the size
                                                    height:
                                                        200, // Set the height to control the size
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 209, 101, 0),
                                                    )),
                                                    child: InkWell(
                                                         onTap: () {
                                                             // viewDocDialog(context, 'Shade Layout');
                                                          },
                                                      child: Center(
                                                        child: getFileWidget(title),
                                                      ),
                                                    )),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                fetchalldata[0]['shade_lay']
                                                        .isNotEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          String agreementUrl =
                                                              '$backendIP/uploads/${fetchalldata[0]['shade_lay']}';
                                                          _launchURL(
                                                              agreementUrl);
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          width: 200,
                                                          child: Card(
                                                            color: Color.fromARGB(
                                                                255, 209, 101, 0),
                                                            elevation: 10,
                                                            shadowColor:
                                                                Colors.black,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
                                                            ),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Download',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      letterSpacing:
                                                                          1,
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
                                    )
                                  : title == 'Structural Drawing'
                                      ? Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          //decoration: BoxDecoration(color: Colors.transparent),
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/bg13.jpg'),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(
                                                  .1), // Adjust the opacity value (0.5 in this case)
                                              BlendMode.dstATop,
                                            ),
                                          )),
                                          child: Center(
                                            child: Container(
                                              height: 500,
                                              width: 300,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          'assets/images/logo_gm3.png'),
                                                      width: 100,
                                                    ),
                                                   
                                                    fetchalldata[0]['stru_dt'] !=
                                                            '0000-00-00'
                                                        ? Text(
                                                            'Last Date On Update ' +
                                                                (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['stru_dt']))))
                                                        : Container(
                                                            color: Colors.red,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                      vertical:
                                                                          8),
                                                              child: Text(
                                                                ' * No Any Attachments',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                        width:
                                                            250, // Set the width to control the size
                                                        height:
                                                            200, // Set the height to control the size
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                          color: Color.fromARGB(
                                                              255, 209, 101, 0),
                                                        )),
                                                        child: InkWell(
                                                           onTap: () {
                                                             // viewDocDialog(context, 'Structural Drawing');
                                                          },
                                                          child: Center(
                                                            child: getFileWidget(title),
                                                          ),
                                                        )),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    fetchalldata[0]['stru_draw']
                                                            .isNotEmpty
                                                        ? InkWell(
                                                            onTap: () {
                                                              String
                                                                  agreementUrl =
                                                                  '$backendIP/uploads/${fetchalldata[0]['stru_draw']}';
                                                              _launchURL(
                                                                  agreementUrl);
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              width: 200,
                                                              child: Card(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        209,
                                                                        101,
                                                                        0),
                                                                elevation: 10,
                                                                shadowColor:
                                                                    Colors.black,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                ),
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Download',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          letterSpacing:
                                                                              1,
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
                                        )
                                      : title == 'Window Drawing'
                                          ? Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              //decoration: BoxDecoration(color: Colors.transparent),
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/bg14.jpg'),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(
                                                      .1), // Adjust the opacity value (0.5 in this case)
                                                  BlendMode.dstATop,
                                                ),
                                              )),
                                              child: Center(
                                                child: Container(
                                                  height: 500,
                                                  width: 300,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              'assets/images/logo_gm3.png'),
                                                          width: 100,
                                                        ),
                                                       
                                                        fetchalldata[0]
                                                                    ['wind_dt'] !=
                                                                '0000-00-00'
                                                            ? Text(
                                                                'Last Date On Update ' +
                                                                    (DateFormat('dd-MM-yyyy').format(DateTime.parse( fetchalldata[0]['wind_dt']))))
                                                            : Container(
                                                                color: Colors.red,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                      vertical:
                                                                          8),
                                                                  child: Text(
                                                                    ' * No Any Attachments',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                            width:
                                                                250, // Set the width to control the size
                                                            height:
                                                                200, // Set the height to control the size
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border
                                                                        .all(
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      209,
                                                                      101,
                                                                      0),
                                                            )),
                                                            child: InkWell(
                                                              onTap: () {
                                                             // viewDocDialog(context, 'Window Drawing');
                                                          },
                                                              child: Center(
                                                                child:
                                                                    getFileWidget(title),
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        fetchalldata[0]
                                                                    ['wind_draw']
                                                                .isNotEmpty
                                                            ? InkWell(
                                                                onTap: () {
                                                                  String
                                                                      agreementUrl =
                                                                      '$backendIP/uploads/${fetchalldata[0]['wind_draw']}';
                                                                  _launchURL(
                                                                      agreementUrl);
                                                                },
                                                                child: Container(
                                                                  height: 50,
                                                                  width: 200,
                                                                  child: Card(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            209,
                                                                            101,
                                                                            0),
                                                                    elevation: 10,
                                                                    shadowColor:
                                                                        Colors
                                                                            .black,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              40),
                                                                    ),
                                                                    child: Center(
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .center,
                                                                        children: [
                                                                          Text(
                                                                            'Download',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize:
                                                                                  17,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              letterSpacing:
                                                                                  1,
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
                                            )
                                          : title == 'Door Drawing'
                                              ? Container(
                                                  width: double.infinity,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  //decoration: BoxDecoration(color: Colors.transparent),
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/bg15.jpg'),
                                                    fit: BoxFit.cover,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      Colors.black.withOpacity(
                                                          .2), // Adjust the opacity value (0.5 in this case)
                                                      BlendMode.dstATop,
                                                    ),
                                                  )),
                                                  child: Center(
                                                    child: Container(
                                                      height: 500,
                                                      width: 300,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image(
                                                              image: AssetImage(
                                                                  'assets/images/logo_gm3.png'),
                                                              width: 100,
                                                            ),
                                                           
                                                            fetchalldata[
                                                                            0][
                                                                        'door_dt'] !=
                                                                    '0000-00-00'
                                                                ? Text('Last Date On Update ' +
                                                                    (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['door_dt']))))
                                                                : Container(
                                                                    color: Colors
                                                                        .red,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15.0,
                                                                          vertical:
                                                                              8),
                                                                      child: Text(
                                                                        ' * No Any Attachments',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    )),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                                width:
                                                                    250, // Set the width to control the size
                                                                height:
                                                                    200, // Set the height to control the size
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border:
                                                                            Border
                                                                                .all(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          209,
                                                                          101,
                                                                          0),
                                                                )),
                                                                child: InkWell(
                                                                     onTap: () {
                                                             // viewDocDialog(context, 'Door Drawing');
                                                          },
                                                                  child: Center(
                                                                    child:
                                                                        getFileWidget(title),
                                                                  ),
                                                                )),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            fetchalldata[0][
                                                                        'door_draw']
                                                                    .isNotEmpty
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      String
                                                                          agreementUrl =
                                                                          '$backendIP/uploads/${fetchalldata[0]['door_draw']}';
                                                                      _launchURL(
                                                                          agreementUrl);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 50,
                                                                      width: 200,
                                                                      child: Card(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            209,
                                                                            101,
                                                                            0),
                                                                        elevation:
                                                                            10,
                                                                        shadowColor:
                                                                            Colors
                                                                                .black,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(40),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Row(
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
                                                )
                                              : Container()));
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
    if (title == 'Plot Layout') {
      agreement = fetchalldata[0]['plot_lay'];
    } else if (title == 'Elevation') {
      agreement = fetchalldata[0]['elev_lay'];
    } else if (title == 'Brick Work Layout') {
      agreement = fetchalldata[0]['brick_lay'];
    } else if (title == 'Shade Layout') {
      agreement = fetchalldata[0]['shade_lay'];
    } else if (title == 'Structural Drawing') {
      agreement = fetchalldata[0]['stru_draw'];
    } else if (title == 'Window Drawing') {
      agreement = fetchalldata[0]['wind_draw'];
    } else if (title == 'Door Drawing') {
      agreement = fetchalldata[0]['door_draw'];
    } else {
      agreement = '';
    }
    if (agreement.isNotEmpty) {
      if (agreement.toLowerCase().endsWith('.pdf')) {
        // Display PDF
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.picture_as_pdf, size: 70), Text(agreement)],
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
          children: [Icon(Icons.description, size: 70), Text(agreement)],
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
