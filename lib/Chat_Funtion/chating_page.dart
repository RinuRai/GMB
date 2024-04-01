import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../pages/loginpage.dart';
import 'admin_chat_page.dart';

class ChatingPage extends StatefulWidget {
  const ChatingPage({super.key});

  @override
  State<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
var backendIP = ApiConstants.backendIP;
 Timer? _timer;

 @override
  void initState() {
    super.initState();
    checkLoginStatus();
   
  }


  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _updateState();
    });
  }

void _updateState() {
  // Perform the setState to update the state
  setState(() {
    // Call your messagelist function here with desired arguments
    messagelist(whoIs, user_id);
  });
}

void dispose() {
    _timer?.cancel(); // Check if _timer is not null before calling cancel()
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
        if(whoIs=='ADMIN'){
          getUserdata();
        }else{
          messagelist(whoIs,user_id);
           _startTimer();
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
          adminmessagelist();
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

/////////////////////////////////////////////////////////////////////////////////
  List adminmsglist = [];
  Future<void> adminmessagelist() async {
    try {
      var apiUrl = Uri.parse('$backendIP/msg_snd_recv.php');
      var response =
          await http.post(apiUrl, body: {'action': 'Admin-Message-List', 
         });
      if (response.statusCode == 200) {
        setState(() {
          adminmsglist = json.decode(response.body);
          isloading = true;
          print(adminmsglist);
        });
      }
    } catch (e) {
      print('error $e');
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
        'reciver_id': 'ADMIN',
        'message': message,
        'dt_tm': dateTimeString,
      });

      if (response.statusCode == 200) {
        print(response.body);
       messagelist(whoIs,user_id);
        
      } else {
        print(response.body);
         messagelist(whoIs,user_id);
      }
    } catch (e) {
      // Handle fetch error
      print('Fetch error: $e');
      
    }

  }






  @override
  Widget build(BuildContext context) {

 List<Map<String, dynamic>> usersWithMessages = [];
    List<Map<String, dynamic>> usersWithoutMessages = [];

    fetchalldata.forEach((data) {
      String cl_us_id = data['us_id'];

      if (adminmsglist.any((msg) => msg['snd_id'] == cl_us_id)) {
        usersWithMessages.add(data);
      } else {
        usersWithoutMessages.add(data);
      }
    });

    List<Map<String, dynamic>> combinedList = [...usersWithMessages, ...usersWithoutMessages];


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
                SizedBox(width: 20,),
                 Image(
                  image: AssetImage('assets/images/logo_gm3.png'),
                  width: 60,
                ),
                SizedBox(width: 20,),

             whoIs != 'ADMIN'
              ?   Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/emt.jpg'),
                    ),
                    SizedBox(width: 20,),
                  Text('ADMIN',style: TextStyle(fontSize: 18),)
                  ],
                )
                :Row(
                  children: [
                    SizedBox(width: 20,),
                  Text('MESSAGE',style: TextStyle(fontSize: 18,letterSpacing: 3),)
                  ],
                )
                
              ],
            ),
           
          ],
        ),
      ),


      body: 
      whoIs != 'ADMIN'
      ?Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: climsglist.length,
              itemBuilder: (context, index) {
                return 
                  Column(
                    crossAxisAlignment: 
                    climsglist[index]['who_snd']=='CLIENT'  
                              ? CrossAxisAlignment.end
                              :CrossAxisAlignment.start,
                    
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:20.0,vertical: 3),
                        child: Container(
                          
                          decoration: BoxDecoration(
                            color: 
                            climsglist[index]['who_snd']=='CLIENT'
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
        style: TextStyle(fontSize: 12),
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
      :Column(
        children: [
         Expanded(
           child: Container(
   child: ListView.builder(
  itemCount: combinedList.length,
  itemBuilder: (context, index) {
    String cl_us_id = combinedList[index]['us_id'];
    String cl_name = combinedList[index]['nm'];

    // Check if cl_us_id matches any snd_id in adminmsglist
    if (adminmsglist.any((msg) => msg['snd_id'] == cl_us_id)) {
      String lastMessage = adminmsglist.firstWhere((msg) => msg['snd_id'] == cl_us_id)['snd_msg'];

      return Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/emt.jpg'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cl_name'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 14,
                          // Add other styles as needed
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminChatingPage(cli_id: cl_us_id,who: 'CLIENT')));
                    },
                    icon: Icon(Icons.message),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Display users without messages
      return Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/emt.jpg'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cl_name'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // You can add other details here for users without messages
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {

                       Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminChatingPage(cli_id: cl_us_id,who: 'CLIENT')));
                    },
                    icon: Icon(Icons.message),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  },
),
                      ),
         ),
        ],
      )
    );
  }
}