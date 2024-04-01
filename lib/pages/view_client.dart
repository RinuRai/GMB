import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';
import 'client_details.dart';
import 'loginpage.dart';

class View_Client_DT extends StatefulWidget {
  const View_Client_DT({super.key});

  @override
  State<View_Client_DT> createState() => _View_Client_DTState();
}

class _View_Client_DTState extends State<View_Client_DT> {
  var backendIP = ApiConstants.backendIP;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String cliId = '';
  String cliusId = '';
  String whoIs = '';
  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var cliId11 = sharedPreferences.getString('cliId');
    var cliusId11 = sharedPreferences.getString('cliusId');
    if (whoIs1 != null && cliId11 != null && cliusId11 != null) {
      setState(() {
        whoIs = whoIs1;
        cliId = cliId11;
        cliusId = cliusId11;
        getClidata(cliId,cliusId);
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
  Map<String, dynamic> fetchclidata = {};
  List Cli_Files = [];

  String name = '';
  String number = '';
  String address = '';

  final TextEditingController _userName = TextEditingController();
    final TextEditingController _number = TextEditingController();
      final TextEditingController _addr = TextEditingController();
            final TextEditingController _usid = TextEditingController();
                  final TextEditingController _psd = TextEditingController();
      
String newnm = '' ;
String newnumb = '' ;
String newaddr = '' ;

bool isediting = false;

  Future<void> getClidata(id,usid) async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl,
          body: {'action': 'Det_Cli', 'cli_id': id, 'clius_id': usid});
      if (response.statusCode == 200) {
        setState(() {
          fetchclidata = json.decode(response.body);

          print(fetchclidata);
          name = fetchclidata['nm'];
          number = fetchclidata['phn'];
          address = fetchclidata['addr'];
          _userName.text = name;
          _number.text = number;
          _addr.text = address;
           _usid.text = fetchclidata['us_id'];
            _psd.text = fetchclidata['us_ps'];

          Cli_Files = [
            {
              'title': 'Agreement',
              'file': fetchclidata['agreement'],
            },
            {
              'title': 'Floor Plan',
              'file': fetchclidata['floor_plan'],
            },
            {
              'title': 'Electrical',
              'file': fetchclidata['elec_plan'],
            },
            {
              'title': 'Plumbing',
              'file': fetchclidata['plumb_plan'],
            },
            {
              'title': 'CenterLine Plan',
              'file': fetchclidata['cl_plan'],
            },
            {
              'title': 'Section Plan',
              'file': fetchclidata['sec_plan'],
            },
            {
              'title': 'Plot Layout',
              'file': fetchclidata['plot_lay'],
            },
            {
              'title': 'Elevation layout',
              'file': fetchclidata['elev_lay'],
            },
            {
              'title': 'Brick Work',
              'file': fetchclidata['brick_lay'],
            },
            {
              'title': 'Shade Work',
              'file': fetchclidata['shade_lay'],
            },
            {
              'title': 'Structural Drawing',
              'file': fetchclidata['stru_draw'],
            },
            {
              'title': 'Window Drawing',
              'file': fetchclidata['wind_draw'],
            },
            {
              'title': 'Door Drawing',
              'file': fetchclidata['door_draw'],
            },
          ];

          isloading = true;
        });
      }
    } catch (e) {
      print('errorrr $e');
    }
  }

  void del_Acc() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Delete_Accout.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'action': 'Dele',
        'cliId': cliId,
        'cliusId': cliusId,
      });
      print(cliId);
      if (response.statusCode == 200) {
        print(response.body);
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.remove('cliId');
        sharedPreferences.remove('cliusId');

        // Navigate to LoginPage after logout
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Client_Detail()),
        );
        SnackBar(content: Text("Account Deleted Successfully",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),));
      }
    } catch (e) {
      print('the error is $e');
    }
  }


  final _formKey = GlobalKey<FormState>();

