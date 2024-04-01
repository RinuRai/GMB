import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
 var backendIP = ApiConstants.backendIP;

class APIService {
  static Future<List> disableList(String stfId) async {
    try {
      var apiUrl = Uri.parse('$backendIP/Add_Disable.php');
      var response = await http.post(apiUrl, body: {'action': 'DISABLE-List-Fetch', 'stf_id': stfId.toString()});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle error response if needed
        return [];
      }
    } catch (e) {
      print('error $e');
      return [];
    }
  }
}
