import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';

//import 'add_plans.dart';
import 'package:file_picker/file_picker.dart';

import '../pages/widget.dart';
import 'layout_works.dart';

class Layout_Upload extends StatefulWidget {
  const Layout_Upload({Key? key}) : super(key: key);

  @override
  _Layout_UploadState createState() => _Layout_UploadState();
}

class _Layout_UploadState extends State<Layout_Upload> {
  String id = '';
  String cli_id = '';
  String plan_title = '';
  String whoIs = '';
  String layFile = '';
  var backendIP = ApiConstants.backendIP;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var plan_title11 = sharedPreferences.getString('plan_title');
    var id11 = sharedPreferences.getString('id');
    var user_id11 = sharedPreferences.getString('cli_id');
    var whoIs1 = sharedPreferences.getString('whoIs');
    var layFile1 = sharedPreferences.getString('layFile');
    if (user_id11 != null) {
      setState(() {
        cli_id = user_id11;
        id = id11!;
        plan_title = plan_title11!;
        whoIs = whoIs1!;
        layFile = layFile1!;
        print(id);
        print(cli_id);
        print(plan_title);
        print(whoIs);
        print(layFile);
        getUserdata();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Layout_Works()),
      );
    }
  }
bool isloading = false ;
  List fetchalldata = [];
  String fetchdataLength = '';
  Future<void> getUserdata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response =
          await http.post(apiUrl, body: {'action': 'CLIENT', 'user_id': cli_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchalldata = json.decode(response.body);
          fetchdataLength = fetchalldata.length.toString();
          print(fetchalldata);
          isloading = true;
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

  File? _pickedFile;
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Set to true if you allow multiple file selection
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png'
      ], // Add the extensions you want to allow
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString();
    String day = now.day.toString();
    String date = '$year-$month-$day';

    if (_pickedFile != null) {
      try {
        var apiUrl = '$backendIP/Add_layoutWork.php';
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields['plan_title'] = plan_title;
        request.fields['user_id'] = cli_id;
        request.fields['ag_date'] = date;
        request.files.add(await http.MultipartFile.fromPath(
          'user_file',
          _pickedFile!.path,
        ));

        final response = await request.send();
        if (response.statusCode == 200) {
          // Handle success
          final responseData = await response.stream.toBytes();
          final responseString = String.fromCharCodes(responseData);
          print('Response: $responseString');

          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.remove('cli_id');
          sharedPreferences.remove('id');
          sharedPreferences.remove('plan_title');

//checkLoginStatus();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Layout_Works()),
          // );
          Navigator.pop(context);
          Navigator.pop(context);
          DialogUtils.showSuccessDialog(context);
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File upload failed'),
            ),
          );
        }
      } catch (e) {
        // Handle exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
          ),
        );
      }
    }
  }

  Widget _displayFile() {
    if (_pickedFile != null) {
      String extension = _pickedFile!.path.split('.').last.toLowerCase();

      if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
        return Image.file(
          _pickedFile!,
          width: 250,
          height: 200,
          fit: BoxFit.cover,
        );
      } else if (extension == 'pdf') {
        // Display a PDF icon or placeholder
        return Icon(Icons.picture_as_pdf, size: 50);
      } else if (extension == 'doc' || extension == 'docx') {
        // Display a document icon or placeholder
        return Icon(Icons.description, size: 50);
      } else {
        // Display a generic icon or placeholder for other file types
        return Icon(Icons.insert_drive_file, size: 50);
      }
    } else {
      return Center(
          child: OutlinedButton(
              onPressed: () {
                _pickFile();
              },
              child: Text('Choose File')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 10,
        title: Text(plan_title),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body:
      isloading
      ? Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 31, 70, 85)),
        child: Center(
          child: Card(
            elevation: 20,
            shadowColor: Colors.white,
            child: Container(
              height:
             layFile.isNotEmpty
                ?600:500,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                     SizedBox(height: 20),
                    Image(
                      image: AssetImage('assets/images/logo_gm3.png'),
                      width: 100,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 250, // Set the width to control the size
                      height: 200, // Set the height to control the size
                      decoration: BoxDecoration(border: Border.all()),
                      child: 
                      whoIs == 'STAFF'
                      ?InkWell(
                         onTap: () {
                          // viewDocDialog(context, plan_title);
                        },
                        child: getFileWidget(plan_title))
                      :_displayFile(),
                    ),
                    SizedBox(height: 20),
                    _pickedFile != null
                        ? InkWell(
                            onTap: () {
                              _upload();
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              child: Card(
                                  color: Color.fromARGB(255, 209, 101, 0),
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  )),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 10),

                    whoIs == 'STAFF' 
                    ?Container()
                    :Container(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                
                     layFile.isNotEmpty
                    ? Column(
                      children: [
                         SizedBox(height: 20,),
                        Text('Last Updated File:'),
                         Text(layFile,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 185, 111, 0)),),
                         Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child:  getFileWidget2(),
                         ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             OutlinedButton(onPressed: (){
                              String agreementUrl =
                                    '$backendIP/uploads/$layFile';
                                _launchURL(agreementUrl);
                             }, child: Text('Download')),
                             whoIs == 'ADMIN'   
                                ?OutlinedButton(onPressed: (){
                                  Deletedialog(context);
                                }, child: Text('Delete'))
                                :Container(),
                           ],
                         ),
                  SizedBox(height: 10,)
                      ],
                    )
                    : Container()
                  ],
                ),
              ),
            ),
          ),
        ),
      )
      :Center(child: CircularProgressIndicator())
    );
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
          children: [Icon(Icons.picture_as_pdf, size: 70), //Text(agreement)
          ],
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
          children: [Icon(Icons.description, size: 70), //Text(agreement)
          ],
        );
      } else {
        // For other file types, display a generic icon or placeholder
        return Icon(Icons.insert_drive_file, size: 70);
      }
    } else {
      return Center(child: Text('Empty'));
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






  Widget getFileWidget2() {
    String agreement = layFile;

    if (agreement.isNotEmpty) {
      if (agreement.toLowerCase().endsWith('.pdf')) {
        // Display PDF
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.picture_as_pdf, size: 60), 
         // Text(agreement)
          ],
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
                height: 50,
              ),
            ),
            
            //Text(agreement)
          ],
        );
      } else if (agreement.toLowerCase().endsWith('.doc') ||
          agreement.toLowerCase().endsWith('.docx')) {
        // Display Document - Use WebView for documents
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.description, size: 60), 
         // Text(agreement)
          ],
        );
      } else {
        // For other file types, display a generic icon or placeholder
        return Icon(Icons.insert_drive_file, size: 60);
      }
    } else {
      return Text(
        'Empty',
        style: TextStyle(fontSize: 20),
      );
    }
  }






 Future<dynamic> Deletedialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
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
                    "Are you Deleted $plan_title ?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary:  Colors.red, // Change the background color
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
                         del_File();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green, // Change the background color
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




  void del_File() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Delete_Files.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'action': plan_title,
        'id': id,
        'cli_id': cli_id,
        'cliFile': layFile,

      });
      print(cli_id);
      if (response.statusCode == 200) {
        print(response.body);
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.remove('cli_id');
        sharedPreferences.remove('layFile');
       
        // Navigate to LoginPage after logout
         checkLoginStatus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Center(child: Text('File Deleted Successfully')),
            ),
          );
       
      }
    } catch (e) {
      print('the error is $e');
    }
  }



  void _launchURL(String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      print('Error launching URL: $e');
      // Handle the error gracefully, perhaps showing a message to the user
    }
  }

}
