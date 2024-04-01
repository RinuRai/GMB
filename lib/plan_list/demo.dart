import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body : Container(
        
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          
          child: Column(
            children: [
              SizedBox(height: 20,),
               SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                 child: Row(
                   children: [
                     Image(
                                 image: AssetImage(
                      'assets/images/logo_gm3.png'),
                                 width: 120,
                               ),
                  SizedBox(width: 20,),
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                          
                           Text('GREEN MARVEL',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 0, 82, 150)),),
                           Text('BUILDERS & DEVELOPERS pvt LTD',style: TextStyle(fontSize: 15),),
                            Text('Info@greenmarvrlbuilders.com',style: TextStyle(fontSize: 15,color: Colors.blue),),
                         ],
                       )  , 
                 
                      //   SizedBox(width: 20,),
                      //   Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //    children: [
                      //      Text('3rd Floor,pulimootil',style: TextStyle(fontSize: 15),),
                      //      Text('Trade center Mollakkal',style: TextStyle(fontSize: 12),),
                      //       Text('Alappuzha,Kerala',style: TextStyle(fontSize: 12),),
                      //    ],
                      //  )  ,      
                   ],
                 ),
               ),

            SizedBox(height: 20,),
                Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      height: 50,
                      child: Center(
                        child: Text('Excavation check List',style: TextStyle(fontSize: 20,decoration: TextDecoration.underline),),
                      ),
                    ),
                  ),
                ],
              ),

               Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.red,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(top:15.0,left:15),
                        child: Text('CLIENT NAME :',),
                      ),
                    ),
                  ),
                ],
              ),


              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                      height: 50,
                      child:  Padding(
                        padding: const EdgeInsets.only(top:15.0,left:15),
                        child: Text('STARTING DATE :',),
                      ),
                    ),
                  ),
                  Expanded(
                    
                    child: Container(
                      color: Colors.green,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(top:15.0,left:15),
                        child: Text('COMPLIEION DATE :',),
                      ),
                    ),
                  ),
                ],
              ),





              // Second row with one column
              Row(
                children: [
                  Expanded(
                    
                    child: Container(
                      color: Colors.red,
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.only(top:15.0,left:15),
                        child: Text('Remarks'),
                      ),
                    ),
                  ),
                ],
              ),
              // Third row with two columns
              
            ],
          ),
        ),
      ),
    );
  }
}




    // int randomNumber11 = Random().nextInt(10000);
    // final String dir = (await getExternalStorageDirectory())!.path;
    // final String path = '$dir/$randomNumber11 report.pdf';
    // final file = File(path);
    // await file.writeAsBytes(await pdf.save());
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('PDF saved to $path'),
    //     backgroundColor: Colors.green,
    //   ),
    // );