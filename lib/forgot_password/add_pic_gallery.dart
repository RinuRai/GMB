import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../forgot_password/FullViewIMG.dart';
import '../pages/loginpage.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:intl/intl.dart';


class Add_Gallery_Pic extends StatefulWidget {
  const Add_Gallery_Pic({super.key});

  @override
  State<Add_Gallery_Pic> createState() => _Add_Gallery_PicState();
}

class _Add_Gallery_PicState extends State<Add_Gallery_Pic> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String cliId = '';
  String cliusId = '';
  String whoIs = '';
  String name = '';
  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var cliId11 = sharedPreferences.getString('clId');
    var cliusId11 = sharedPreferences.getString('clusId');
    var clnam11 = sharedPreferences.getString('clnam');
    if (whoIs1 != null && cliId11 != null && cliusId11 != null) {
      setState(() {
        whoIs = whoIs1;
        cliId = cliId11;
        cliusId = cliusId11;
        name = clnam11!;
        print(cliusId);
       // getClidata();
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

  bool isloading = false;
  List fetchGlList = [];
  String fetchdataLength = '';

  List fetchGlremoveList = [];

 Future<void> getGlryList() async {
    print(cliusId);
    try {

      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl, body: {
        'action': 'Gallery_list_All',
        'cli_id': cliusId.toString(), // Convert to string here
      });
      if (response.statusCode == 200) {
        setState(() {
          print('hi');
          List fetchedList = json.decode(response.body);
          print(fetchedList);

          // Filter images within three days from the current date
          List withinThreeDaysList = List.from(fetchedList);
          withinThreeDaysList.removeWhere((item) =>
              !isWithinThreeDaysFromCurrentDate(item['time'], item['id'], item['pic_nm']));
          fetchGlList = withinThreeDaysList;
          print(fetchGlList);

          // Filter images before three days from the current date
          List beforeThreeDaysList = List.from(fetchedList);
          beforeThreeDaysList.removeWhere((item) =>
              !beforeThreeDaysFromCurrentDate(item['time'], item['id'], item['pic_nm']));
          fetchGlremoveList = beforeThreeDaysList;
          print(fetchGlremoveList);

          // Extract IDs and image names from fetchGlremoveList
          List<Map<String, dynamic>> idsAndNamesToRemove =
              fetchGlremoveList.map<Map<String, dynamic>>((item) => {'id': item['id'], 'pic_nm': item['pic_nm']}).toList();
          if (fetchGlremoveList.isNotEmpty) {
            deleteImages(idsAndNamesToRemove);
          } else {
            // Handle empty list case if needed
          }

          fetchdataLength = fetchGlList.length.toString();
          isloading = true;
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

bool isWithinThreeDaysFromCurrentDate(String dateString, String imageId, String imageName) {
  print(imageId);
  print(imageName);
  DateTime currentDate = DateTime.now();
  DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
  int differenceInDays = currentDate.difference(date).inDays;
  return differenceInDays <= 3;
}

bool beforeThreeDaysFromCurrentDate(String dateString, String imageId, String imageName) {
  print(imageId);
  print(imageName);
  DateTime currentDate = DateTime.now();
  DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
  int differenceInDays = currentDate.difference(date).inDays;
  return differenceInDays >= 3;
}


void deleteImages(List<Map<String, dynamic>> idsAndNamesToRemove) async {
  print(idsAndNamesToRemove);
  try {
    var apiUrl = Uri.parse('$backendIP/delete_images.php');
    var response = await http.post(apiUrl, body: {
     'action': 'delete_images_GL', // Change action to 'delete_images_GL'
     'data': json.encode(idsAndNamesToRemove),
    });
    if (response.statusCode == 200) {
       print(response.body);
    }
    else{
      print(response.body);
      print('error');
    }
  } catch (e) {
    print('error $e');
  }
}


// Future<Uint8List?> _compressImage(File file, int targetSizeInKB) async {
//   final int targetSizeInBytes = targetSizeInKB * 1024; // Convert KB to bytes
//   int quality = 90; // Initial quality value

//   Uint8List? result;

//   while (quality >= 0) {
//     result = await FlutterImageCompress.compressWithFile(
//       file.absolute.path,
//       quality: quality,
//     );

//     print('Quality: $quality, Result Length: ${result!.length}');

//     if (result.length <= targetSizeInBytes) {
//       // If the compressed image is within the target size, return it
//       return result;
//     }

//     // Calculate the next quality value based on the current quality and image size
//     quality = ((quality * targetSizeInBytes) / result.length).floor();
//   }

//   // If unable to compress within the target size, return null
//   return null;
// }



bool togle = false;
var backendIP = ApiConstants.backendIP;

ImagePicker picker = ImagePicker();
XFile? _pickedImage;
bool uploadpic = false;

// Future<void> _pickImage1() async {
//   final pickedImage = await picker.pickImage(source: ImageSource.camera);

//   if (pickedImage != null) {
//     // Pass target size in KB to _compressImage function
//     Uint8List? compressedImage = await _compressImage(File(pickedImage.path), 100);

//     if (compressedImage != null) {
//       // Save the compressed image to a file
//       final tempDir = await getTemporaryDirectory();
//       final tempPath = tempDir.path;
//       final tempFile = await File('$tempPath/compressed_image.jpg').writeAsBytes(compressedImage);

//       setState(() {
//         _pickedImage = XFile(tempFile.path);
//         uploadpic = true;
//         // You can now use _pickedImage for displaying, saving, or uploading.
//         // For example, you can call _upload() to upload the compressed image.
//         _upload();
//       });
//     } else {
//       // Handle case where compression failed
//       print('Compression failed: compressedImage is null');
//     }
//   }
// }

  void _pickImage1() async {
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
        uploadpic = true;
        _upload();
      });
    }
  }

  void _pickImage2() async {
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
    print(cliusId);
    print(name);
    if (_pickedImage != null) {
      List<int> imageBytes = await File(_pickedImage!.path).readAsBytes();

      var imageFile = http.MultipartFile.fromBytes(
        'user_image',
        imageBytes,
        filename: 'user_image.jpg',
      );

      var apiUrl =
          '$backendIP/gallery.php'; // Replace with your server's API endpoint
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['clid'] = cliusId;
      request.fields['name'] = name;
      request.files.add(imageFile);

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          // Upload successful, handle the response if needed
          final responseData = await response.stream.toBytes();
          final responseString = String.fromCharCodes(responseData);
          print('Response: $responseString');
          setState(() {
            getGlryList();
          });
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Center(child: Text('photo upload successfully',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
          ));
        } else {
          // Handle HTTP error
          print('HTTP Error: ${response.statusCode}');
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
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
        toolbarHeight: togle ? 320 : 80,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('assets/images/logo_gm3.png'),
                  width: 80,
                ),
                togle
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            togle = false;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_circle_up,
                          size: 30,
                        ))
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            togle = true;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          size: 30,
                        ))
              ],
            ),
            togle
                ? Container(
                    height: 240,
                    child: Column(
                      children: [
                        Divider(),
                        ListTile(
                          title: Text('GALLERY'),
                          trailing: Icon(Icons.arrow_drop_down),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('Residential building'),
                          trailing: Icon(Icons.arrow_drop_down),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('Interior Design'),
                          trailing: Icon(Icons.arrow_drop_down),
                        ),
                        Divider(),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: whoIs == 'CLIENT'
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){ _pickImage1();}, icon: Icon(Icons.camera,size: 50,)),

                 SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  onPressed: () {
                    // Add your action for the first button
                    _pickImage2();
                  },
                  tooltip: 'Gallery',
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.add_a_photo_sharp),
                ),
               
              ],
            ),
      body: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black87),
            child: Center(
                child: Text('GALLERY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 6))),
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
                                          imageUrl: '$backendIP/pic_list/' +fetchGlList[index]['pic_nm'],
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
                                                '$backendIP/pic_list/' +
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
          )
        ],
      ),
    );
  }

Future<dynamic> galleryDialog(BuildContext context, img) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        content: SizedBox(
          width: double.infinity,
          child: PhotoViewGallery.builder(
            itemCount: 1, // Number of images in the gallery
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage('$backendIP/pic_list/' + img),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
            pageController: PageController(),
            onPageChanged: (index) {
              // Handle page change if needed
            },
          ),
        ),
      );
    },
  );
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
        'action': 'Dele-Image',
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
                  'Image Deleted',
                 style: TextStyle(
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
