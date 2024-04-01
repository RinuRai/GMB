import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;


  final List<String> imageUrls = [
    'assets/images/img1.jpg',
    'assets/images/img2.jpg',
    'assets/images/img3.jpg',
    'assets/images/img4.jpg',
    'assets/images/img5.jpg',
  ];

  final List<String> text = [
    'Building the lifestyle of Tomorrow',
    'Best Architecture and Interior Design Services',
    'Turning Your Dreams into real Homes',
    'Marriage lets you for the rest of your life.',
    'The highest happiness on earth is marriage.'
  ];

  final List<String> info = ['Read More', 'Read More', 'Read More', 'Read More', 'Read More'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        toolbarHeight: 100,
       title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Image.asset(
              'assets/images/logo_gm.png', 
              height: 80, 
              width: 220, 
              fit: BoxFit.contain, 
            ),
           
          popupicon(),
         ],
       ),
     
      ),


      

body:  IndexedStack(
  index: _currentIndex,
  children: [
    SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 270,
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: imageUrls.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Stack(
                  children: [
                    Container(
                      height: 270, // Set the height to match the container
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: AssetImage(imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 250, // Set the width to control the size
                        height: 120,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(68, 10, 2, 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text[index],style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                              OutlinedButton(onPressed: (){}, child: Text('Read More',style: TextStyle(color: Colors.white)))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
              options: CarouselOptions(
                height: 270, // Match the height of the container
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                enableInfiniteScroll: true,
                viewportFraction: 1,
              ),
            ),
          ),
    
        Card(
        child: ListTile(
          leading: Image(image: AssetImage('assets/images/png1.jpg'),width: 80,),
          title: Text('OUR MISSION',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
          subtitle: Text('We deliver exceptional quality homes, offices and hotels to enhance customer lifestyle and happiness that sustains for generations..'),
        ),
      ), Card(
        child: ListTile(
          leading: Image(image: AssetImage('assets/images/png2.png'),width: 80,),
          title: Text('TRUST',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
          subtitle: Text('Customer satisfaction is the cornerstone of all efforts as the company endeavours to craft homes for lifelong happiness.'),
        ),
      ),
       Card(
        child: ListTile(
          leading: Image(image: AssetImage('assets/images/png3.png'),width: 80,),
          title: Text('CONSISTANCY',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
          subtitle: Text('Every home built is a product of meticulous planning and fine attention to detail to meet customer expectations.'),
        ),
      ),

      Container(
        width: double.infinity,
        height: 300,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               SizedBox(height: 20,),
              Text('GREEN MARVEL BUILDERS & DEVELOPERS',style: TextStyle(color: Colors.white,fontSize:16)),
               SizedBox(height: 20,),
              Row(
                children: [
                   Icon(Icons.location_on,color: Colors.white,),
                  SizedBox(width: 10,),
                  Text('3rd Floor,Pulimootil Trade Center Mullakkal,\nAlappuzha-688011,Kerala',style: TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.add_ic_call_rounded,color: Colors.white,),
                  SizedBox(width: 10,),
                  Text('+91-9497218832',style: TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.add_ic_call_rounded,color: Colors.white,),
                  SizedBox(width: 10,),
                  Text('+91-8075193470',style: TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                   Icon(Icons.add_ic_call_rounded,color: Colors.white,),
                  SizedBox(width: 10,),
                  Text('+91-8075193470',style: TextStyle(color: Colors.white)),
                ],
              ),
               SizedBox(height: 20,),
              Divider(),
             Spacer(),
              Center(child: Text('© Green Marvel, All Right Reserved.',style: TextStyle(color: Colors.white))),
               SizedBox(height: 20,),
            ],
          ),
        ),
      )
        ],
      ),
    ),


    Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(50)
          ),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width:200,
                 child:TextField(
                  decoration: InputDecoration(
                    hintText: 'search here.....',
                  border: InputBorder.none,
                  ),
                 )),
              IconButton(onPressed: (){}, icon: Icon(Icons.search))
            ],
          ),
        ),

      Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: imageUrls.length, // Replace with the actual number of items
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 10.0, // Spacing between columns
            mainAxisSpacing: 10.0, // Spacing between rows
          ),
          itemBuilder: (BuildContext context, int index) {
            // Replace this Container with your widget for each grid item
            return Container(
              color: Colors.blueGrey,
              child: Image(image: AssetImage(imageUrls[index]),fit: BoxFit.cover,),
            );
          },
        ),
      ),
    ),

      ],
    ),
    
    
    Container(
       width: double.infinity,
       height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
                      children: [
                            Container(
                              height: 150, // Set the height to match the container
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/ban1.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: 100,
                              child: Container(
                                width: 200, // Set the width to control the size
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(68, 10, 2, 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Contact Us',style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),
                                
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
        
             
            //  Center(child: Text('If You Have Any Query, Please Feel\nFree Contact Us',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),)),  
            Container(
            width: double.infinity,
            height: 450,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Text('If You Have Any Query, Please Feel Free Contact Us',style: TextStyle(color: Colors.white,fontSize:15)),
                   Divider(),
                  SizedBox(height: 20,),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.location_on,size: 50,),
                      title: Text('GREEN MARVEL BUILDERS & DEVELOPERS',style: TextStyle(color: Colors.black,fontSize:16)),
                      subtitle: Text('3rd Floor,Pulimootil Trade Center Mullakkal,\nAlappuzha-688011,Kerala',style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  
                  SizedBox(height: 20,),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.add_ic_call_rounded,size: 50,),
                      title: Text('Call Us Now',style: TextStyle(color: Colors.black)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('+91-9497218832',style: TextStyle(color: Colors.black)),
                          Text('+91-8075193470',style: TextStyle(color: Colors.black)),
                          Text('+91-8075193470',style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  
                   SizedBox(height: 20,),
                  Divider(),
                 Spacer(),
                  Center(child: Text('© Green Marvel, All Right Reserved.',style: TextStyle(color: Colors.white))),
                   SizedBox(height: 20,),
                ],
              ),
            ),
                )         
          ],
        ),
      ),
    )

  ],
),

     

      bottomNavigationBar: BottomNavigationBar(
      elevation: 10,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation to different tabs here
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'contact',
          ),
        ],
      ),
    );   
  }

   PopupMenuButton<dynamic> popupicon() {
    return PopupMenuButton(
        color:Colors.white,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
             child: Column(
              children: [
                TextButton(onPressed: (){}, child: Text('Home')),
                TextButton(onPressed: (){}, child: Text('About')),
                TextButton(onPressed: (){}, child: Text('Service')),
                TextButton(onPressed: (){}, child: Text('Pricing')),
                TextButton(onPressed: (){}, child: Text('Contact')),
              ],
             ),
            ),
          ];
        },
        child: Container(child: Icon(Icons.menu,size: 40,)));
  } 
}