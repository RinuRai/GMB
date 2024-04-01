// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'pages/adminhomepage.dart';
import 'pages/bottom_navigate.dart';
import 'pages/client_details.dart';
import 'pages/loginpage.dart';
import 'pages/view_client.dart';
import 'plan_list/add_plans.dart';
import 'plan_list/electricalplan.dart';
import 'plan_list/demo.dart';
// import 'pages/homepage.dart';
// import 'pages/loginpage.dart';
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenMarvelBuilders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: AppBarTheme(color: Colors.white,titleTextStyle: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold, )),
        fontFamily: 'Calibri',
        useMaterial3: true,
      ),
      home: 
      //HomePage(),
      //LoginPage(),
      //SplashScreen(),
      //AdminHomePage(),
       Home_Navigator(),
      //FlorPlan_page(),
      //Electrical_Plan(),
      //Add_GMPlans(),
      //View_Client_DT(),
      //Client_Detail(),
      //Demo(),
    );
  }
}
