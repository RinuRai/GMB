import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../pages/loginpage.dart';

class Change_Password extends StatefulWidget {
  @override
  State<Change_Password> createState() => _Change_PasswordState();
}

class _Change_PasswordState extends State<Change_Password> {
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
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }





  String oldpass = '';
  String otp = '';
  String newpass = '';
  String cnfmpass = '';

  final _changegpasskey = GlobalKey<FormState>();
  String generatedOTP = '';

  bool showpsdField = false;
  bool otpsection = false;

  Future<void> changePassword(cnfps, old) async {
    try {
      print(cnfps);
      print(old);
      print(user_id);
      print(whoIs);
      var apiUrl = Uri.parse('$backendIP/Forgot_password.php');

      var response = await http.post(apiUrl, body: {
        'action': 'Change-PASS-AD',
        'newpass': cnfps,
        'oldpass': old,
        'userid': user_id,
        'who': whoIs,
      });

      if (response.statusCode == 200) {
        print(response.body);
        if (response.body == '"Password Changed"') {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
            content: Center(child: Text("Password updated successfully",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
          ),
        );
      } else {
          // Password update failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Center(child: Text("Please Confirm Your Old Password",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
            ),
          );
        }
      } else {
        // Handle non-200 response status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(child: Text("Error updating password",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)),
          ),
        );
      }
    } catch (e) {
      // Handle fetch error
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error updating password",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
           key: _changegpasskey,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/img4.jpg'),
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
                        'Change Password',
                        style:
                            TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                      ),
                    ),
                  Column(
                      children: [
                        SizedBox(height: 20.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                oldpass = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter old password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Enter old Password',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.text,
                            // Handle user input for phone number
                          ),
                        ),
                        SizedBox(height: 20.0),
                      
                      ],
                    ),
          
                    
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
                           return 'Please enter New password';
                         } else if (value.length < 6) {
                           return 'Password must be at least 6 characters';
                         }
                         return null;
                       },
                       decoration: InputDecoration(
                         labelText: 'Enter New password',
                         border: InputBorder.none,
                       ),
                       keyboardType: TextInputType.text,
                       // Handle user input for phone number
                     ),
                   ),
                   SizedBox(height: 10.0),
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
                           return 'Confirm New password';
                         } else if (value.length < 6) {
                           return 'Password must be at least 6 characters';
                         }
                         return null;
                       },
                       decoration: InputDecoration(
                         labelText: 'Confirm New Password',
                         border: InputBorder.none,
                       ),
                       keyboardType: TextInputType.text,
                       // Handle user input for OTP
                     ),
                   ),
                   SizedBox(height: 30.0),
                                    
                   Container(
                    width: 150,
                    height: 50,
                     child: ElevatedButton(
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
                             changePassword(cnfmpass, oldpass);
                           } else {
                             ScaffoldMessenger.of(context)
                                 .showSnackBar(
                               SnackBar(
                                 backgroundColor:
                                     Color.fromARGB(255, 207, 15, 1),
                                 content: Container(
                                  
                                   child: Center(
                                     child: Text(
                                       'Password Not Matched, Please Confirm Your New Password',
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
                       child: Center(
                         child: Text(
                           'Submit',
                           style: TextStyle(
                               color: Colors.white, fontSize: 18),
                         ),
                       ),
                     ),
                   ),
                   SizedBox(height: 20,)
                        
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// 236541