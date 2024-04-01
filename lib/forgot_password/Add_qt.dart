import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

import '../pages/loginpage.dart';
import 'FullViewIMG.dart';



class Add_qc_data extends StatefulWidget {
  const Add_qc_data({super.key});

  @override
  State<Add_qc_data> createState() => _Add_qc_dataState();
}

class _Add_qc_dataState extends State<Add_qc_data> {
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
        getClidata();
        getGlryList();
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  List fetchGlList = [];
  String fetchdataLength = '';
  bool isloading = false;
  String name = '';
  String number = '';
  String address = '';

  Future<void> getGlryList() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl, body: {
        'action': 'QCPIC_list_All',
        'cli_id': cliusId,
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchGlList = json.decode(response.body);
          fetchdataLength = fetchGlList.length.toString();
          isloading = true;
          print(fetchGlList);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

  Map<String, dynamic> fetchclidata = {};

  Future<void> getClidata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl,
          body: {'action': 'Det_Cli', 'cli_id': cliId, 'clius_id': cliusId});
      if (response.statusCode == 200) {
        setState(() {
          fetchclidata = json.decode(response.body);

          print(fetchclidata);
          name = fetchclidata['nm'];
          number = fetchclidata['phn'];
          address = fetchclidata['addr'];
          isloading = true;
        });
      }
    } catch (e) {
      print('error $e');
    }
  }


 String content = '';


ImagePicker picker = ImagePicker();
XFile? _pickedImage;
 bool uploadpic = false;
void _pickImagecam() async {
  final pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
    setState(() {
      _pickedImage = pickedImage;
      uploadpic = true;
      
        _upload();
    });
  }
}

void _pickImagegal() async {
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
    setState(() {
      _pickedImage = pickedImage;
      uploadpic = true;
        _upload();
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

    var apiUrl = '$backendIP/QC.php'; // Replace with your server's API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['user_id'] = cliusId;
    request.fields['name'] = name;
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
          content: Center(child: Text('photo upload succesfully',style: TextStyle(
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
          content: Center(child: Text('photo not upload',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
        ));
      }
    } catch (e) {
      // Handle network-related errors
      print('Network Error: $e');
    }
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
            ? SingleChildScrollView(
                child: Column(
                  children: [

                     Container(
                      height: 80,
                      width: double.infinity,
                      color: Color.fromARGB(255, 235, 235, 235),
                       child: Center(
                         child: Text(
                          name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                                             ),
                       ),
                     ),

                    Container(
                       height: 80,
                      width: double.infinity,
                      color: Color.fromARGB(64, 223, 223, 223),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){
                             _pickImagecam();
                          },
                           tooltip: 'Camera',
                                       
                                        icon: Icon(Icons.add_a_photo_sharp,size: 40,color: Color.fromARGB(255, 0, 104, 189),),
                          ),
                      
                        SizedBox(width: 30,),
                           IconButton(onPressed: (){
                               _pickImagegal();
                          },
                         
                                        tooltip: 'gallery',
                                        icon: Icon(Icons.add_photo_alternate_sharp,size: 50,color: Color.fromARGB(255, 0, 104, 189),),
                          ),
                         
                      
                        
                          // OutlinedButton(onPressed: (){
                      
                          // }, child: Text('Remove',style: TextStyle(color: Colors.red,fontSize: 16),)),
                        ],
                      ),
                    ),
                   Column(
            children: [
              isloading
                  ? 
                fetchGlList.isNotEmpty  
                  ?Container(
                      height: MediaQuery.of(context).size.height-200,
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
                                onLongPress: () {
                                  whoIs == 'CLIENT'
                                      ? null
                                      : _showDeleteOption(
                                          context,
                                          index,
                                          fetchGlList[index]['id']
                                              .toString());
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
                      height: 500,
                     child: Center(child: Text('No Gallery')))
                  : Container(
                     height: 500,
                    child: Center(child: CircularProgressIndicator()))
      
            ],
          ),
                   

               
                   
                   
                    
                    
                    
                   
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

 


  void _showDeleteOption(BuildContext context, int index, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Image?"),
          content: Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement the delete logic here
                _deleteImage(id);
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage(id) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Delete_Accout.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'action': 'Dele-Image-qcpic',
        'id': id,
      });
      print(id);
      if (response.statusCode == 200) {
        print(response.body);
        getGlryList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Image Deleted',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('the error is $e');
    }
  }


}
