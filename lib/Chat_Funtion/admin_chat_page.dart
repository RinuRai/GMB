import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../pages/loginpage.dart';

class AdminChatingPage extends StatefulWidget {
 const AdminChatingPage({Key? key, required this.cli_id, required this.who}) : super(key: key);
  
 final String cli_id;
  final String who;
 
  @override
  State<AdminChatingPage> createState() => _AdminChatingPageState();
}

class _AdminChatingPageState extends State<AdminChatingPage> {
  var backendIP = ApiConstants.backendIP;
late Timer _timer;

 @override
  void initState() {
    super.initState();
   checkLoginStatus();
  }


  void _startTimer() {
  // Set up a Timer that calls the `_updateState` method every 5 seconds
  _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    // Call the method to update the state
    _updateState();
  });
}

void _updateState() {
  // Perform the setState to update the state
  setState(() {
    // Call your messagelist function here with desired arguments
    messagelist(widget.who,widget.cli_id);
  });
}

void dispose() {
  // Dispose the timer when the widget is disposed to avoid memory leaks
  _timer.cancel();
  super.dispose();
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
       if( whoIs=='ADMIN'){
          messagelist(widget.who,widget.cli_id);
         _startTimer();
       }else{
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




/////////////////////////////////////////////////////////////////////////////
  List climsglist = [];
  Future<void> messagelist(who,id) async {
    try {
      var apiUrl = Uri.parse('$backendIP/msg_snd_recv.php');
      var response =
          await http.post(apiUrl, body: {'action': 'cli-Message-List', 
          'who': who,
          'user_id': id});
      if (response.statusCode == 200) {
        setState(() {
          climsglist = json.decode(response.body);
          isloading = true;
          print(climsglist);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

List<String> messages = [];

TextEditingController messageController = TextEditingController();

void sendMessage(String message) async {
    try {
    // Get current date and time
    DateTime now = DateTime.now();

    // Format date and time with AM/PM indicator
    String dateTimeString = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      print(whoIs);
      print(user_id);
      print(message);
      print(dateTimeString);
     
      var apiUrl = Uri.parse('$backendIP/msg_snd_recv.php');
      var response = await http.post(apiUrl, body: {
        'action': 'SEND-MESSAGE-TO',
        'who': whoIs,
        'snd_id': user_id,
        'reciver_id': widget.cli_id,
        'message': message,
        'dt_tm': dateTimeString,
      });

      if (response.statusCode == 200) {
        print(response.body);
        messagelist(widget.who,widget.cli_id);
        
      } else {
        print(response.body);
          messagelist(widget.who,widget.cli_id);
      }
    } catch (e) {
      // Handle fetch error
      print('Fetch error: $e');
      
    }

  }






  @override
  Widget build(BuildContext context) {

    return Scaffold(
            appBar: AppBar(
        toolbarHeight:  80,
        elevation: 3,
        shadowColor: Color.fromARGB(255, 255, 115, 0),
        centerTitle: true,
       // leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 Image(
                  image: AssetImage('assets/images/logo_gm3.png'),
                  width: 60,
                ),
                SizedBox(width: 20,),

              Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/emt.jpg'),
                    ),
                    SizedBox(width: 20,),
                  Text('ADMIN',style: TextStyle(fontSize: 18),)
                  ],
                )
               
                
              ],
            ),
           
          ],
        ),
      ),


      body: 
     Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: climsglist.length,
              itemBuilder: (context, index) {
                return 
                  Column(
                    crossAxisAlignment: 
                    climsglist[index]['who_snd']=='ADMIN'  
                              ? CrossAxisAlignment.end
                              :CrossAxisAlignment.start,
                    
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:20.0,vertical: 3),
                        child: Container(
                          
                          decoration: BoxDecoration(
                            color: 
                            climsglist[index]['who_snd']=='ADMIN'
                            ?Color.fromARGB(255, 206, 255, 199)
                            :Color.fromARGB(255, 218, 218, 218),
                            borderRadius: BorderRadius.circular(10)
                          ),
                         
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal:10.0,vertical: 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                 
                                  Text(climsglist[index]['snd_msg'],style:TextStyle(fontSize: 18),),
                                 Text(
        // Convert string to DateTime and then format it
        DateFormat.Hm().format(DateTime.parse(climsglist[index]['msg_time'])),
        style: TextStyle(fontSize: 12,color: Colors.grey),
      ),
                                ],
                              ),
                            ),
                          ),
                      ),
                        
                    ],
                  );
                    
              
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5)
                      ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          fillColor: const Color.fromARGB(255, 230, 228, 228),
                          filled: true
                        ),
                      ),
                    ),

                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,color: Color.fromARGB(255, 29, 179, 34),),
                  onPressed: () {
                    String message = messageController.text;
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      )
     
    );
  }
}