import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'disable_client.dart';

class Diable_Staff_list extends StatefulWidget {
  const Diable_Staff_list({super.key});

  @override
  State<Diable_Staff_list> createState() => _Diable_Staff_listState();
}

class _Diable_Staff_listState extends State<Diable_Staff_list> {

 var backendIP = ApiConstants.backendIP;



  @override
  void initState() {
    super.initState();
    getSTFdata();
  }

bool isloading = false ;
List fetchstfdata = [];

Future<void> getSTFdata() async {

    try {
      var apiUrl = Uri.parse('$backendIP/STAFF-dtls.php');
      var response = await http.post(apiUrl,
          body: {'action': 'STAFF-LIST','whois': "STAFF"});
      if (response.statusCode == 200) {
        setState(() {
          fetchstfdata = json.decode(response.body);
          isloading = true ;
          print(fetchstfdata);
        });
      }
      else{
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          elevation: 10,
          title: Text(
            'Select STAFF',
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
            ?  Container(
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
                            itemCount: fetchstfdata.length,
                            itemBuilder: (context, index) {
                              String stf_us_id = fetchstfdata[index]['ad_nm'];
                              // String stf_id =
                              //     fetchstfdata[index]['id'].toString();
                              String stf_name = fetchstfdata[index]['name'];
                              // String up_date = fetchstfdata[index]['price'];
                              String stf_num = fetchstfdata[index]['phn'];
                              
                             
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
                                              '$stf_name'.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                             '$stf_num',
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
                                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>DisableClient(stfid: stf_us_id)));
                                                },
                                                child: Text(
                                                  'Client List'),
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
                 
                
            : Center(child: CircularProgressIndicator())

    );
  }
}