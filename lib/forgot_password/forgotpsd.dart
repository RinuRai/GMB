import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import '../config.dart';
import '../pages/loginpage.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var backendIP = ApiConstants.backendIP;

TextEditingController adminInitialemail = TextEditingController();
TextEditingController adminemail = TextEditingController();
TextEditingController otpcnlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    otpsection = true;
   adminInitialemail.text = 
   //'rinurai2001@gmail.com';
   'greenmarvelbuilders@gmail.com';
  }



  String email = '';
  String otp = '';
  String newpass = '';
  String cnfmpass = '';

  final _nmbrkey = GlobalKey<FormState>();
  final _otpkey = GlobalKey<FormState>();
  final _changegpasskey = GlobalKey<FormState>();
  String generatedOTP = '';

  bool showpsdField = false;
  bool otpsection = false;

  Future<void> changePassword(cnfps) async {
    print(cnfps);
    try {
      var apiUrl = Uri.parse('$backendIP/Forgot_password.php');

      var response = await http.post(apiUrl, body: {
        'action': 'Forgot-PASS-Ad',
        'pass': cnfps,
      });

      if (response.statusCode == 200) {
        print(response.body);
        if (response.body == '"Password Changed"') {
          // Password updated successfully
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
            content: Center(child: Text("Password updated successfully",style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),)),
          ),
        );
      } else {
          // Password update failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Center(child: Text("Error updating password")),
            ),
          );
        }
      } else {
        // Handle non-200 response status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(child: Text("Error updating password")),
          ),
        );
      }
    } catch (e) {
      // Handle fetch error
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error updating password"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
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
              ],
            ),
            Image(
              image: AssetImage('assets/images/logo_gm3.png'),
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Forgot Password ?',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                    ),
                  ),
                otpsection
                 ? Column(
                    children: [
                      SizedBox(height: 40.0),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _nmbrkey,
                          child: TextFormField(
                            controller: adminemail,
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                            decoration: InputDecoration(
                              hintText: 'Enter your Email',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            // Handle user input for phone number
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 209, 101, 0),
                          ),
                        ),
                        onPressed: () {
                          if (_nmbrkey.currentState!.validate()) {
                            if(adminInitialemail.text == adminemail.text){
                               sendOTP(
                                adminemail.text);
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Only Admin Can Change Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please Check your email",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
                            }
                          }
                        },
                        child: SizedBox(
                          height: 45,
                          child: Center(
                            child: Text(
                              'Send OTP',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _otpkey,
                          child: TextFormField(
                            controller: otpcnlr,
                            onChanged: (value) {
                              setState(() {
                                otp = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter otp';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your OTP',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.phone,
                            // Handle user input for OTP
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 209, 101, 0),
                          ),
                        ),
                        onPressed: () {
                          if (_otpkey.currentState!.validate()) {
                            verifyOTP(otpcnlr.text
                               ); // Replace with the user's phone number input
                          }
                          // Replace '1234' with the actual OTP entered by the user
                        },
                        child: SizedBox(
                          height: 45,
                          child: Center(
                            child: Text(
                              'Verify OTP',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  :Container(),

                  /////////////////////////////////////////////
                  
                  showpsdField
                      ? Form(
                          key: _changegpasskey,
                          child: Column(
                            children: [
                           
                              SizedBox(height: 40.0),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      newpass = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter New password',
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  // Handle user input for phone number
                                ),
                              ),
                              SizedBox(height: 30.0),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      cnfmpass = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirm your password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  // Handle user input for OTP
                                ),
                              ),
                              SizedBox(height: 30.0),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 209, 101, 0),
                                  ),
                                ),
                                onPressed: () {
                                  if (_changegpasskey.currentState!
                                      .validate()) {
                                    if (newpass == cnfmpass) {
                                      changePassword(cnfmpass);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Color.fromARGB(255, 209, 101, 0),
                                          content: Container(
                                            height: 30,
                                            child: Center(
                                              child: Text(
                                                'Password Not Matched',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: SizedBox(
                                  height: 45,
                                  child: Center(
                                    child: Text(
                                      'Change Password',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  
EmailOTP myauth = EmailOTP();
  void sendOTP(String eml) async {
      print(eml);
        myauth.setConfig(
          appEmail: "rinu@mindTek.com",
          appName: "GREEN MARVEL Builders & Developers PVT LTD-\nEmail Verification",
          userEmail: eml,
          otpLength: 6,
          otpType: OTPType.digitsOnly,
        );
        if (await myauth.sendOTP() == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "GREEN MARVEL BUILDING",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "OTP has been sent",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Check your email for the OTP.",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  } else {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(child: Text("Oops, OTP send failed")),
        ),
      );
    }
  }

  void verifyOTP(otp11) async {
      if (await myauth.verifyOTP(otp:otp11) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Center(child: Text("OTP is verified")),
          ),
        );
        setState(() {
          showpsdField = true;
          otpsection = false;
        });
        otpcnlr.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(child: Text("Invalid OTP")),
          ),
        );
        adminemail.clear();
        otpcnlr.clear();
     }
    
  }


}

// 236541