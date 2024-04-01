import 'package:flutter/material.dart';

class DialogUtils {
  static void showSuccessDialog(BuildContext context) {
    final GlobalKey<State> dialogKey = GlobalKey<State>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: dialogKey, // Assign the GlobalKey to the AlertDialog
          content: Container(
            height: 200,
            child: Column(
              children: [
                Image(image: AssetImage('assets/images/verify.png'), height: 100,),
                Text('Upload', style: TextStyle(fontSize: 35, color: Colors.green, fontWeight: FontWeight.bold),),
                Text('File upload success', style: TextStyle(fontSize: 15, color: Colors.black45),),
              ],
            ),
          ),
        );
      },
    );

    // Close the dialog after 2 seconds if it's still open
    Future.delayed(Duration(seconds: 3), () {
      if (dialogKey.currentContext != null) {
        Navigator.of(dialogKey.currentContext!).pop();
      }
    });
  }
}
