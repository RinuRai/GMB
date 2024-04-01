import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';

import '../pages/loginpage.dart';
import 'Add_qt.dart';
import 'FullViewIMG.dart';

class qc_Cntl extends StatefulWidget {
  const qc_Cntl({super.key});

  @override
  State<qc_Cntl> createState() => _qc_CntlState();
}

class _qc_CntlState extends State<qc_Cntl> {
  var backendIP = ApiConstants.backendIP;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

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
        getUserdata();
        
         whoIs =='STAFF'
            ?loadDisableList()
            :null;

        if(whoIs == 'CLIENT'){
          setState(() {
            getGlryList();
          });
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

  bool isloading = false;
  List fetchalldata = [];
  String fetchdataLength = '';
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



  List fetchGlList = [];
  String fetchdataLength2= '';



  Future<void> getGlryList() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl, body: {
        'action': 'QCPIC_list_All',
        'cli_id': user_id,
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchGlList = json.decode(response.body);
          fetchdataLength2 = fetchGlList.length.toString();
          isloading = true;
          print(fetchGlList);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }



  void view_qc(cliId, cliusId) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Add_qc_data()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('cliId', cliId);
    sharedPreferences.setString('cliusId', cliusId);
  }

  bool togle = false;

// List filtter = [];
  String Searching = '';
  void serchdata() {
    setState(() {
      if (Searching.isNotEmpty) {
        fetchalldata = fetchalldata
            .where((complaint) => complaint['nm']
                .toString()
                .toLowerCase()
                .contains(Searching.toLowerCase()))
            .toList();
      } else {
        getUserdata();
      }
    });
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
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          elevation: 10,
          title: Text(
            'QUALITY CONTROL',
            style:
                TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
          ),
          centerTitle: true,
          toolbarHeight: 80,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
        ),
        body: isloading
            ? whoIs == 'ADMIN' || whoIs == 'STAFF'
                ? Container(
                    decoration: BoxDecoration(),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          // Wrap the ListView.builder with Expanded
                          child: ListView.builder(
                            itemCount: fetchalldata.length,
                            itemBuilder: (context, index) {
                              String cl_us_id = fetchalldata[index]['us_id'];
                              String cl_id =
                                  fetchalldata[index]['id'].toString();
                              String cl_name = fetchalldata[index]['nm'];
                              // String up_date = fetchalldata[index]['price'];
                              String cl_num = fetchalldata[index]['phn'];
                              // String rating = florData[index]['rating'];
                              // bool liked = florData[index]['liked'];

                             bool isDisabled = fetchDisablelist.any((disableItem) => disableItem['cli_id'] == cl_us_id);
                               if(whoIs == 'STAFF'){
                                 if (isDisabled) {
                                  return SizedBox.shrink(); // Skip rendering this item
                                }
                               } 
                               else{null;}


                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
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
                                                  '$cl_name'.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  cl_num,
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
                                                  height: 40,
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      view_qc(cl_id.toString(),
                                                          cl_us_id);
                                                    },
                                                    child: Text('Add Data'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Divider()
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: Color.fromARGB(255, 235, 235, 235),
                      child: Center(
                        child: Text(
                          fetchalldata[0]['nm'].toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                     Column(
                            children: [
                             
                                fetchGlList.isNotEmpty  
                                  ?Container(
                  height: MediaQuery.of(context).size.height-250,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: GridView.builder(
                      itemCount: fetchGlList
                          .length, // Replace with the actual number of items
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0, // Spacing between columns
                        mainAxisSpacing: 10.0, // Spacing between rows
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        // Replace this Container with your widget for each grid item
                        return InkWell(
                             onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullPageImage(
                                      imageUrl: '$backendIP/qc_picture/' +fetchGlList[index]['pic_nm'],
                                    ),
                                  ),
                                );
                              },
                           
                            child: fetchGlList[index]['pic_nm'] != null &&
                                    fetchGlList[index]['pic_nm']
                                        .isNotEmpty
                                ? Image(
                                    image:
                                         NetworkImage(
                                            '$backendIP/qc_picture/' +
                                                fetchGlList[index]
                                                    ['pic_nm']),
                                     
                                    fit: BoxFit.cover,
                                  )
                                : Center(child: CircularProgressIndicator()));
                      },
                    ),
                  ),
                )
                :Container(
                  height: 400,
                 child: Center(child: Text('No Gallery')))
                                 
                      
                            ],
                          ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )
            : Center(child: CircularProgressIndicator()));
  }
}
