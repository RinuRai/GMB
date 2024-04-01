// ignore_for_file: camel_case_types, non_constant_identifier_names, library_private_types_in_public_api, avoid_print, prefer_const_constructors, use_build_context_synchronously, unused_element, sized_box_for_whitespace, unnecessary_cast, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_unnecessary_containers, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:greenmarvelbuilders/pages/bottom_navigate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Disable_Function/disable_common_fuc.dart';
import '../config.dart';
import 'payment_dtls_upload.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Payment_Dtls extends StatefulWidget {
  const Payment_Dtls({super.key});

  @override
  State<Payment_Dtls> createState() => _Payment_DtlsState();
}

class _Payment_DtlsState extends State<Payment_Dtls> {
  var backendIP = ApiConstants.backendIP;
  String whoIs = '';
  String user_id = '';
  String title = '';
  List fetchalldata = [];
  String fetchdataLength = '';

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var title11 = sharedPreferences.getString('paytitle');
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        title = title11!;
        print(whoIs);
        print(user_id);
        print(title);
        if (whoIs == 'ADMIN' || whoIs == 'STAFF') {
          getUserdata();
           whoIs =='STAFF'
            ?loadDisableList()
            :null;
        } else if (whoIs == 'CLIENT') {
          if (title == 'Payment Details') {
            getClidata('DTL-FT-PAYMENT');
          } else if (title == 'Shedule') {
            getClidata('DTL-FT-SHEDULE');
          } else if (title == 'Check List') {
            getClidata('DTL-FT-CHECK');
          } else {
            print('error');
          }
          rmrkClidata();
        } else {
          print('error');
        }
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home_Navigator()),
      );
    }
  }

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




  String droptitle = 'All';

  Future<void> getClidata(String categry) async {
    print(categry);
    print(user_id);

    try {
      var apiUrl = Uri.parse('$backendIP/Fetch_pay_shed_check.php');
      var response = await http
          .post(apiUrl, body: {'action': categry, 'clius_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchalldata = json.decode(response.body);
          setState(() {
             isloading = true;
          });
          print(fetchalldata);
          fetchalldata[0]['titl'] != null && fetchalldata[0]['titl'].isNotEmpty
          ?droptitle = fetchalldata[0]['titl']
          :null;
         
        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  Map<String, dynamic> fetchrmrkdata = {};

  Future<void> rmrkClidata() async {
    print(user_id);

    try {
      var apiUrl = Uri.parse('$backendIP/Fetch_pay_shed_check.php');
      var response = await http.post(apiUrl,
          body: {'action': 'Titl-Rmrk_Data', 'clius_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchrmrkdata = json.decode(response.body);
          print(fetchrmrkdata);
          
        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  void add_ag(id, usid, nm) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Payment_Dtls_Upload()));
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('pay_title', title);
    sharedPreferences.setString('id', id);
    sharedPreferences.setString('cli_id', usid);
    sharedPreferences.setString('cli_nm', nm);
  }

  void _launchURL(String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      print('Error launching URL: $e');
      // Handle the error gracefully, perhaps showing a message to the user
    }
  }

  Future<void> downloadpayPDF() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Details',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                  decoration: pw.TextDecoration.underline)),
          pw.Table(
            defaultColumnWidth: pw.FlexColumnWidth(),
            border: pw.TableBorder.all(width: 2, color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  pw.Text('Sl.No',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Description',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Percentage',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Amount',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Status',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Date',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
              for (var data in fetchalldata)
                pw.TableRow(
                  children: [
                    pw.Text((fetchalldata.indexOf(data) + 1).toString()),
                    pw.Text(data['description'].toString(),
                        style: pw.TextStyle(fontSize: 16)),
                    pw.Text(data['percentage'].toString(),
                        style: pw.TextStyle(fontSize: 16)),
                    pw.Text(data['amt'].toString(),
                        style: pw.TextStyle(fontSize: 16)),
                    pw.Text(data['sts'].toString(),
                        style: pw.TextStyle(fontSize: 16)),
                    pw.Text(
                        DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(data['date'].toString())),
                        style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
            ],
          ),
        ],
      ),
    ));
    int randomNumber12 = Random().nextInt(1000);
    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/$randomNumber12 departments_report.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to $path'),
        backgroundColor: Colors.green,
      ),
    );
  }

///////////////////////////////////////////////////////////////////

  double calculateSubtotal(List dataList) {
    double subtotal = 0;
    for (var data in dataList) {
      subtotal += double.parse(data['amt'].toString());
    }
    return subtotal;
  }

