import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../forgot_password/FullViewIMG.dart';

class Add_Staff extends StatefulWidget {
  const Add_Staff({super.key});

  @override
  State<Add_Staff> createState() => _Add_StaffState();
}

class _Add_StaffState extends State<Add_Staff> {
  var backendIP = ApiConstants.backendIP;

  @override
  void initState() {
    super.initState();
    getSTFdata();
  }

  List fetchstfdata = [];

  Future<void> getSTFdata() async {
    try {
      var apiUrl = Uri.parse('$backendIP/STAFF-dtls.php');
      var response = await http
          .post(apiUrl, body: {'action': 'STAFF-LIST', 'whois': "STAFF"});
      if (response.statusCode == 200) {
        setState(() {
          fetchstfdata = json.decode(response.body);
          print(fetchstfdata);
        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  String userName = '';
  String phNum = '';
  String address = 'Null';
  String userId = '';
  String password = '';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _phNum = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  void Adduser() async {
    try {
      //  setState(() {
      //   _autoValidate = true; // Enable auto-validation when the Register button is clicked
      // });
      DateTime now = DateTime.now();

      // Create a DateFormat object for formatting

      // Extract date and time components
      String year = now.year.toString();
      String month = now.month.toString();
      String day = now.day.toString();
      String hour = now.hour.toString();
      String minute = now.minute.toString();
      String second = now.second.toString();
      String date = '$year-$month-$day';
      String time = '$hour:$minute:$second';
      print(userName);
      print(phNum);
      print(address);
      print(userId);
      print(password);
      print(time);
      print(date);

      var apiUrl = Uri.parse(
          '$backendIP/Add_user.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'STAFF',
        'name': userName,
        'phNum': phNum.toString(),
        'address': address,
        'userId': userId,
        'password': password,
        'reg_date': date,
        'reg_time': time,
      });

      if (response.statusCode == 200) {
        // ignore: unused_local_variable
        var data = jsonDecode(response.body);
        print(data);

        if (data == "This UserID is Already Registered") {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Container(
                height: 30,
                child: Center(
                  child: Text(
                    data,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
              ),
            ),
          );

          setState(() {});
        } else {
          print('Registration successful');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color.fromARGB(255, 209, 101, 0),
              content: Container(
                height: 30,
                child: Center(
                  child: Text(
                    'Registration successful',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
              ),
            ),
          );
        }
        setState(() {
          getSTFdata();
          _userName.clear();
          _phNum.clear();
          _address.clear();
          _userId.clear();
          _pass.clear();
        });
      } else {
        print('Error occurred during registration: ${response.body}');
        SnackBar(
          backgroundColor: Colors.red,
          content: Container(
            height: 30,
            child: Center(
              child: Text(
                'Failed Registration',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('insert error $e');
    }
  }

////////////////////////////////////////////////////////////
  int editingIndex = -1;
  final TextEditingController _Name = TextEditingController();
  final TextEditingController _psd = TextEditingController();
  final TextEditingController _nwphn = TextEditingController();
  String uptnm = '';
  String uptphn = '';

  void updt_Staff(uid, id, name, psd, num) async {
    print(uid);
    print(id);
    print(name);
    print(psd);
    print(num);

    try {
      var apiUrl = Uri.parse(
          '$backendIP/update_profile.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Update-Stf-profile',
        'usId': uid.toString(),
        'id': id.toString(),
        'newusid': name.toString(),
        'newpass': psd.toString(),
        'num': num.toString(),
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
                  'Update Changed',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
                ),
              ),
            ),
          ),
        );
        setState(() {
          editingIndex = -1;
          getSTFdata();
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
      }
    } catch (e) {
      print('Change error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg8.jpg'),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(50),
                                topLeft: Radius.circular(50),
                              ),
                              // image: DecorationImage(
                              //     image: AssetImage('assets/images/bg1.jpg'),
                              //     fit: BoxFit.cover)
                              color: Color.fromARGB(255, 228, 226, 226)),
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                            'Add Staff',
                            style: TextStyle(
                              color: Color.fromARGB(255, 209, 101, 0),
                              fontFamily:
                                  'Satisfy', // Use the font family defined in pubspec.yaml
                              fontSize: 25,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 4.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          )))),
                  Positioned(
                      bottom: 200,
                      left: MediaQuery.of(context).size.width - 60,
                      child: popupicon()),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    // image: DecorationImage(
                    //     image: AssetImage('assets/images/bg8.jpg'),
                    //     fit: BoxFit.cover)
                    color: Color.fromARGB(255, 228, 226, 226)),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: _userName,
                              onChanged: (value) {
                                setState(() {
                                  userName = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter staff Name';
                                }
                                return null;
                              },
                              // keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                labelText: "Name",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: _phNum,
                              onChanged: (value) {
                                setState(() {
                                  phNum = value;
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                labelText: "Phone Number",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: _address,
                              onChanged: (value) {
                                setState(() {
                                  address = value;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                labelText: "Address",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: _userId,
                              onChanged: (value) {
                                setState(() {
                                  userId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter User ID';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                labelText: "User ID",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            child: TextFormField(
                              controller: _pass,
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              obscureText: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                labelText: "Password",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0,
                          ),
                          InkWell(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Adduser();
                              }
                            },
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              child: Card(
                                color: Color.fromARGB(255, 209, 101, 0),
                                elevation: 10,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          // For the default or other states
                          return Color.fromARGB(
                              255, 31, 70, 85); // Set your desired color
                        }),
                        headingTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold, // Set your desired font weight
                          color: Colors.white, // Set your desired text color
                        ),
                        columnSpacing:
                            40, // Adjust the spacing between columns as needed
                        dataRowHeight: 80,
                        columns: <DataColumn>[
                          DataColumn(
                            label:
                                Text('SL.NO.', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Name',
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                          DataColumn(
                            label:
                                Text('profile', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Staff Id',
                                style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Password',
                                style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Phn', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('#', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('#', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Edit', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label:
                                Text('Delete', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                        rows:
                            fetchstfdata.asMap().entries.map<DataRow>((entry) {
                          int index = entry.key;
                          dynamic data = entry.value;
                          int currentSerialNumber = index + 1;
                          Color rowColor = index.isEven
                              ? Color.fromARGB(255, 236, 234, 234)
                              : Colors.white;
                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) {
                              return rowColor; // Set the row color
                            }),
                            cells: [
                              DataCell(Text(currentSerialNumber.toString(),
                                  style: TextStyle(fontSize: 18))),
                              DataCell(Text(data['name'].toString(),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold))),
                              DataCell(data['pic'] != null &&
                                      data['pic'].isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullPageImage(
                                              imageUrl:
                                                  '$backendIP/profile_pic/' +
                                                      data['pic'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              '$backendIP/profile_pic/' +
                                                  data['pic'].toString())),
                                    )
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          '$backendIP/profile_pic/emt.jpg'),
                                    )),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _Name,
                                            onChanged: (value) {
                                              setState(() {
                                                uptnm = value;
                                              });
                                            },
                                            // initialValue: data['name'].toString(),
                                            decoration: InputDecoration(
                                              labelText:
                                                  data['ad_nm'].toString(),
                                              border: InputBorder.none,
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['ad_nm'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _psd,
                                            decoration: InputDecoration(
                                              labelText:
                                                  data['ad_ps'].toString(),
                                              border: InputBorder.none,
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['ad_ps'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _nwphn,
                                            onChanged: (value) {
                                              setState(() {
                                                uptphn = value;
                                              });
                                            },
                                            // initialValue: data['name'].toString(),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: data['phn'].toString(),
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['phn'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(Text(data['who_is'].toString(),
                                  style: TextStyle(fontSize: 18))),
                              DataCell(TextButton(
                                  onPressed: () {
                                    staffprofile(
                                        context,
                                        data['name'].toString(),
                                        data['phn'].toString(),
                                        data['ad_nm'].toString(),
                                        data['pic'].toString(),
                                        data['ad_ps'].toString());
                                  },
                                  child: Text(
                                    'view',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  ))),
                              DataCell(
                                editingIndex == index
                                    ? ElevatedButton(
                                        onPressed: () {
                                          if (_Name.text.isNotEmpty &&
                                              _psd.text.isNotEmpty &&
                                              _nwphn.text.isNotEmpty) {
                                            setState(() {
                                              editingIndex = -1;
                                              updt_Staff(
                                                  data['ad_nm'].toString(),
                                                  data['id'].toString(),
                                                  _Name.text,
                                                  _psd.text,
                                                  _nwphn.text);
                                            });
                                          } else {
                                            ScaffoldMessenger.of(
                                                    context as BuildContext)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Container(
                                                  height: 40,
                                                  width: double.infinity,
                                                  color: Color.fromARGB(
                                                      255, 198, 0, 0),
                                                  child: Center(
                                                    child: Text(
                                                      'Enter New Values',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors
                                              .green, // Set the background color here
                                        ),
                                        child: Text('Submit',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _Name.text = data['ad_nm'];
                                            _psd.text = data['ad_ps'];
                                            _nwphn.text = data['phn'];
                                            editingIndex = index;
                                          });
                                        },
                                        icon: Icon(Icons.edit),
                                      ),
                              ),
                              DataCell(IconButton(
                                onPressed: () {
                                  logoutdialog(context, data['id'].toString(),
                                      data['ad_nm'].toString());
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                iconSize: 30,
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    fetchstfdata.isNotEmpty
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
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> popupicon() {
    return PopupMenuButton(
        color: Colors.white,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        stafflistdialog(context);
                      },
                      child: Container(
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Text(
                              'Staff List',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ))),
                ],
              ),
            ),
          ];
        },
        child: Container(
            child: Icon(
          Icons.menu,
          size: 30,
          color: Colors.white,
        )));
  }

  Future<dynamic> stafflistdialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          // For the default or other states
                          return Color.fromARGB(
                              255, 31, 70, 85); // Set your desired color
                        }),
                        headingTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold, // Set your desired font weight
                          color: Colors.white, // Set your desired text color
                        ),
                        columnSpacing:
                            40, // Adjust the spacing between columns as needed
                        dataRowHeight: 80,
                        columns: <DataColumn>[
                          DataColumn(
                            label:
                                Text('SL.NO.', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Name',
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                          DataColumn(
                            label:
                                Text('profile', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Staff Id',
                                style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Password',
                                style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Phn', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('#', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('#', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label: Text('Edit', style: TextStyle(fontSize: 16)),
                          ),
                          DataColumn(
                            label:
                                Text('Delete', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                        rows:
                            fetchstfdata.asMap().entries.map<DataRow>((entry) {
                          int index = entry.key;
                          dynamic data = entry.value;
                          int currentSerialNumber = index + 1;
                          Color rowColor = index.isEven
                              ? Color.fromARGB(255, 236, 234, 234)
                              : Colors.white;
                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) {
                              return rowColor; // Set the row color
                            }),
                            cells: [
                              DataCell(Text(currentSerialNumber.toString(),
                                  style: TextStyle(fontSize: 18))),
                              DataCell(Text(data['name'].toString(),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold))),
                              DataCell(data['pic'] != null &&
                                      data['pic'].isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullPageImage(
                                              imageUrl:
                                                  '$backendIP/profile_pic/' +
                                                      data['pic'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              '$backendIP/profile_pic/' +
                                                  data['pic'].toString())),
                                    )
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          '$backendIP/profile_pic/emt.jpg'),
                                    )),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _Name,
                                            onChanged: (value) {
                                              setState(() {
                                                uptnm = value;
                                              });
                                            },
                                            // initialValue: data['name'].toString(),
                                            decoration: InputDecoration(
                                              labelText:
                                                  data['ad_nm'].toString(),
                                              border: InputBorder.none,
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['ad_nm'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _psd,
                                            decoration: InputDecoration(
                                              labelText:
                                                  data['ad_ps'].toString(),
                                              border: InputBorder.none,
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['ad_ps'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(
                                editingIndex == index
                                    ? Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TextFormField(
                                            controller: _nwphn,
                                            onChanged: (value) {
                                              setState(() {
                                                uptphn = value;
                                              });
                                            },
                                            // initialValue: data['name'].toString(),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: data['phn'].toString(),
                                              // fillColor: Colors.grey[100],
                                              // filled: true
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(data['phn'].toString(),
                                        style: TextStyle(fontSize: 18)),
                              ),
                              DataCell(Text(data['who_is'].toString(),
                                  style: TextStyle(fontSize: 18))),
                              DataCell(TextButton(
                                  onPressed: () {
                                    staffprofile(
                                        context,
                                        data['name'].toString(),
                                        data['phn'].toString(),
                                        data['ad_nm'].toString(),
                                        data['pic'].toString(),
                                        data['ad_ps'].toString());
                                  },
                                  child: Text(
                                    'view',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  ))),
                              DataCell(
                                editingIndex == index
                                    ? ElevatedButton(
                                        onPressed: () {
                                          if (_Name.text.isNotEmpty &&
                                              _psd.text.isNotEmpty &&
                                              _nwphn.text.isNotEmpty) {
                                            setState(() {
                                              editingIndex = -1;
                                              updt_Staff(
                                                  data['ad_nm'].toString(),
                                                  data['id'].toString(),
                                                  _Name.text,
                                                  _psd.text,
                                                  _nwphn.text);
                                            });
                                          } else {
                                            ScaffoldMessenger.of(
                                                    context as BuildContext)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Container(
                                                  height: 40,
                                                  width: double.infinity,
                                                  color: Color.fromARGB(
                                                      255, 198, 0, 0),
                                                  child: Center(
                                                    child: Text(
                                                      'Enter New Values',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors
                                              .green, // Set the background color here
                                        ),
                                        child: Text('Submit',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _Name.text = data['ad_nm'];
                                            _psd.text = data['ad_ps'];
                                            _nwphn.text = data['phn'];
                                            editingIndex = index;
                                          });
                                        },
                                        icon: Icon(Icons.edit),
                                      ),
                              ),
                              DataCell(IconButton(
                                onPressed: () {
                                  logoutdialog(context, data['id'].toString(),
                                      data['ad_nm'].toString());
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                iconSize: 30,
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    fetchstfdata.isNotEmpty
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
              
            ),
          );
        });
  }

  Future<dynamic> logoutdialog(BuildContext context, id, uid) {
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
                          del_Acc(id, uid);
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

  void del_Acc(id, uid) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Delete_Accout.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'action': 'Dele-STAFF-ACC',
        'stfId': id,
        'stfuid': uid,
      });
      print(uid);
      if (response.statusCode == 200) {
        print(response.body);
        getSTFdata();
        // Navigate to LoginPage after logout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 209, 101, 0),
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Staff Account Deleted',style: TextStyle(
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

  Future<dynamic> staffprofile(BuildContext context, name, phn, uid, pic, psd) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
                height: 350,
                width: double.infinity,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: pic != null && pic.isNotEmpty
                          ? NetworkImage('$backendIP/profile_pic/' + pic)
                          : NetworkImage('$backendIP/profile_pic/emt.jpg'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: Text(uid,
                              style: TextStyle(
                                fontSize: 18,
                              )),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: Text(psd,
                              style: TextStyle(
                                fontSize: 18,
                              )),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Text(phn,
                        style: TextStyle(
                          fontSize: 18,
                        ))
                  ],
                )),
          );
        });
  }
}
