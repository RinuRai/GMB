import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/loginpage.dart';

class Electrical_Plan extends StatefulWidget {
  const Electrical_Plan({super.key});

  @override
  State<Electrical_Plan> createState() => _Electrical_PlanState();
}

class _Electrical_PlanState extends State<Electrical_Plan> {


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }


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






  String selectedCategory = 'All'; // Track the selected category

  void selectCategory(String categoryName) {
    setState(() {
      selectedCategory = categoryName; // Update the selected category
    });
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
           appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            'assets/images/bg1.jpg', // Replace with your background image path
            fit: BoxFit.cover,
          ),
          title: Text(
            'Results (535)',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          
        ),
        toolbarHeight: 60,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
      ),

      body: Column(
        children: [
          Container(
            width:double.infinity,
            color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Text('Categories',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black54),),
                ),
               SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                 child: Row(
                    children: [
                      // Example categories
                      cate1(
                        name: 'All',
                        isSelected: selectedCategory == 'All',
                        onSelect: selectCategory,
                      ),
                      cate1(
                        name: 'Kitchen',
                        isSelected: selectedCategory == 'Kitchen',
                        onSelect: selectCategory,
                      ),
                      cate1(
                        name: 'Bedroom',
                        isSelected: selectedCategory == 'Bedroom',
                        onSelect: selectCategory,
                      ),
                      cate1(
                        name: 'Hall',
                        isSelected: selectedCategory == 'Hall',
                        onSelect: selectCategory,
                      ),
                      cate1(
                        name: 'Living Room',
                        isSelected: selectedCategory == 'Living Room',
                        onSelect: selectCategory,
                      ),
                    ],
                  ),
               ),
               Divider()
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0,vertical: 20),
                  child: Container(
                    child: Column(
                      children: [
                        Image(image: AssetImage('assets/images/bg7.jpg')),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Green Marvel Appartment',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                Text('2 Lakh',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black38),),
                              ],
                            ),
                            OutlinedButton(onPressed: (){}, child: Text('See Details')),
                        
                          ],
                        ),

                  whoIs == 'ADMIN'
                     ? Padding(
                       padding: const EdgeInsets.symmetric(vertical:10.0),
                       child: InkWell(
                          onTap: () {
                            // login();
                            //logindemo();
                          },
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg1.jpg'),fit: BoxFit.cover),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/logo_gm3.png'),
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Change Plan',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                     )
                      : Container(),
                         Divider(color: Colors.black12,),
                      ],
                    ),
                  ),
                );
              }),
          )

        ],
      ),
    );
  }
}


class cate1 extends StatelessWidget {
  final String name; // Define a property to store the category name
  final bool isSelected; // Check if this category is selected
  final Function(String) onSelect; // Callback when category is selected

  const cate1({
    required this.name,
    required this.isSelected,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect(name); // Call the onSelect callback with the category name
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Color.fromARGB(255, 209, 101, 0) : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
          child: Text(
            name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
