import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../pages/loginpage.dart';
import 'package:image_picker/image_picker.dart';

class Profile_View extends StatefulWidget {
  const Profile_View({super.key});

  @override
  State<Profile_View> createState() => _Profile_ViewState();
}

class _Profile_ViewState extends State<Profile_View> {
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
    var cliusId11 = sharedPreferences.getString('user_id');
    if (whoIs1 != null && cliId11 != null && cliusId11 != null) {
      setState(() {
        whoIs = whoIs1;
        cliId = cliId11;
        cliusId = cliusId11;
        getClidata();
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

  String name = '';
  String number = '';
  String address = '';

  Future<void> getClidata() async {
    try {
      print(whoIs);
      print(cliusId);
      var apiUrl = Uri.parse('$backendIP/STAFF-dtls.php');
      var response = await http.post(apiUrl,
          body: {'action': 'FETCH-AD-STF','who': whoIs,'clius_id': cliusId});
      if (response.statusCode == 200) {
        setState(() {
          fetchclidata = json.decode(response.body);
          print(fetchclidata);
          isloading = true ;
        });
      }
    } catch (e) {
      print('error: $e');
    }
  }


ImagePicker picker = ImagePicker();
XFile? _pickedImage;
 bool uploadpic = false;
void _pickImage() async {
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
    setState(() {
      _pickedImage = pickedImage;
      uploadpic = true;
    });
  }
}

void _upload() async {
  if (_pickedImage != null) {
    List<int> imageBytes = await File(_pickedImage!.path).readAsBytes();

    var imageFile = http.MultipartFile.fromBytes(
      'user_image',
      imageBytes,
      filename: 'user_image.jpg', 
    );

    var apiUrl = '$backendIP/Change_profile.php'; // Replace with your server's API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['user_id'] = cliusId;
    request.files.add(imageFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Upload successful, handle the response if needed
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Response: $responseString');
        setState(() {
           checkLoginStatus();
        });
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('photo upload succesfully',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
        ));
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('photo not upload',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
        ));
      }
    } catch (e) {
      // Handle network-related errors
      print('Network Error: $e');
    }
  }
}



  String Disabled = 'ALL';

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
                          height: 340,
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
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                            )),
                        Positioned(
                            bottom: 10,
                            left: MediaQuery.of(context).size.width /3 -10,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _pickedImage != null
                            ? FileImage(File(_pickedImage!.path)) as ImageProvider<Object>?
                            // ignore: unnecessary_null_comparison
                            : fetchclidata['pic'] != null && fetchclidata['pic'].isNotEmpty
                            ?NetworkImage('$backendIP/profile_pic/'+fetchclidata['pic'].toString())
                            :NetworkImage('$backendIP/profile_pic/emt.jpg'),
                            )),

                           Positioned(
                            bottom: -5,
                            left: MediaQuery.of(context).size.width / 2 +20,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: IconButton(onPressed: (){_pickImage();}, icon: Icon(Icons.camera_alt,size: 40,color: Colors.black,)))),  
                      ],
                    ),
                    uploadpic
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                               style: ElevatedButton.styleFrom(
    primary: Color.fromARGB(255, 194, 117, 1), // Background color
    onPrimary: Colors.white, // Text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // BorderRadius
    ),
    elevation: 4.0, // Elevation
  ),
                                  onPressed: () {
                                    _upload();
                                  },
                                  child: Text('Change Profile')),
                              
                            ],
                          )
                        : Container(),

                     SizedBox(height: 20,),
                      Text(
                          fetchclidata['name'].toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                       SizedBox(height: 20,),
                   
                   Card(
                    elevation: 10,
                     child: Container(
                      height: 150,
                      width: 300,
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                       
                        Text(fetchclidata['phn'],style: TextStyle(fontSize: 18),),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,size: 50,color: const Color.fromARGB(255, 0, 76, 138),),
                            Container(
                              width: 200,
                              child: Text(fetchclidata['addr'],style: TextStyle(fontSize: 16),)),
                          ],
                        ),
                        SizedBox(
                      height: 30,
                    ),
                        ],
                       ),
                     ),
                   ),
                    
                      SizedBox(
                      height: 30,
                    ),
                    whoIs == 'ADMIN' || whoIs == 'STAFF'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             
                              OutlinedButton(
                                  onPressed: () {},
                                  child: Text('Edit Profile')),
                              
                            ],
                          )
                        : Container(),
                        
                    
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }



}