//////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 31, 70, 85),
              // flexibleSpace: FlexibleSpaceBar(
              //   background: Image.asset(
              //     'assets/images/bg1.jpg', // Replace with your background image path
              //     fit: BoxFit.cover,
              //   ),
              title: Text(
                title.toUpperCase(),
                style: TextStyle(
                    color: Colors.white, fontSize: 20, letterSpacing: 2),
              ),
              centerTitle: true,
              // ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              toolbarHeight: 80,
              shadowColor: Colors.grey,
            ),
            body: Container(
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height - 80,
                child: whoIs == 'ADMIN' || whoIs == 'STAFF'
                    ? ListView.builder(
                        itemCount: fetchalldata.length,
                        itemBuilder: (context, index) {
                          Color getColor(int i) {
                            return i % 2 == 0
                                ? Colors.white
                                : const Color.fromARGB(255, 236, 232,
                                    232); // Alternates between black and grey
                          }

                          Color containerColor = getColor(index);
                          String name = fetchalldata[index]['nm'];
                          String number = fetchalldata[index]['phn'];

                          bool isDisabled = fetchDisablelist.any((disableItem) => disableItem['cli_id'] == fetchalldata[index]['us_id']);
                               if(whoIs == 'STAFF'){
                                 if (isDisabled) {
                                  return SizedBox.shrink(); // Skip rendering this item
                                }
                               } 
                               else{null;}

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              color: containerColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
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
                                            '$name',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            number,
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
                                            height: 80,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () {
                                                    add_ag(
                                                        fetchalldata[index]
                                                                ['id']
                                                            .toString(),
                                                        fetchalldata[index]
                                                                ['us_id']
                                                            .toString(),
                                                        fetchalldata[index]
                                                                ['nm']
                                                            .toString());
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.add),
                                                            Text(
                                                              'Add',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          '$title',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : title == 'Payment Details'
                        ? Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(color: Colors.white),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage('assets/images/bg5.jpg'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(
                                        .1), // Adjust the opacity value (0.5 in this case)
                                    BlendMode.dstATop,
                                  ),
                                )),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Image(
                                        image: AssetImage(
                                            'assets/images/logo_gm3.png'),
                                        width: 100,
                                      ),
                                      // Text(
                                      //   fetchalldata[0]['nm'],
                                      //   style: TextStyle(fontSize: 30),
                                      // ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                headingRowColor:
                                                    MaterialStateColor
                                                        .resolveWith(
                                                            (Set<MaterialState>
                                                                states) {
                                                  // For the default or other states
                                                  return Color.fromARGB(
                                                      255,
                                                      31,
                                                      70,
                                                      85); // Set your desired color
                                                }),
                                                headingTextStyle: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight
                                                      .bold, // Set your desired font weight
                                                  color: Colors
                                                      .white, // Set your desired text color
                                                ),
                                                columnSpacing:
                                                    10, // Adjust the spacing between columns as needed
                                                dataRowHeight: 50,
                                                border: TableBorder.all(),
                                                columns: <DataColumn>[
                                                  DataColumn(
                                                    label: Text('SL.NO.',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Description',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Percentage',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Amount',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Status',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Date',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                ],
                                                rows: fetchalldata
                                                    .asMap()
                                                    .entries
                                                    .map<DataRow>((entry) {
                                                  int index = entry.key;
                                                  dynamic data = entry.value;
                                                  int currentSerialNumber =
                                                      index + 1;
                                                  Color rowColor = index.isEven
                                                      ? Color.fromARGB(
                                                          36, 158, 158, 158)
                                                      : Colors.white;
                                                  return DataRow(
                                                    color: MaterialStateColor
                                                        .resolveWith(
                                                            (Set<MaterialState>
                                                                states) {
                                                      return rowColor; // Set the row color
                                                    }),
                                                    cells: [
                                                      DataCell(Text(
                                                          currentSerialNumber
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                      DataCell(Text(
                                                          data['description']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                      DataCell(Text(
                                                          data['percentage']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                      DataCell(Text(
                                                          data['amt']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                      DataCell(Text(
                                                          data['sts']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16))),
                                                      DataCell(
                                                        Text(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .parse(data[
                                                                          'date']
                                                                      .toString())),
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50,
                                            ),
                                            fetchalldata.isNotEmpty
                                                ? Container()
                                                : Container(
                                                    child: Column(
                                                      children: [
                                                        Text('No data found'),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),

                                      fetchalldata.isEmpty
                                          ? Container(
                                              color: Colors.red,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 8),
                                                child: Text(
                                                  ' * No Any Attachments',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ))
                                          : Container(),

                                      Container(
                                        height: 60,
                                        width: double.infinity,
                                        color: Color.fromARGB(255, 0, 53, 83),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Sub Total :',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                              Text(
                                                  ' ${calculateSubtotal(fetchalldata)}',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: 10,
                                      ),

                                      fetchalldata.isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                downloadpayPDF();
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 200,
                                                child: Card(
                                                  color: Color.fromARGB(
                                                      255, 0, 62, 112),
                                                  elevation: 10,
                                                  shadowColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Download',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : title == 'Shedule'
                            ? Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/bg7.jpg'),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.white.withOpacity(
                                            .05), // Adjust the opacity value (0.5 in this case)
                                        BlendMode.dstATop,
                                      ),
                                    )),
                                    child: Column(
                                      children: [
                                        // Container(
                                        //     height: 30,
                                        //     width: MediaQuery.of(context)
                                        //         .size
                                        //         .width,
                                        //     color:
                                        //         Color.fromARGB(255, 31, 70, 85),
                                        //     child: Center(
                                        //         child: Text(
                                        //       'Content Title:',
                                        //       style: TextStyle(
                                        //           letterSpacing: 4,
                                        //           wordSpacing: 5,
                                        //           color: Colors.white),
                                        //     ))),
                                        // Card(
                                        //   elevation: 10,
                                        //   child: Container(
                                        //     height: 60,
                                        //     width: MediaQuery.of(context)
                                        //         .size
                                        //         .width,
                                        //     padding: const EdgeInsets.symmetric(
                                        //         vertical: 5),
                                        //     decoration: BoxDecoration(
                                        //       color: Color.fromARGB(
                                        //           255, 255, 255, 255),
                                        //       borderRadius:
                                        //           BorderRadius.circular(0),
                                        //       border: Border.all(
                                        //         color: Colors.grey,
                                        //         width: 1,
                                        //       ),
                                        //     ),
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(
                                        //           left: 30.0),
                                        //       child: DropdownButton<String>(
                                        //         value: droptitle,
                                        //         onChanged:
                                        //             (String? newValue) async {
                                        //           if (newValue != null) {
                                        //             setState(() {
                                        //               droptitle = newValue;
                                        //             });
                                        //           }
                                        //         },
                                        //         items: [
                                        //           DropdownMenuItem<String>(
                                        //             value: 'All',
                                        //             child: Container(
                                        //               width: 150,
                                        //               child: Text(
                                        //                 'Select Title',
                                        //                 style: TextStyle(
                                        //                   fontSize: 16,
                                        //                   fontWeight:
                                        //                       FontWeight.bold,
                                        //                   color: Colors
                                        //                       .grey, // You can set a different color to indicate it's disabled
                                        //                 ),
                                        //                 overflow: TextOverflow
                                        //                     .ellipsis,
                                        //               ),
                                        //             ),
                                        //             onTap:
                                        //                 null, // Set onTap to null to make it not clickable
                                        //           ),
                                        //           ...Set<String>.from(
                                        //                   fetchalldata.map(
                                        //                       (data) =>
                                        //                           data['titl']))
                                        //               .where((value) =>
                                        //                   value.isNotEmpty)
                                        //               .map((value) =>
                                        //                   DropdownMenuItem<
                                        //                       String>(
                                        //                     value: value,
                                        //                     child: Container(
                                        //                       width:
                                        //                           250, // Set the maximum width you prefer
                                        //                       child: Text(
                                        //                         value,
                                        //                         style:
                                        //                             TextStyle(
                                        //                           fontSize: 16,
                                        //                           fontWeight: droptitle ==
                                        //                                   value
                                        //                               ? FontWeight
                                        //                                   .bold
                                        //                               : FontWeight
                                        //                                   .normal,
                                        //                         ),
                                        //                         overflow:
                                        //                             TextOverflow
                                        //                                 .ellipsis,
                                        //                       ),
                                        //                     ),
                                        //                   ))
                                        //               .toList(),
                                        //         ],
                                        //         underline: Container(),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Image(
                                                  image: AssetImage(
                                                      'assets/images/logo_gm3.png'),
                                                  width: 100,
                                                ),
                                                // Text(
                                                //   fetchalldata[0]['nm'],
                                                //   style: TextStyle(fontSize: 30),
                                                // ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                        height: 50,
                                                        child: Center(
                                                          child: Text(
                                                           fetchrmrkdata['shed_titl']!=null && fetchrmrkdata['shed_titl'].isNotEmpty
                                                            ?fetchrmrkdata['shed_titl']
                                                            :'Shedule',
                                                            style: TextStyle(
                                                                fontSize: 23,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all()),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all()),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .white,
                                                                  height: 50,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            15.0,
                                                                        left:
                                                                            15),
                                                                    child: Text(
                                                                      'CLIENT NAME :  ' +
                                                                          user_id
                                                                              .toUpperCase(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Container(
                                                        //   decoration: BoxDecoration(
                                                        //       border: Border.all()),
                                                        //   child: Row(
                                                        //     children: [
                                                        //       Expanded(
                                                        //         child: Container(
                                                        //           color: Colors.white,
                                                        //           height: 50,
                                                        //           child: Padding(
                                                        //             padding:
                                                        //                 const EdgeInsets
                                                        //                     .only(
                                                        //                     top: 15.0,
                                                        //                     left: 15),
                                                        //             child: Text(
                                                        //               'STARTING DATE :',
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //       Expanded(
                                                        //         child: Container(
                                                        //           color: Colors.white,
                                                        //           height: 50,
                                                        //           child: Padding(
                                                        //             padding:
                                                        //                 const EdgeInsets
                                                        //                     .only(
                                                        //                     top: 15.0,
                                                        //                     left: 15),
                                                        //             child: Text(
                                                        //               'COMPLIEION DATE :',
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child:
                                                                    DataTable(
                                                                        headingRowColor:
                                                                            MaterialStateColor.resolveWith((Set<MaterialState>
                                                                                states) {
                                                                          // For the default or other states
                                                                          return Colors
                                                                              .white; // Set your desired color
                                                                        }),
                                                                        headingTextStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold, // Set your desired font weight
                                                                          color:
                                                                              Colors.black, // Set your desired text color
                                                                        ),
                                                                        columnSpacing:
                                                                            15, // Adjust the spacing between columns as needed
                                                                        dataRowHeight:
                                                                            50,
                                                                        border:
                                                                            TableBorder.all(),
                                                                        columns: <DataColumn>[
                                                                      DataColumn(
                                                                        label: Text(
                                                                            'SL.NO.',
                                                                            style:
                                                                                TextStyle(fontSize: 16)),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                            'DESCRIPTION',
                                                                            style:
                                                                                TextStyle(fontSize: 16)),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                            'PRECENTAGE',
                                                                            style:
                                                                                TextStyle(fontSize: 16)),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                            'Start Date',
                                                                            style:
                                                                                TextStyle(fontSize: 16)),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                            'End Date',
                                                                            style:
                                                                                TextStyle(fontSize: 16)),
                                                                      ),
                                                                      // DataColumn(
                                                                      //   label: Text(
                                                                      //       'NA',
                                                                      //       style: TextStyle(
                                                                      //           fontSize:
                                                                      //               16)),
                                                                      // ),
                                                                    ],
                                                                        rows: [
                                                                      // DataRow(
                                                                      //   cells: [
                                                                      //     DataCell(
                                                                      //       Container(
                                                                      //         width: double
                                                                      //             .infinity,
                                                                      //         child:
                                                                      //             Text(
                                                                      //           '',
                                                                      //           style:
                                                                      //               TextStyle(fontSize: 18),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //     DataCell(
                                                                      //       Container(
                                                                      //         width: double
                                                                      //             .infinity,
                                                                      //         child:
                                                                      //             Text(
                                                                      //           'Pre-Construction',
                                                                      //           style: TextStyle(
                                                                      //               fontSize: 18,
                                                                      //               fontWeight: FontWeight.bold),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //     DataCell(
                                                                      //       Container(
                                                                      //         width: double
                                                                      //             .infinity,
                                                                      //         child:
                                                                      //             Text(
                                                                      //           '',
                                                                      //           style:
                                                                      //               TextStyle(fontSize: 18),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //     DataCell(
                                                                      //       Container(
                                                                      //         width: double
                                                                      //             .infinity,
                                                                      //         child:
                                                                      //             Text(
                                                                      //           '',
                                                                      //           style:
                                                                      //               TextStyle(fontSize: 18),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //     DataCell(
                                                                      //       Container(
                                                                      //         width: double
                                                                      //             .infinity,
                                                                      //         child:
                                                                      //             Text(
                                                                      //           '',
                                                                      //           style:
                                                                      //               TextStyle(fontSize: 18),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //   ],
                                                                      // ),
                                                                      ...fetchalldata
                                    .asMap()
                                    .entries
                                    .map<DataRow>((entry) {
                                                                        int index =
                                                                            entry.key;
                                                                        dynamic
                                                                            data =
                                                                            entry.value;
                                                                        int currentSerialNumber =
                                                                            index +
                                                                                1;
                                                                        Color rowColor = index.isEven
                                                                            ? Color.fromARGB(
                                                                                35,
                                                                                255,
                                                                                252,
                                                                                252)
                                                                            : Colors.white;
                                                                        return DataRow(
                                                                          color:
                                                                              MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                                                            return rowColor; // Set the row color
                                                                          }),
                                                                          cells: [
                                                                            DataCell(Text(currentSerialNumber.toString(),
                                                                                style: TextStyle(fontSize: 18))),
                                                                            // DataCell(Text(
                                                                            //     data['st_dt']
                                                                            //         .toString(),
                                                                            //     style: TextStyle(
                                                                            //         fontSize:
                                                                            //             18))),
                                                                            // DataCell(Text(
                                                                            //     data['ed_dt']
                                                                            //         .toString(),
                                                                            //     style: TextStyle(
                                                                            //         fontSize:
                                                                            //             18))),
                                                                            DataCell(Container(
                                                                              width: 110,
                                                                              child: Text(data['content'].toString(), style: TextStyle(fontSize: 18)),
                                                                            )),
                                                                            DataCell(Container(
                                                                              width: 110,
                                                                              child: Text(data['presentage'].toString(), style: TextStyle(fontSize: 18)),
                                                                            )),
                                                                            DataCell(Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(data['st_dt'])),
                                                                                style: TextStyle(fontSize: 16))),
                                                                            DataCell(Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(data['ed_dt'])),
                                                                                style: TextStyle(fontSize: 16))),
                                                                            // DataCell(Text(
                                                                            //     '',
                                                                            //     style:
                                                                            //         TextStyle(fontSize: 18))),
                                                                          ],
                                                                        );
                                                                      }).toList(),
                                                                    ]),
                                                              ),
                                                              fetchalldata
                                                                      .isNotEmpty
                                                                  ? Container()
                                                                  : Container(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Text(
                                                                              'No data found'),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        border:
                                                                            Border.all()),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        color: Colors
                                                                            .white,
                                                                        height:
                                                                            120,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 15.0,
                                                                              left: 15,
                                                                              right: 15),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Remarks :',
                                                                                style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                                                                              ),
                                                                              Center(
                                                                                child: Text(
                                                                                  fetchrmrkdata['shed_rmk'] != null && fetchrmrkdata['shed_rmk'].isNotEmpty ? fetchrmrkdata['shed_rmk'].toString() : '',
                                                                                  style: TextStyle(fontSize: 15),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                  height: 10,
                                                ),

                                                fetchalldata.isNotEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          downloadSHDCheckPDF2(
                                                              fetchalldata,
                                                              droptitle);
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          width: 200,
                                                          child: Card(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    0,
                                                                    62,
                                                                    112),
                                                            elevation: 10,
                                                            shadowColor:
                                                                Colors.black,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
                                                            ),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Download',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      letterSpacing:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : title == 'Check List'
                                ? Container(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height,
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/bg10.jpg'),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(
                                                .05), // Adjust the opacity value (0.5 in this case)
                                            BlendMode.dstATop,
                                          ),
                                        )),
                                        child: Column(
                                          children: [
                                            Container(
                                                height: 30,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Color.fromARGB(
                                                    255, 31, 70, 85),
                                                child: Center(
                                                    child: Text(
                                                  'Content Title:',
                                                  style: TextStyle(
                                                      letterSpacing: 4,
                                                      wordSpacing: 5,
                                                      color: Colors.white),
                                                ))),
                                            Card(
                                              elevation: 10,
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30.0),
                                                  child: DropdownButton<String>(
                                                    value: droptitle,
                                                    onChanged: (String?
                                                        newValue) async {
                                                      if (newValue != null) {
                                                        setState(() {
                                                          droptitle = newValue;
                                                        });
                                                      }
                                                    },
                                                    items: [
                                                      DropdownMenuItem<String>(
                                                        value: 'All',
                                                        child: Container(
                                                          width: 150,
                                                          child: Text(
                                                            'Select Title',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .grey, // You can set a different color to indicate it's disabled
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        onTap:
                                                            null, // Set onTap to null to make it not clickable
                                                      ),
                                                      ...Set<String>.from(
                                                              fetchalldata.map(
                                                                  (data) => data[
                                                                      'titl']))
                                                          .where((value) =>
                                                              value.isNotEmpty)
                                                          .map((value) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      250, // Set the maximum width you prefer
                                                                  child: Text(
                                                                    value,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight: droptitle ==
                                                                              value
                                                                          ? FontWeight
                                                                              .bold
                                                                          : FontWeight
                                                                              .normal,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ))
                                                          .toList(),
                                                    ],
                                                    underline: Container(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Image(
                                                      image: AssetImage(
                                                          'assets/images/logo_gm3.png'),
                                                      width: 100,
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            color: Colors.white,
                                                            height: 50,
                                                            child: Center(
                                                              child: Text(
                                                                droptitle ==
                                                                        'All'
                                                                    ? 'check List'
                                                                    : '$droptitle',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border: Border
                                                                          .all()),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .white,
                                                                      height:
                                                                          50,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                15.0,
                                                                            left:
                                                                                15),
                                                                        child:
                                                                            Text(
                                                                          'CLIENT NAME :  ' +
                                                                              user_id.toUpperCase(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // Container(
                                                            //   decoration:
                                                            //       BoxDecoration(
                                                            //           border: Border
                                                            //               .all()),
                                                            //   child: Row(
                                                            //     children: [
                                                            //       Expanded(
                                                            //         child: Container(
                                                            //           color: Colors
                                                            //               .white,
                                                            //           height: 50,
                                                            //           child: Padding(
                                                            //             padding: const EdgeInsets
                                                            //                 .only(
                                                            //                 top: 15.0,
                                                            //                 left: 15),
                                                            //             child: Text(
                                                            //               'STARTING DATE :',
                                                            //             ),
                                                            //           ),
                                                            //         ),
                                                            //       ),
                                                            //       Expanded(
                                                            //         child: Container(
                                                            //           color: Colors
                                                            //               .white,
                                                            //           height: 50,
                                                            //           child: Padding(
                                                            //             padding: const EdgeInsets
                                                            //                 .only(
                                                            //                 top: 15.0,
                                                            //                 left: 15),
                                                            //             child: Text(
                                                            //               'COMPLIEION DATE :',
                                                            //             ),
                                                            //           ),
                                                            //         ),
                                                            //       ),
                                                            //     ],
                                                            //   ),
                                                            // ),
                                                            SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: DataTable(
                                                                        headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                                                          // For the default or other states
                                                                          return Colors
                                                                              .white; // Set your desired color
                                                                        }),
                                                                        headingTextStyle: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold, // Set your desired font weight
                                                                          color:
                                                                              Colors.black, // Set your desired text color
                                                                        ),
                                                                        columnSpacing: 15, // Adjust the spacing between columns as needed
                                                                        dataRowHeight: 50,
                                                                        border: TableBorder.all(),
                                                                        columns: <DataColumn>[
                                                                          DataColumn(
                                                                            label:
                                                                                Text('SL.NO.', style: TextStyle(fontSize: 16)),
                                                                          ),
                                                                          DataColumn(
                                                                            label:
                                                                                Text('DESCRIPTION', style: TextStyle(fontSize: 16)),
                                                                          ),
                                                                          DataColumn(
                                                                            label:
                                                                                Text('YES', style: TextStyle(fontSize: 16)),
                                                                          ),
                                                                          DataColumn(
                                                                            label:
                                                                                Text('NO', style: TextStyle(fontSize: 16)),
                                                                          ),
                                                                          DataColumn(
                                                                            label:
                                                                                Text('NA', style: TextStyle(fontSize: 16)),
                                                                          ),
                                                                        ],
                                                                        rows: [
                                                                          // DataRow(
                                                                          //   cells: [
                                                                          //     DataCell(
                                                                          //       Container(
                                                                          //         width:
                                                                          //             double.infinity,
                                                                          //         child:
                                                                          //             Text(
                                                                          //           '',
                                                                          //           style: TextStyle(fontSize: 18),
                                                                          //         ),
                                                                          //       ),
                                                                          //     ),
                                                                          //     DataCell(
                                                                          //       Container(
                                                                          //         width:
                                                                          //             double.infinity,
                                                                          //         child:
                                                                          //             Text(
                                                                          //           'Pre-Construction',
                                                                          //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                          //         ),
                                                                          //       ),
                                                                          //     ),
                                                                          //     DataCell(
                                                                          //       Container(
                                                                          //         width:
                                                                          //             double.infinity,
                                                                          //         child:
                                                                          //             Text(
                                                                          //           '',
                                                                          //           style: TextStyle(fontSize: 18),
                                                                          //         ),
                                                                          //       ),
                                                                          //     ),
                                                                          //     DataCell(
                                                                          //       Container(
                                                                          //         width:
                                                                          //             double.infinity,
                                                                          //         child:
                                                                          //             Text(
                                                                          //           '',
                                                                          //           style: TextStyle(fontSize: 18),
                                                                          //         ),
                                                                          //       ),
                                                                          //     ),
                                                                          //     DataCell(
                                                                          //       Container(
                                                                          //         width:
                                                                          //             double.infinity,
                                                                          //         child:
                                                                          //             Text(
                                                                          //           '',
                                                                          //           style: TextStyle(fontSize: 18),
                                                                          //         ),
                                                                          //       ),
                                                                          //     ),
                                                                          //   ],
                                                                          // ),
                                                                          ...fetchalldata
                                                                              .where((data) => droptitle == 'All' || data['titl'] == droptitle)
                                                                              .toList()
                                                                              .asMap()
                                                                              .entries
                                                                              .map<DataRow>((entry) {
                                                                            int index =
                                                                                entry.key;
                                                                            dynamic
                                                                                data =
                                                                                entry.value;
                                                                            int currentSerialNumber =
                                                                                index + 1;
                                                                            Color rowColor = index.isEven
                                                                                ? Color.fromARGB(35, 255, 252, 252)
                                                                                : Colors.white;
                                                                            return DataRow(
                                                                              color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                                                                return rowColor; // Set the row color
                                                                              }),
                                                                              cells: [
                                                                                DataCell(Text(currentSerialNumber.toString(), style: TextStyle(fontSize: 18))),
                                                                                // DataCell(Text(
                                                                                //     data['st_dt']
                                                                                //         .toString(),
                                                                                //     style: TextStyle(
                                                                                //         fontSize:
                                                                                //             18))),
                                                                                // DataCell(Text(
                                                                                //     data['ed_dt']
                                                                                //         .toString(),
                                                                                //     style: TextStyle(
                                                                                //         fontSize:
                                                                                //             18))),
                                                                                DataCell(Container(
                                                                                  width: 130,
                                                                                  child: Text(data['content'].toString(), style: TextStyle(fontSize: 18)),
                                                                                )),
                                                                                DataCell(Text(data['sts'] == 'yes' ? data['sts'].toString() : '', style: TextStyle(fontSize: 18))),
                                                                                DataCell(Text(data['sts'] == 'no' ? data['sts'].toString() : '', style: TextStyle(fontSize: 18))),
                                                                                DataCell(Text('', style: TextStyle(fontSize: 18))),
                                                                              ],
                                                                            );
                                                                          }).toList(),
                                                                        ]),
                                                                  ),
                                                                  fetchalldata
                                                                          .isNotEmpty
                                                                      ? Container()
                                                                      : Container(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              Text('No data found'),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            border:
                                                                                Border.all()),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Colors.white,
                                                                            height:
                                                                                120,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Remarks :',
                                                                                    style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                                                                                  ),
                                                                                  Center(
                                                                                    child: Text(
                                                                                      fetchrmrkdata['chk_rmk'] != null && fetchrmrkdata['chk_rmk'].isNotEmpty ? fetchrmrkdata['chk_rmk'].toString() : '',
                                                                                      style: TextStyle(fontSize: 15),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    fetchalldata.isNotEmpty
                                                        ? InkWell(
                                                            onTap: () async {
                                                              downloadSHDCheckPDF(
                                                                  fetchalldata,
                                                                  droptitle);
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              width: 200,
                                                              child: Card(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        62,
                                                                        112),
                                                                elevation: 10,
                                                                shadowColor:
                                                                    Colors
                                                                        .black,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                ),
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Download',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          letterSpacing:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()))

        // Handle the case when fetchalldata is empty
        : Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(), // or any other placeholder or message
            ),
          );
  }

  Widget getFileWidget() {
    String agreement = '';
    if (title == 'Payment Details') {
      agreement = fetchalldata[0]['pay_dls'];
    } else if (title == 'Shedule') {
      agreement = fetchalldata[0]['shedule'];
    } else if (title == 'Check List') {
      agreement = fetchalldata[0]['check_dls'];
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

  Future<void> downloadSHDCheckPDF(List fetchalldata, String droptitle) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'GREEN MARVEL',
                        style: pw.TextStyle(
                          fontSize: 25,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF005296),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'BUILDERS & DEVELOPERS pvt LTD',
                        style: pw.TextStyle(fontSize: 15),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'Info@greenmarvrlbuilders.com',
                        style: pw.TextStyle(
                          fontSize: 15,
                          color: PdfColor.fromInt(0xFF0000FF),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      color: PdfColor.fromHex('#ffffff'),
                      height: 50,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        droptitle == 'All' ? 'check List' : '$droptitle',
                        style: pw.TextStyle(
                          fontSize: 23,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(),
                child: pw.Column(
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              color: PdfColor.fromHex('#ffffff'),
                              height: 50,
                              alignment: pw.Alignment.topLeft,
                              padding: pw.EdgeInsets.only(
                                top: 15,
                              ),
                              child: pw.Text(
                                'CLIENT NAME : ' + user_id.toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // pw.Container(
                    //   child: pw.Row(
                    //     children: [
                    //       pw.Expanded(
                    //         child: pw.Container(
                    //           color: PdfColor.fromHex('#ffffff'),
                    //           height: 50,
                    //           alignment: pw.Alignment.topLeft,
                    //           padding: pw.EdgeInsets.only(top: 15,),
                    //           child: pw.Text('STARTING DATE :'),
                    //         ),
                    //       ),
                    //       pw.Expanded(
                    //         child: pw.Container(
                    //           color: PdfColor.fromHex('#ffffff'),
                    //           height: 50,
                    //           alignment: pw.Alignment.topLeft,
                    //           padding: pw.EdgeInsets.only(top: 15,),
                    //           child: pw.Text('COMPLETION DATE :'),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      decoration: pw.BoxDecoration(),
                      child: pw.Column(
                        children: [
                          pw.Table(
                            border: pw.TableBorder.all(
                              width: 0.5,
                              color: PdfColors.black,
                            ),
                            columnWidths: {
                              0: pw.FlexColumnWidth(1),
                              1: pw.FlexColumnWidth(3),
                              2: pw.FlexColumnWidth(1),
                              3: pw.FlexColumnWidth(1),
                              4: pw.FlexColumnWidth(1),
                            },
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Text('SL.NO.',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('DESCRIPTION',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('YES',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('NO',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('NA',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                ],
                              ),
                              ...fetchalldata
                                  .where((data) =>
                                      droptitle == 'All' ||
                                      data['titl'] == droptitle)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map<pw.TableRow>(
                                (entry) {
                                  int index = entry.key;
                                  dynamic data = entry.value;
                                  int currentSerialNumber = index + 1;

                                  return pw.TableRow(
                                    children: [
                                      pw.Text(currentSerialNumber.toString(),
                                          style: pw.TextStyle(fontSize: 18),
                                          textAlign: pw.TextAlign.center),
                                      pw.Text(
                                        data['content'].toString(),
                                        style: pw.TextStyle(fontSize: 18),
                                      ),
                                      pw.Text(
                                          data['sts'] == 'yes'
                                              ? data['sts'].toString()
                                              : '',
                                          style: pw.TextStyle(fontSize: 18),
                                          textAlign: pw.TextAlign.center),
                                      pw.Text(
                                          data['sts'] == 'no'
                                              ? data['sts'].toString()
                                              : '',
                                          style: pw.TextStyle(fontSize: 18),
                                          textAlign: pw.TextAlign.center),
                                      pw.Text('',
                                          style: pw.TextStyle(fontSize: 18),
                                          textAlign: pw.TextAlign.center),
                                    ],
                                  );
                                },
                              ).toList(),
                            ],
                          ),
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                //   border: pw.BoxBorder(
                                //   color: PdfColors.black,  // Set the color of the border
                                //   width: 1.0,             // Set the width of the border
                                // ),
                                ),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Container(
                                    color: PdfColor.fromHex('#ffffff'),
                                    height: 120,
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.only(top: 15),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Remarks :',
                                          style: pw.TextStyle(fontSize: 18),
                                        ),
                                        pw.Padding(
                                          padding: pw.EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: pw.Text(
                                            fetchrmrkdata['chk_rmk'] != null &&
                                                    fetchrmrkdata['chk_rmk']
                                                        .isNotEmpty
                                                ? fetchrmrkdata['chk_rmk']
                                                    .toString()
                                                : '',
                                            style: pw.TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 50),
                          if (fetchalldata.isEmpty)
                            pw.Text(
                              'No data found',
                              style: pw.TextStyle(fontSize: 18),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    int randomNumber11 = Random().nextInt(10000);
    final List<int> bytes = await pdf.save();
    final ByteData data =
        ByteData.sublistView(Uint8List.fromList(bytes).buffer.asByteData());

    // Write to file
    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/$randomNumber11 report.pdf';
    await File(path).writeAsBytes(data.buffer.asUint8List());
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    // Open the PDF file
    OpenFile.open(path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to $path'),
        backgroundColor: Colors.green,
      ),
    );
  }

//  Future<void> downloadSHDCheckPDF() async {
//     final pdf = pw.Document();

//     pdf.addPage(pw.Page(
//       build: (pw.Context context) => pw.Table(
//         defaultColumnWidth: pw.FlexColumnWidth(),
//         border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
//         children: [
//           pw.TableRow(
//             children: [
//               pw.Text('S.No',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//               pw.Text('Start Date',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//               pw.Text('Finish Date',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//               pw.Text('Content',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//               pw.Text('Status',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//               pw.Text('Time',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 18)),
//             ],
//           ),
//           for (var data in fetchalldata)
//             pw.TableRow(
//               //alignment: pw.Alignment.center,
//               children: [
//                 pw.Text((fetchalldata.indexOf(data) + 1).toString()),
//                 pw.Text(data['st_dt'].toString(),
//                     style: pw.TextStyle(fontSize: 16)),
//                 pw.Text(data['ed_dt'].toString(),
//                     style: pw.TextStyle(fontSize: 16)),
//                 pw.Text(data['content'].toString(),
//                     style: pw.TextStyle(fontSize: 16)),
//                 pw.Text(data['sts'].toString(),
//                     style: pw.TextStyle(fontSize: 16)),
//                 pw.Text(
//                     DateFormat('dd-MM-yyyy   HH:mm:ss')
//                         .format(DateTime.parse(data['time'].toString())),
//                     style: pw.TextStyle(fontSize: 16)),
//               ],
//             ),
//         ],
//       ),
//     ));

//     int randomNumber11 = Random().nextInt(10000);
//     final String dir = (await getExternalStorageDirectory())!.path;
//     final String path = '$dir/$randomNumber11 report.pdf';
//     final file = File(path);
//     await file.writeAsBytes(await pdf.save());
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('PDF saved to $path'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

  Future<void> downloadSHDCheckPDF2(List fetchalldata, String droptitle) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'GREEN MARVEL',
                        style: pw.TextStyle(
                          fontSize: 25,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF005296),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'BUILDERS & DEVELOPERS pvt LTD',
                        style: pw.TextStyle(fontSize: 15),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'Info@greenmarvrlbuilders.com',
                        style: pw.TextStyle(
                          fontSize: 15,
                          color: PdfColor.fromInt(0xFF0000FF),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      color: PdfColor.fromHex('#ffffff'),
                      height: 50,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                       fetchrmrkdata['shed_titl'].isNotEmpty
                                                            ?fetchrmrkdata['shed_titl']
                                                            :'Shedule',
                        style: pw.TextStyle(
                          fontSize: 23,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(),
                child: pw.Column(
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              color: PdfColor.fromHex('#ffffff'),
                              height: 50,
                              alignment: pw.Alignment.topLeft,
                              padding: pw.EdgeInsets.only(top: 15),
                              child: pw.Text(
                                'CLIENT NAME : ' + user_id.toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // pw.Container(
                    //   child: pw.Row(
                    //     children: [
                    //       pw.Expanded(
                    //         child: pw.Container(
                    //           color: PdfColor.fromHex('#ffffff'),
                    //           height: 50,
                    //           alignment: pw.Alignment.topLeft,
                    //           padding: pw.EdgeInsets.only(top: 15),
                    //           child: pw.Text('STARTING DATE :'),
                    //         ),
                    //       ),
                    //       pw.Expanded(
                    //         child: pw.Container(
                    //           color: PdfColor.fromHex('#ffffff'),
                    //           height: 50,
                    //           alignment: pw.Alignment.topLeft,
                    //           padding: pw.EdgeInsets.only(top: 15),
                    //           child: pw.Text('COMPLETION DATE :'),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      decoration: pw.BoxDecoration(),
                      child: pw.Column(
                        children: [
                          pw.Table(
                            border: pw.TableBorder.all(
                              width: 0.5,
                              color: PdfColors.black,
                            ),
                            columnWidths: {
                              0: pw.FlexColumnWidth(1),
                              1: pw.FlexColumnWidth(3),
                              2: pw.FlexColumnWidth(1),
                              3: pw.FlexColumnWidth(1),
                              4: pw.FlexColumnWidth(1),
                            },
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Text('SL.NO.',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('DESCRIPTION',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('PRECENTAGE',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('Start Date',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  pw.Text('Finish Date',
                                      style: pw.TextStyle(fontSize: 16),
                                      textAlign: pw.TextAlign.center),
                                  // pw.Text('NA',
                                  //     style: pw.TextStyle(fontSize: 16),
                                  //     textAlign: pw.TextAlign.center),
                                ],
                              ),
                              // pw.TableRow(
                              //   children: [
                              //     pw.Container(width: double.infinity),
                              //     pw.Container(width: double.infinity),
                              //     pw.Container(width: double.infinity),
                              //     pw.Container(width: double.infinity),
                              //     pw.Container(width: double.infinity),
                              //   ],
                              // ),
                              ... fetchalldata
                                    .asMap()
                                    .entries
                                  .map<pw.TableRow>(
                                (entry) {
                                  int index = entry.key;
                                  dynamic data = entry.value;
                                  int currentSerialNumber = index + 1;

                                  return pw.TableRow(
                                    children: [
                                      pw.Text(currentSerialNumber.toString(),
                                          style: pw.TextStyle(fontSize: 18),
                                          textAlign: pw.TextAlign.center),
                                      pw.Text(
                                        data['content'].toString(),
                                        style: pw.TextStyle(fontSize: 18),
                                      ),
                                       pw.Text(
                                        data['presentage'].toString(),
                                        style: pw.TextStyle(fontSize: 18),
                                      ),
                                      pw.Text(
                                          DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(data['st_dt'])),
                                          style: pw.TextStyle(fontSize: 16),
                                          textAlign: pw.TextAlign.center),
                                      pw.Text(
                                          DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(data['ed_dt'])),
                                          style: pw.TextStyle(fontSize: 16),
                                          textAlign: pw.TextAlign.center),
                                      // pw.Text('',
                                      //     style: pw.TextStyle(fontSize: 18),
                                      //     textAlign: pw.TextAlign.center),
                                    ],
                                  );
                                },
                              ).toList(),
                            ],
                          ),
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                //   border: pw.BoxBorder(
                                //   color: PdfColors.black,  // Set the color of the border
                                //   width: 1.0,             // Set the width of the border
                                // ),
                                ),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Container(
                                    color: PdfColor.fromHex('#ffffff'),
                                    height: 120,
                                    alignment: pw.Alignment.topLeft,
                                    padding: pw.EdgeInsets.only(top: 15),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Remarks :',
                                          style: pw.TextStyle(fontSize: 18),
                                        ),
                                        pw.Padding(
                                          padding: pw.EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: pw.Text(
                                            fetchrmrkdata['shed_rmk'] != null &&
                                                    fetchrmrkdata['shed_rmk']
                                                        .isNotEmpty
                                                ? fetchrmrkdata['shed_rmk']
                                                    .toString()
                                                : '',
                                            style: pw.TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 50),
                          if (fetchalldata.isEmpty)
                            pw.Text(
                              'No data found',
                              style: pw.TextStyle(fontSize: 18),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    int randomNumber11 = Random().nextInt(10000);
    final List<int> bytes = await pdf.save();
    final ByteData data =
        ByteData.sublistView(Uint8List.fromList(bytes).buffer.asByteData());

    // Write to file
    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/$randomNumber11 report.pdf';
    await File(path).writeAsBytes(data.buffer.asUint8List());
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    // Open the PDF file
    OpenFile.open(path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to $path'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
