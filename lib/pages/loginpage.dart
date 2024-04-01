import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

//import '../forgot_password/forgotpsd.dart';
import '../forgot_password/forgotpsd.dart';
import 'bottom_navigate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  var backendIP = ApiConstants.backendIP;
  String userId = '';
  String password = '';

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = true;
        demofetch();
        _selectedOption = '';
      });
    });
  }

  String demo = '';
  void demofetch() async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/demo.php?action=demo'); // Append query parameters directly to the URL for GET requests
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          List demolist = json.decode(response.body);
          demo = demolist[0]['ad_nm'];
          print(demo);
        });
      }
    } catch (e) {
      print('error $e');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Sign-in successful
        print('Signed in as: ${googleUser.email}');
        // Access user information: googleUser.displayName, googleUser.photoUrl, etc.
      } else {
        // User canceled the sign-in
        print('Sign-in canceled');
        // Handle cancellation accordingly (show message, etc.)
      }
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') {
        // Handle sign-in cancellation specifically
        print('Sign-in canceled: ${e.toString()}');
        // Provide feedback to the user indicating cancellation
        // Show a snackbar, toast, or display a message
      } else {
        // Handle other PlatformExceptions or log the error
        print('Error signing in: ${e.toString()}');
        // Provide feedback to the user indicating an error occurred
        // Show a snackbar, toast, or display a message
      }
    } catch (error) {
      // Handle other generic errors, if any
      print('Error signing in: $error');
      // Provide feedback to the user indicating an error occurred
      // Show a snackbar, toast, or display a message
    }
  }

  Future<void> _handleFacebookSignUp() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      // Handle successful sign-up here
      // Access token: result.accessToken
      // User ID: result.userId
      print('Logged in with Facebook! Token: ${result.accessToken}');
    } catch (e) {
      // Handle error during sign-up
      print('Error signing up with Facebook: $e');
    }
  }

  void login() async {
    // Get the current time
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString();
    String day = now.day.toString();
    String hour = now.hour.toString();
    String minute = now.minute.toString();
    String second = now.second.toString();
    String time_date = '$year-$month-$day $hour:$minute:$second';

    print(userId);
    print(password);
    print(_selectedOption);

    try {
      var url = "$backendIP/admin_login.php";
      var response = await http.post(Uri.parse(url), body: {
        "user_id": userId,
        "password": password,
        "whoIs": _selectedOption,
        "timeDate": time_date,
      });

      var data = jsonDecode(response.body);

      if (data == "successfully logged") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 209, 101, 0),
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Login Successfully',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home_Navigator()));
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('whoIs', _selectedOption);
        sharedPreferences.setString('user_id', userId);
      } else {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Container(
              height: 30,
              child: Center(
                child: Text('Invalid UserID Password',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('An error occurred. Please check your network connection.',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
        ),
      );
    }
  }

  late String _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg2.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                ),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height:MediaQuery.of(context).size.height / 3+10,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/img6.jpg'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      Image(
                        image: AssetImage('assets/images/logo_gm3.png'),
                        height: 110,
                      ),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
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
                                      return 'Please enter your Id';
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
                                    labelText: "User Id",
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
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      child: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedOption = 'ADMIN';
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: _selectedOption == 'ADMIN'
                                              ? Colors
                                                  .white // Change color if selected
                                              : Colors
                                                  .transparent, // Keep transparent otherwise
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text(
                                        'ADMIN',
                                      )),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedOption = 'STAFF';
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: _selectedOption == 'STAFF'
                                              ? Colors
                                                  .white // Change color if selected
                                              : Colors
                                                  .transparent, // Keep transparent otherwise
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text(
                                        'STAFF',
                                      )),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedOption = 'CLIENT';
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: _selectedOption == 'CLIENT'
                                            ? Colors
                                                .white // Change color if selected
                                            : Colors
                                                .transparent, // Keep transparent otherwise
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                          child: Text(
                                        'CLIENT',
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    // userlogin();

                                    if (_selectedOption.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Color.fromARGB(255, 209, 101, 0),
                                          content: Center(
                                              child: Text(
                                                  'Please Select Anyone of ADMIN, STAFF, CLIENT')),
                                        ),
                                      );
                                    } else {
                                      login();
                                      //logindemo();
                                    }
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign in',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPassword()));
                                    },
                                    child: Text(
                                      'Forgot Password ?',
                                      style: TextStyle(fontSize: 17,),
                                    ),
                                  ),
                                ],
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
          : Center(
              child: RotationTransition(
                turns: _controller,
                child: Image.asset(
                  'assets/images/logo_gm3.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
    );
  }
}
