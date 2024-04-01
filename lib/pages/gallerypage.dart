import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';

import '../forgot_password/FullViewIMG.dart';
import '../forgot_password/add_pic_gallery.dart';
import 'loginpage.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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

        if(whoIs =='ADMIN' || whoIs =='STAFF')
        {
        setState(() {
            getUserdata();
            whoIs =='STAFF'
            ?loadDisableList()
            :null;
        });
        }else if(whoIs =='CLIENT'){
          getGlryList();
        }
        else{
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
     List fetchGlremoveList = [];
  Future<void> getGlryList() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl, body: {
        'action': 'Gallery_list_All',
        'cli_id': user_id.toString(),
      });
      if (response.statusCode == 200) {
        setState(() {
           print('hi');
          List fetchedList = json.decode(response.body);

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
        List<Map<String, dynamic>> idsAndNamesToRemove = fetchGlremoveList.map<Map<String, dynamic>>((item) => {'id': item['id'], 'pic_nm': item['pic_nm']}).toList();
        if(fetchGlremoveList.isNotEmpty){
          deleteImages(idsAndNamesToRemove);
        }
        else{
          null;
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
  


  bool togle = false;

  var backendIP = ApiConstants.backendIP;
  
  void view_gallery(cliId, cliusId,nm) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Add_Gallery_Pic()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('clId', cliId);
    sharedPreferences.setString('clusId', cliusId);
    sharedPreferences.setString('clnam', nm);
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
      
      body: Column(
        children: [
          Container(
            height: 70,
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
          whoIs == 'ADMIN' || whoIs == 'STAFF'
          ? SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(),
                height: MediaQuery.of(context).size.height-250,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Expanded(
                      // Wrap the ListView.builder with Expanded
                      child: ListView.builder(
                        itemCount: fetchalldata.length,
                        itemBuilder: (context, index) {
                          String cl_us_id = fetchalldata[index]['us_id'];
                          String cl_id = fetchalldata[index]['id'].toString();
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          AssetImage('assets/images/emt.jpg'),
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
      
                                    SizedBox(width: 10,),
                                    
                                    IconButton(
                                      tooltip: 'Add photo',
                                      onPressed: (){
                                        view_gallery(
                                                cl_id.toString(), cl_us_id,cl_name);
                                      }, icon: Icon(Icons.add_a_photo_sharp,size: 30,color: Color.fromARGB(255, 29, 143, 0),)),
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
              ),
          )
          :whoIs == 'CLIENT'
                        ? fetchGlList.isNotEmpty  
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
                                          imageUrl: '$backendIP/pic_list/' +fetchGlList[index]['pic_nm'],
                                        ),
                                      ),
                                    );
                                  },
                                
                                child: fetchGlList[index]['pic_nm'] != null &&
                                        fetchGlList[index]['pic_nm'].isNotEmpty
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
                :Container()
      
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


}



 