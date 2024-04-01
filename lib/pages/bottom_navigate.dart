import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Chat_Funtion/chating_page.dart';
import '../config.dart';
import 'adminhomepage.dart';
import 'client_details.dart';
import 'gallerypage.dart';
import 'loginpage.dart';

class Home_Navigator extends StatefulWidget {
  const Home_Navigator({super.key});

  @override
  State<Home_Navigator> createState() => _Home_NavigatorState();
}

class _Home_NavigatorState extends State<Home_Navigator> {
  int _currentIndex = 0;

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
        isloading = true;
      });
    } else {
      // Redirect to the login page since no valid login data exists.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  final List<Widget> _screens = [
    AdminHomePage(),
    Client_Detail(),
    GalleryPage(),
    ChatingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? _screens[_currentIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Colors
            .white, // Set the background color for the bottom navigation bar

        selectedItemColor: isloading
            ? Colors.black
            : Colors.white, // Color of the selected item
        unselectedItemColor: isloading
            ? Colors.grey
            : Colors.white, // Color of the unselected items
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              whoIs =='CLIENT' 
              ? Icons.info
              :Icons.people_alt_sharp),
            label: 
            whoIs =='CLIENT' 
            ?'About'
            :'Client',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 
            whoIs =='CLIENT'
            ?'Gallery'
            :'Add Site',
          ),
           if (whoIs != 'STAFF') 
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
          
        ],
      ),
    );
  }
}
