import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';
import 'loginpage.dart';
import 'view_client.dart';

class Client_Detail extends StatefulWidget {
  const Client_Detail({super.key});

  @override
  State<Client_Detail> createState() => _Client_DetailState();
}

class _Client_DetailState extends State<Client_Detail> {
  
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


  void view_client(cliId, cliusId) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => View_Client_DT()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('cliId', cliId);
    sharedPreferences.setString('cliusId', cliusId);
  }

  bool togle = false;

// List filtter = [];
String Searching = '';
void serchdata(){
    setState(() {
      if(Searching.isNotEmpty){
       fetchalldata = fetchalldata.where((complaint) =>
        complaint['nm'].toString().toLowerCase().contains(Searching.toLowerCase())
    ).toList();
      }
      else{
        getUserdata();
      }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  togle
                      ? Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container( 
                                    height: 50,
                                    width: 220,
                                    
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          Searching = value;
                                          serchdata();
                                        });
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        
                                      border: InputBorder.none,
                                        
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        hintText: "Seach Here....",
                                        hintStyle:
                                            TextStyle(color: Colors.black),
                                        filled: true,
                                        //fillColor: const Color.fromARGB(255, 223, 217, 217),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.search,
                                        size: 40,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(
                              image: AssetImage('assets/images/logo_gm3.png'),
                              width: 80,
                            ),
                          ],
                        ),
                ],
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
        ),
        body: isloading
            ? 
            whoIs == 'ADMIN' ||  whoIs == 'STAFF'
            ?Container(
                decoration: BoxDecoration(),
               // height: MediaQuery.of(context).size.height-180,
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



      :whoIs == 'CLIENT'
      ?SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            Container(
              color: const Color.fromARGB(82, 158, 158, 158),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'ABOUT US',
                  style: TextStyle(
                     color: Color.fromARGB(255, 209, 101, 0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 248, 223, 0).withOpacity(0.3), // Shadow color
                      offset: Offset(2, 2), // Shadow offset
                      blurRadius: 4, // Shadow blur radius
                    ),
                  ],
                  ),
                   textAlign: TextAlign.center,
                ),
              ),
            ),
SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal:18,vertical: 10),
                decoration: BoxDecoration(border: Border.all(
                  width: 2,
                  color: Color.fromARGB(255, 209, 101, 0),
                )),
                child: Text('17',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
              ),
              SizedBox(width: 20,),
              Container(
               
                child: Column(
                  children: [
                    Text('Years\nWorking\nExperience',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ],
          ),


            ListTile(
              leading: Icon(Icons.info),
              title: Text('Our Story'),
              //subtitle: Text('Share your company\'s history and journey.'),
            ),
           Container(
  color: Colors.grey[200],
  padding: EdgeInsets.all(20),
  child: Text(
    'Established in 2005 by G.M construction in the Alappuzha district. In 2022, we changed the name to Green Marvel Builders and Developers Pvt Ltd. Our engineers conceive every apartment as a lovable place. What makes it different is the intelligent space layout and multi-functional design that ensure moving space and airflow. Uncommonly common amenities add to your conveniences. We have built a significant portfolio of successful projects bringing our depth of experience and in-house design, construction, and operational resources, to deliver fully integrated whole-life solutions.',
    style: TextStyle(
      fontSize: 16,
      color: Colors.black87, // Example color
      fontWeight: FontWeight.normal, // Example weight
      fontStyle: FontStyle.normal, // Example style
      letterSpacing: 1.2, // Example spacing
      height: 1.5, // Example line height
      // You can add more styling properties as needed
    ),
  ),
),

           
             SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.thumb_up),
              title: Text('Mission & Vision'),
             // subtitle: Text('Describe your company\'s mission and vision.'),
            ),
            Container(
  color: Colors.grey[200],
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Text(
        'That\’s when we started thinking deeply about it. There are so many people who want to build a dream home for themselves but unable to do it because of this difficulty.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87, // Example color
          fontWeight: FontWeight.normal, // Example weight
          fontStyle: FontStyle.normal, // Example style
          letterSpacing: 0.5, // Example spacing
          height: 1.5, // Example line height
          // You can add more styling properties as needed
        ),
      ),
      
       SizedBox(height: 20),
      Text(
        'The world is evolving towards the online market. We have a solution for everything online but not for construction.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87, // Example color
          fontWeight: FontWeight.normal, // Example weight
          fontStyle: FontStyle.normal, // Example style
          letterSpacing: 0.5, // Example spacing
          height: 1.5, // Example line height
          // You can add more styling properties as needed
        ),
      ),
       SizedBox(height: 20),
      Text(
        'There was a problem in it, they were just giving the contact information of the service providers.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87, // Example color
          fontWeight: FontWeight.normal, // Example weight
          fontStyle: FontStyle.normal, // Example style
          letterSpacing: 0.5, // Example spacing
          height: 1.5, // Example line height
          // You can add more styling properties as needed
        ),
      ),
    ],
  ),
),


            SizedBox(height: 20),
            Container(
              color: const Color.fromARGB(82, 158, 158, 158), 
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:30.0),
                child: Text(
                'DIRECTORS',
                style: TextStyle(
                  color:  Color.fromARGB(255, 209, 101, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 255, 251, 0).withOpacity(0.3), // Shadow color
                      offset: Offset(2, 2), // Shadow offset
                      blurRadius: 4, // Shadow blur radius
                    ),
                  ],
                ),
                  textAlign: TextAlign.center,
              ),
              
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                 decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 218, 218, 218))),
                  child: Column(
                    children: [
                      Image(image: AssetImage('assets/images/emt.jpg'),width: MediaQuery.of(context).size.width /3+20,),
                      SizedBox(height: 20,),
                      Text('ANEESH B.E',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),

                      Text('MANAGING DIRECTOR')
                    ],
                  )
                ),
                Container(
              decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 218, 218, 218))),
                  child: Column(
                    children: [
                      Image(image: AssetImage('assets/images/emt.jpg'),width: MediaQuery.of(context).size.width /3+20,),
                      SizedBox(height: 20,),
                      Text('AJEESH B.COM',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),

                      Text('DIRECTOR')
                    ],
                  )
                ),
              ],
            ),
             SizedBox(height: 40),
            Container(
              color: const Color.fromARGB(82, 158, 158, 158), 
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:30.0),
                child: Text(
                'CONTACT US',
                style: TextStyle(
                  color: Color.fromARGB(255, 209, 101, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 255, 238, 0).withOpacity(0.3), // Shadow color
                      offset: Offset(2, 2), // Shadow offset
                      blurRadius: 4, // Shadow blur radius
                    ),
                  ],
                ),
                  textAlign: TextAlign.center,
              ),
              
              ),
            ),
             Card(
               child: ListTile(
                leading: Icon(Icons.location_on,size: 40,),
                title: Text('GREEN MARVEL BUILDERS & DEVELOPERS',style: TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text('3rd Floor,Pulimootil Trade Center\nMullakkal ,Alappuzha-688011,Kerala'),
                           ),
             ),

            Card(
              child: ListTile(
                leading: Icon(Icons.call,size: 30,),
                title: Text('+91-9497218832 \n+91-8075193470 \n+91-9562720484',style: TextStyle(fontWeight: FontWeight.bold),),
                
              ),
            ),

             Card(
               child: ListTile(
                leading: Icon(Icons.mail,size: 30,),
                title: Text('info@greenmarvelbuilders.com',style: TextStyle(fontWeight: FontWeight.bold),),
                
                           ),
             ),

            SizedBox(height: 20),


            
                      fetchalldata[0]['spvs_nm'].isNotEmpty
                      ?Column(
                        children: [
                          Container(
                            width: double.infinity,
              color: const Color.fromARGB(82, 158, 158, 158), 
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:30.0),
                child: Text(
                'SUPERVISOR',
                style: TextStyle(
                  color:  Color.fromARGB(255, 209, 101, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 255, 251, 0).withOpacity(0.3), // Shadow color
                      offset: Offset(2, 2), // Shadow offset
                      blurRadius: 4, // Shadow blur radius
                    ),
                  ],
                ),
                  textAlign: TextAlign.center,
              ),
              
              ),
            ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              color: Color.fromARGB(158, 0, 0, 0),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:40,vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Details :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Center(
                                      child: ListTile(
                                        leading:CircleAvatar(
                                            radius: 25,
                                            backgroundImage:
                                                AssetImage('assets/images/emt.jpg'),
                                          ),
                                        title: Text(fetchalldata[0]['spvs_nm'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white)),
                                        subtitle: Text(fetchalldata[0]['spvs_num'],style: TextStyle(color: Colors.white)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      :Container(),
          ],
        ),
      )


              :Container( )



            : Center(child: CircularProgressIndicator()));
  }
}
















                    // whoIs == 'CLIENT'
                    //     ? SingleChildScrollView(
                    //       child: Container(
                    //         height: 500,
                    //           width: double.infinity,
                    //           child: Padding(
                    //             padding:
                    //                 const EdgeInsets.symmetric(horizontal: 15.0),
                    //             child: SingleChildScrollView(
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'Find The\nPerfect Home',
                    //                     style: TextStyle(
                    //                         fontSize: 25,
                    //                         fontWeight: FontWeight.bold),
                    //                   ),
                    //                   Text(
                    //                     'Discover the best home for You',
                    //                     style: TextStyle(
                    //                         fontSize: 15, color: Colors.black45),
                    //                   ),
                    //                   SizedBox(
                    //                     height: 20,
                    //                   ),
                    //                   CarouselSlider.builder(
                    //                     itemCount: imageUrls.length,
                    //                     itemBuilder: (BuildContext context,
                    //                         int index, int realIndex) {
                    //                       return Stack(children: [
                    //                         Container(
                    //                           decoration: BoxDecoration(
                    //                               image: DecorationImage(
                    //                                   image: AssetImage(
                    //                                       imageUrls[index]['img']),
                    //                                   fit: BoxFit.cover),
                    //                               borderRadius:
                    //                                   BorderRadius.circular(10)),
                    //                         ),
                                              
                    //                         // Positioned(
                    //                         //   top: 20,
                    //                         //   left: 20,
                    //                         //   child: Text('Urban\nApartment',style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: Colors.white),)
                    //                         //   ),
                    //                         Positioned(
                    //                             top: 30,
                    //                             left: 30,
                    //                             child: Container(
                    //                                 height: 40,
                    //                                 width: 120,
                    //                                 color:
                    //                                     Color.fromARGB(78, 0, 0, 0),
                    //                                 child: Center(
                    //                                     child: Text(
                    //                                   imageUrls[index]['price'],
                    //                                   style: TextStyle(
                    //                                       fontSize: 25,
                    //                                       fontWeight:
                    //                                           FontWeight.bold,
                    //                                       color: Colors.white),
                    //                                 )))),
                    //                       ]);
                    //                     },
                    //                     options: CarouselOptions(
                    //                       height: 380,
                    //                       enlargeCenterPage: false,
                    //                       autoPlay: true,
                    //                       autoPlayInterval: Duration(seconds: 3),
                    //                       autoPlayAnimationDuration:
                    //                           Duration(milliseconds: 800),
                    //                       enableInfiniteScroll: true,
                    //                       viewportFraction: 1,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //     )
                    //     : Container()