void submit_data(uid,id,name,num,addr,newid,newpass)async{

    print(uid);
    print(id);
    print(name);
    print(num);
    print(addr);
    print(newid);
    print(newpass);
  try {
      var apiUrl = Uri.parse(
          '$backendIP/update_profile.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Update-cli-profile',
        'usId': uid,
        'id': id,
        'name': name,
        'num': num,
        'addr': addr,
         'newid': newid,
        'newpass': newpass,

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
                  'Update Changed',
                  style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );
       setState(() {
        getClidata(id,newid);
        isediting = false;
       });
       
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
          ),
        );
        setState(() {
          isediting = false;
        });
      }
    } catch (e) {
      print('Change error $e');
    }

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isloading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height /2-80,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/bg14.jpg'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white),
                              height: 70,
                              width: MediaQuery.of(context).size.width,
                            )),
                        Positioned(
                            bottom: 10,
                            left: MediaQuery.of(context).size.width /2 -60,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  AssetImage('assets/images/emt.jpg'),
                            )),
                      ],
                    ),
                    
                    Form(
                       key: _formKey,
                      child: Column(
                        children: [
                          isediting
                      ? Container(
                        width: 200,
                        child: TextFormField(
                           controller: _userName,
                                  onChanged: (value) {
                                    setState(() {
                                      newnm = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Name';
                                    }
                                    return null;
                                  },
                                  
                          decoration: InputDecoration(
                             labelText: 'Name',
                            border:OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 238, 238, 238),
                            filled: true,
                          ),
                        
                        ),
                      )
                      :Text(
                        name.toUpperCase(),
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                        SizedBox(
                        height: 10,
                      ), 
                      isediting
                      ? Container(
                        width: 200,
                        child: TextFormField(
                           controller: _number,
                                  onChanged: (value) {
                                    setState(() {
                                      newnumb = value;
                                    });
                                  },
                                 validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Phone Number';
                                  } else if (value.length != 10 ||
                                      !value.contains(RegExp(r'^[0-9]+$'))) {
                                    return 'Please enter a valid 10-digit Phone Number';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                  
                          decoration: InputDecoration(
                            labelText: 'Number',
                            border:OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 238, 238, 238),
                            filled: true,
                          ),
                        
                        ),
                      )
                      :Text(number,style: TextStyle(fontSize: 16),),
                                         SizedBox(
                        height: 10,
                      ), 
                                         
                   isediting
                      ? Container(
                        width: 200,
                        child: TextFormField(
                           controller: _addr,
                                  onChanged: (value) {
                                    setState(() {
                                      newaddr = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter value';
                                    }
                                    return null;
                                  },
                                  
                          decoration: InputDecoration(
                             labelText: 'Address',
                            border:OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 238, 238, 238),
                            filled: true,
                          ),
                        
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on),
                          Text(address,style: TextStyle(fontSize: 16),),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ), 

                      isediting
                      ? Container(
                        width: 200,
                        child: TextFormField(
                           controller: _usid,
                                 
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter value';
                                    }
                                    return null;
                                  },
                                  
                          decoration: InputDecoration(
                             labelText: 'User Id',
                            border:OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 238, 238, 238),
                            filled: true,
                          ),
                        
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          Text('ID :  ',style: TextStyle(fontSize: 20),),
                          Container(
                             width: 100,
                            padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            child: Center(
                              child: Text(fetchclidata['us_id'].toString(),style: TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),),
                            )),
                        ],
                      ),

                        SizedBox(
                        height: 10,
                      ), 

                       isediting
                      ? Container(
                        width: 200,
                        child: TextFormField(
                           controller: _psd,
                                 
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter value';
                                    }
                                    return null;
                                  },
                                  
                          decoration: InputDecoration(
                             labelText: 'Password',
                            border:OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 238, 238, 238),
                            filled: true,
                          ),
                        
                        ),
                      )
                      : whoIs == 'CLIENT' || whoIs == 'ADMIN'
                        ?Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Password :  ',style: TextStyle(fontSize: 20),),
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            child: Center(
                              child: Text(fetchclidata['us_ps'].toString(),style: TextStyle(
                              fontSize: 17,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),),
                            )),
                            
                        ],
                      ):Container(),


                        ],
                      ),
                    ),
                     SizedBox(
                      height:
                      20,
                    ),
                    // isediting
                    // ?Container()
                    // : Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                          
                    //       Text('ID :  ',style: TextStyle(fontSize: 20),),
                    //       Container(
                    //          width: 100,
                    //         padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
                    //         decoration: BoxDecoration(
                    //           border: Border.all()
                    //         ),
                    //         child: Center(
                    //           child: Text(fetchclidata['us_id'].toString(),style: TextStyle(
                    //           fontSize: 17,
                    //           color: Colors.blue,
                    //           fontWeight: FontWeight.bold),),
                    //         )),
                    //     ],
                    //   ),
                    //   SizedBox(
                    //   height: 20,
                    // ),

                    // isediting
                    // ? Container()
                    //     :whoIs == 'CLIENT' || whoIs == 'ADMIN'
                    //     ?Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text('Password :  ',style: TextStyle(fontSize: 20),),
                    //       Container(
                    //         width: 100,
                    //         padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
                    //         decoration: BoxDecoration(
                    //           border: Border.all()
                    //         ),
                    //         child: Center(
                    //           child: Text(fetchclidata['us_ps'].toString(),style: TextStyle(
                    //           fontSize: 17,
                    //           color: Colors.red,
                    //           fontWeight: FontWeight.bold),),
                    //         )),
                            
                    //     ],
                    //   ):Container(),

                     
                    
                    whoIs == 'ADMIN'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                             

                             isediting     
                              ? ElevatedButton(
                                
                                  onPressed: () {
                                     if (_formKey.currentState!.validate()) {
                                 FocusManager.instance.primaryFocus?.unfocus();
                               submit_data(fetchclidata['us_id'].toString(),fetchclidata['id'].toString(),_userName.text,_number.text,_addr.text,_usid.text,_psd.text);
                              }
                                    
                                  },
                                   style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  // You can customize other properties here, like text color, padding, etc.
                                ),
                                  child: Text('Submit',style: TextStyle(color: Colors.white),))
                                :   OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      isediting = true;
                                    });
                                  },
                                  child: Text('Edit Profile')),

                              SizedBox(
                                width: 10,
                              ),

                              OutlinedButton(
                                  onPressed: () {
                                    logoutdialog(context);
                                  },
                                  child: Text('Delete Profile')),
                            ],
                          )
                        : Container(),


                         fetchclidata['spvs_nm'].isNotEmpty
                      ?Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:50,vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Supervisor Details :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                Center(
                                  child: ListTile(
                                    leading:CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            AssetImage('assets/images/emt.jpg'),
                                      ),
                                    title: Text(fetchclidata['spvs_nm'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                    subtitle: Text(fetchclidata['spvs_num']),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      :Container(),
                        
                    whoIs == 'ADMIN' || whoIs == 'STAFF'
                    ? Card(
                      elevation: 1,
                      child: Container(
                       height: 250,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            itemCount: Cli_Files
                                .length, // Replace with the actual number of items
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5.0, // Spacing between columns
                              mainAxisSpacing: 5.0, // Spacing between rows
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              // Replace this Container with your widget for each grid item
                              return Column(
                                children: [
                                  Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Rounded corners
                                      side: BorderSide(
                                        color: Colors.grey, // Border color
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromARGB(255, 255, 254, 254),
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Match the card's shape
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              Cli_Files[index]['title'].toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              //viewDocDialog(Cli_Files, index);
                                            },
                                            child: getFileWidget(Cli_Files, index)),
                                        ],
                                      ),
                                    ),
                                  ),
                                 
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    :Container()
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

  Widget getFileWidget(List cli_files, int index) {
    if (index < cli_files.length) {
      var agreement = cli_files[index]['file'];

      if (agreement != null && agreement.isNotEmpty) {
        if (agreement.toLowerCase().endsWith('.pdf')) {
          // Display PDF
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  agreement,
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        } else if (agreement.toLowerCase().endsWith('.jpg') ||
            agreement.toLowerCase().endsWith('.jpeg') ||
            agreement.toLowerCase().endsWith('.png')) {
          // Display Image
          return Column(
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
                  height: 40,
                  // fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  agreement,
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        } else if (agreement.toLowerCase().endsWith('.doc') ||
            agreement.toLowerCase().endsWith('.docx')) {
          // Display Document - Use WebView for documents
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  agreement,
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        } else {
          // For other file types, display a generic icon or placeholder
          return Icon(Icons.insert_drive_file, size: 40);
        }
      } else {
        return Icon(
          Icons.cancel_sharp,
          color: Colors.black26,
          size: 30,
        );
      }
    } else {
      return Center(child: Text('No Atachments'));
    }
  }

// Future<dynamic> viewDocDialog(List cli_files, int index) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.transparent,
//         content: getFileWidget2(cli_files, index),
//       );
//     },
//   );
// }


  Widget getFileWidget2(List cli_files, int index) {
    String agreement = '';
    if (cli_files.isNotEmpty) {
      agreement = cli_files[index]['file'];
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
        return Image(
            image: NetworkImage('$backendIP/uploads/$agreement'),
            fit: BoxFit.cover);
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


  Future<dynamic> logoutdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            content: Container(
              height: 250,
              // decoration: BoxDecoration(
              //   color: Colors.red
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_sharp,
                    color: Colors.red,
                    size: 50,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Are you Deleted This Account?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
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
                          del_Acc();
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
