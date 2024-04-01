import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class Add_User extends StatefulWidget {
  const Add_User({super.key});

  @override
  State<Add_User> createState() => _Add_UserState();
}

class _Add_UserState extends State<Add_User> {
  var backendIP = ApiConstants.backendIP;
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
        'action': 'CLIENT',
        'name': userName,
        'phNum': phNum,
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
          Navigator.pop(context);
          print('Registration successful');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color.fromARGB(255, 209, 101, 0),
              content: Container(
                height: 30,
                child: Center(
                  child: Text(
                    'Registration successful',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                  ),
                ),
              ),
            ),
          );
        }
      } else {
        print('Error occurred during registration: ${response.body}');
        SnackBar(
          backgroundColor: Colors.red,
          content: Container(
            height: 30,
            child: Center(
              child: Text(
                'Failed Registration',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('insert error $e');
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
                        image: AssetImage('assets/images/bg10.jpg'),
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
                              image: DecorationImage(
                                  image: AssetImage('assets/images/bg1.jpg'),
                                  fit: BoxFit.cover)),
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                            'Add User',
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
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/bg2.jpg'),
                        fit: BoxFit.cover)),
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
                                  return 'Please enter Name';
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
            ],
          ),
        ),
      ),
    );
  }
}
