import 'dart:convert';
import 'package:greenmarvelbuilders/pages/bottom_navigate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../forgot_password/FullViewIMG.dart';
import 'adding_agreement.dart';

class Agreement extends StatefulWidget {
  const Agreement({Key? key}) : super(key: key);

  @override
  State<Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  var backendIP = ApiConstants.backendIP;
  String whoIs = '';
  String user_id = '';
  List fetchalldata = [];
  String fetchdataLength = '';

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        getUserdata();
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

  void add_ag(id, usid,filenm) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AG_Upload()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('id', id);
    sharedPreferences.setString('client_uid', usid);
    sharedPreferences.setString('client_file', filenm);
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
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: Text(
            whoIs == 'ADMIN' ? 'Add Agreement' : 'Agreement',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1,
              wordSpacing: 2,
              fontFamily:
                  'Satisfy', // Use the font family defined in pubspec.yaml
              fontSize: 22,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 4.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          toolbarHeight: 75,
          elevation: 10,
          centerTitle: true,
          shadowColor: Colors.black,
        ),
        body: isloading
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg1.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(
                                .4), // Adjust the opacity value (0.5 in this case)
                            BlendMode.dstATop,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Shadow color
                            spreadRadius: -1, // Negative spread radius
                            blurRadius: 9, // Blur radius
                            offset: Offset(0, 3), // Shadow position
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '“You construct a dream.\nWe will construct them into Reality”.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        height: MediaQuery.of(context).size.height - 170,
                        child: whoIs == 'ADMIN'
                            ? ListView.builder(
                                itemCount: fetchalldata.length,
                                itemBuilder: (context, index) {
                                  // Extract data for each person
                                  String name = fetchalldata[index]['nm'];
                                  String number = fetchalldata[index]['phn'];
                                  String aggrement =
                                      fetchalldata[index]['agreement'];
                                  String agree_date =
                                      fetchalldata[index]['agree_date'];
                                  return Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage: AssetImage(
                                                  'assets/images/emt.jpg'),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$name'.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      color:
                                                          Colors.transparent),
                                                  height: 80,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      aggrement.isEmpty
                                                          ? ElevatedButton(
                                                              onPressed: () {
                                                                add_ag(
                                                                    fetchalldata[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                                    fetchalldata[index]
                                                                            [
                                                                            'us_id']
                                                                        .toString(),
                                                                        fetchalldata[index]
                                                                            [
                                                                            'agreement']
                                                                        .toString(),);
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    'Add Agreement',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            209,
                                                                            101,
                                                                            0),
                                                              ),
                                                            )
                                                          : ElevatedButton(
                                                              onPressed: () {
                                                                add_ag(
                                                                    fetchalldata[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                                    fetchalldata[index]
                                                                            [
                                                                            'us_id']
                                                                        .toString(),
                                                                     fetchalldata[index]
                                                                            [
                                                                            'agreement']
                                                                        .toString(),);
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .verified_user,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    'change Agreement',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      agree_date != '0000-00-00'
                                                          ? Text(
                                                              'Last updated on  '+(DateFormat('dd-MM-yyyy').format(DateTime.parse(agree_date))),
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            )
                                                          : Text(
                                                              'No attachments',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                color: Colors
                                                                    .black,
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
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage('assets/images/bg2.jpg'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(
                                        .3), // Adjust the opacity value (0.5 in this case)
                                    BlendMode.dstATop,
                                  ),
                                )),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image: AssetImage(
                                            'assets/images/logo_gm3.png'),
                                        width: 100,
                                      ),
                                      // Text(
                                      //   fetchalldata[0]['nm'],
                                      //   style: TextStyle(fontSize: 30),
                                      // ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      fetchalldata[0]['agree_date'] !=
                                              '0000-00-00'
                                          ? Text('Last Date On Update ' +
                                             (DateFormat('dd-MM-yyyy').format(DateTime.parse(fetchalldata[0]['agree_date']))) )
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
                                        height: 30,
                                      ),
                                      Container(
                                          width:
                                              250, // Set the width to control the size
                                          height:
                                              200, // Set the height to control the size
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                            color:
                                                Color.fromARGB(255, 209, 101, 0),
                                          )),
                                          child: InkWell(
                                            onTap: () {
                                              //viewDocDialog(context);
                                            },
                                            child: Center(
                                              child: getFileWidget(),
                                            ),
                                          )),
                                      SizedBox(
                                        height: 40,
                                      ),
                                  
                                      fetchalldata[0]['agreement'].isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                String agreementUrl =
                                                    '$backendIP/uploads/${fetchalldata[0]['agreement']}';
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
                                        height: 20,
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              )),
                    // Container(
                    //   padding: EdgeInsets.all(15),
                    //   color: Colors.grey[300],
                    //   child: Center(
                    //     child: Text(
                    //       '“The greatest glory in living lies not in never falling, but in rising every time we fall.”\n- Nelson Mandela',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontStyle: FontStyle.italic,
                    //         color: Colors.black54,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

  Widget getFileWidget() {
    String agreement = fetchalldata[0]['agreement'];

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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
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
                height: 150,
              ),
            ),
            
            Text(agreement)
          ],
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
      return Text(
        'Empty',
        style: TextStyle(fontSize: 20),
      );
    }
  }




// Future<dynamic> viewDocDialog(BuildContext context) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return 
      
//       AlertDialog(
//         backgroundColor: Colors.white,
//         content: getFileWidget(),
//       );
      
//     },
//   );
// }

}
