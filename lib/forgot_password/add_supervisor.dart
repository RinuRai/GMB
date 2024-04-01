import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

import '../pages/loginpage.dart';
import 'Add_qt.dart';

class Add_Supervisor extends StatefulWidget {
  const Add_Supervisor({super.key});

  @override
  State<Add_Supervisor> createState() => _Add_SupervisorState();
}

class _Add_SupervisorState extends State<Add_Supervisor> {
  var backendIP = ApiConstants.backendIP;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String whoIs = '';
  String user_id = '';
String spvtitle = '';

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    var spvtitle1 = sharedPreferences.getString('supertitle');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        spvtitle = spvtitle1!;
        getUserdata();

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
            '$spvtitle',
            style:
                TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
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
            ? whoIs == 'ADMIN'
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
                              String spv_nm = fetchalldata[index]['spvs_nm'];
                               String spv_num = fetchalldata[index]['spvs_num'].toString();
                              // String rating = florData[index]['rating'];
                              // bool liked = florData[index]['liked'];
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
                                             'Supervisor Name : '+ spv_nm,
                                              style: TextStyle(
                                                fontSize:
                                                    15, // Change the fontSize as needed
                                                // Add other styles as needed
                                              ),
                                            ),
                                             Text(
                                             'Supervisor Number : '+ spv_num,
                                              style: TextStyle(
                                                fontSize:
                                                    15, // Change the fontSize as needed
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
                                                  _showAddDialog(context,cl_name,cl_us_id,cl_id);
                                                },
                                                child: Text(
                                                  spv_nm.isNotEmpty
                                                  ?'Change'
                                                  :'Add'),
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
                          ),
                        ),
                      ],
                    ),
                  )
                  :Container()
                
            : Center(child: CircularProgressIndicator()));
  }


  final _formKey = GlobalKey<FormState>();
  String name = '';
  int number = 0;

  Future<void> _showAddDialog(BuildContext context,nm,uid,id) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController numberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Supervisor Details')),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                                              '$nm'.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  
                   validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                 
                ),
                TextFormField(
                  controller: numberController,
                  decoration: InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                   validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Phone Number';
                                } else if (value.length != 10 ||
                                    !value.contains(RegExp(r'^[0-9]+$'))) {
                                  return 'Please enter a valid 10-digit Phone Number';
                                }
                                return null;
                              },
                 
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                                 FocusManager.instance.primaryFocus?.unfocus();
                              add_supervisor(uid,id,nameController.text.toString(),numberController.text.toString());
                              }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


void add_supervisor(uid,id,name,num)async{

    print(uid);
    print(id);
    print(name);
    print(num);

  try {
      var apiUrl = Uri.parse(
          '$backendIP/add_supervisor.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Add-Spervisor-Dtl',
        'usId': uid.toString(),
        'id': id.toString(),
        'supname': name.toString(),
        'supnum': num.toString(),

      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Supervisor Added to $uid',style: TextStyle(
                  color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );
       setState(() {
        Navigator.pop(context);
        checkLoginStatus();
       });
       
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed Add',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
          ),
        );
        
      }
    } catch (e) {
      print('Change error $e');
    }

}




}
