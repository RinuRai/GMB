import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../pages/loginpage.dart';
import '../pages/view_client.dart';
import 'FullViewIMG.dart';

class Client_Profile extends StatefulWidget {
  const Client_Profile({super.key});

  @override
  State<Client_Profile> createState() => _Client_ProfileState();
}

class _Client_ProfileState extends State<Client_Profile> {

  var backendIP = ApiConstants.backendIP;


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  bool isloading = false;
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
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }


  List fetchalldata = [];
  String fetchdataLength = '';
   String elevation = '';

  Future<void> getUserdata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response =
          await http.post(apiUrl, body: {'action': whoIs, 'user_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchalldata = json.decode(response.body);
          fetchdataLength = fetchalldata.length.toString();
          elevation = fetchalldata[0]['elev_lay'];
          isloading = true;
          print(fetchalldata);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }


  List imageUrls = [
    {'img': 'assets/images/bg10.jpg', 'price': '\$ 42.50k'},
    {'img': 'assets/images/bg16.jpg', 'price': '\$ 45.25k'},
    {'img': 'assets/images/bg7.jpg', 'price': '\$ 38.10k'},
    {'img': 'assets/images/bg8.jpg', 'price': '\$ 48.25k'},
    {'img': 'assets/images/bg14.jpg', 'price': '\$ 30.5k'}
  ];






  void view_client(cliId, cliusId) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => View_Client_DT()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('cliId', cliId);
    sharedPreferences.setString('cliusId', cliusId);
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(

         appBar: AppBar(
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
          toolbarHeight: 100,
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white,letterSpacing: 2),
          ),
        ),

      body: 
        isloading
            ? 
            Container(
                decoration: BoxDecoration(),
               // height: MediaQuery.of(context).size.height-180,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                      height: 100,
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
                                              color: Colors.transparent),
                                          height: 40,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              view_client(
                                                  cl_id.toString(), cl_us_id);
                                            },
                                            child: Text('Show Details'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    elevation.isNotEmpty
                      ?Card(
                        child: Container(
                          height: 500,
                                width: double.infinity,
                          child: Column(
                            children: [
                               SizedBox(height: 20,),
                              Text('ELEVATION',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 3,color: Color.fromARGB(255, 253, 93, 0)),),
                              SizedBox(height: 20,),
                              Center(child: InkWell(
                                 onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullPageImage(
                                          imageUrl: '$backendIP/uploads/$elevation',
                                        ),
                                      ),
                                    );
                                  },
                                child: Image(image: NetworkImage('$backendIP/uploads/$elevation'),height: 400,))),
                            ],
                          )),
                      )
                      :SingleChildScrollView(
                          child: Container(
                            height: 500,
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Find The\nPerfect Home',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Discover the best home for You',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black45),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      CarouselSlider.builder(
                                        itemCount: imageUrls.length,
                                        itemBuilder: (BuildContext context,
                                            int index, int realIndex) {
                                          return Stack(children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          imageUrls[index]['img']),
                                                      fit: BoxFit.cover),
                                                  borderRadius:
                                                      BorderRadius.circular(10)),
                                            ),
                                              
                                            // Positioned(
                                            //   top: 20,
                                            //   left: 20,
                                            //   child: Text('Urban\nApartment',style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: Colors.white),)
                                            //   ),
                                            Positioned(
                                                top: 30,
                                                left: 30,
                                                child: Container(
                                                    height: 40,
                                                    width: 120,
                                                    color:
                                                        Color.fromARGB(78, 0, 0, 0),
                                                    child: Center(
                                                        child: Text(
                                                      imageUrls[index]['price'],
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )))),
                                          ]);
                                        },
                                        options: CarouselOptions(
                                          height: 380,
                                          enlargeCenterPage: false,
                                          autoPlay: true,
                                          autoPlayInterval: Duration(seconds: 3),
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 800),
                                          enableInfiniteScroll: true,
                                          viewportFraction: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ),
                  ],
                ),
              )


            : Center(child: CircularProgressIndicator())
      
    );
  }
}