import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class DisableClient extends StatefulWidget {
  const DisableClient({Key? key, required this.stfid}) : super(key: key);

  final String stfid;

  @override
  State<DisableClient> createState() => _DisableClientState();
}

class _DisableClientState extends State<DisableClient> {
  var backendIP = ApiConstants.backendIP;

  String whoIs = '';
  String user_id = '';

  

  bool isloading = false;
  List<String> selectedClients = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var whoIs1 = sharedPreferences.getString('whoIs');
    var user_id1 = sharedPreferences.getString('user_id');
    if (whoIs1 != null) {
      setState(() {
        whoIs = whoIs1;
        user_id = user_id1!;
        getUserData();
        DisableList();
        print(whoIs);
        print(user_id);
      });
    } else {
      null;
    }
  }

  List fetchDisablelist = [];
 
  Future<void> DisableList() async {
    try {
      var apiUrl = Uri.parse('$backendIP/Add_Disable.php');
      var response = await http.post(apiUrl, body: {'action': 'DISABLE-List-Fetch', 'stf_id': widget.stfid.toString()});
      if (response.statusCode == 200) {
        setState(() {
          fetchDisablelist = json.decode(response.body);
          isloading = true;
          print(fetchDisablelist);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }

  List fetchalldata = [];
  String fetchdataLength = '';
  Future<void> getUserData() async {
    try {
      var apiUrl = Uri.parse('$backendIP/fetching.php');
      var response = await http.post(apiUrl, body: {'action': whoIs, 'user_id': user_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchalldata = json.decode(response.body);
          fetchdataLength = fetchalldata.length.toString();
          isloading = true;
          print(fetchalldata);
        });
      }
    } catch (e) {
      print('error $e');
    }
  }




  void toggleClientSelection(String clientId) {
    setState(() {
      if (selectedClients.contains(clientId)) {
        selectedClients.remove(clientId);
      } else {
        selectedClients.add(clientId);
      }
    });
  }

  Future<void> submitSelectedClients() async {
    // Implement your logic to submit selected clients here
    print(selectedClients);

    try {
      var apiUrl = Uri.parse('$backendIP/Add_Disable.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'DISABLE-LIST-ADD',
        'stf_id': widget.stfid.toString(),
        'cli_id': jsonEncode(selectedClients),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Disable Added',
                  style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      } else {
        print('Error occurred during upload: ${response.body}');
        SnackBar(
          backgroundColor: Colors.red,
          content: Container(
            height: 30,
            child: Center(
              child: Text(
                'Failed Disable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Disable error $e');
    }

    setState(() {
      selectedClients.clear();
    });
  }

//////////////////////////////////////////////////////////////////////////////////////////
///

 Future<void> submitSelectedClientsuncheck() async {
    // Implement your logic to submit selected clients here
    print(selectedClients);

    try {
      var apiUrl = Uri.parse('$backendIP/Add_Disable.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'ENABLE-CLIENT',
        'stf_id': widget.stfid.toString(),
        'cli_id': jsonEncode(selectedClients),
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Client Enabled',
                 style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      } else {
        print('Error occurred during upload: ${response.body}');
        SnackBar(
          backgroundColor: Colors.red,
          content: Container(
            height: 30,
            child: Center(
              child: Text(
                'Failed Enabled',
               style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Enabled error $e');
    }

    setState(() {
      selectedClients.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          elevation: 10,
          title: Text(
            'Disable client',
            style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
          ),
          centerTitle: true,
          toolbarHeight: 80,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
       bottom: TabBar(
  indicatorColor: Colors.white, // Set the color of the indicator
  labelColor: Colors.white, // Set the color of the selected tab label
  unselectedLabelColor: const Color.fromARGB(255, 168, 167, 167), // Set the color of the unselected tab label
  tabs: [
    Tab(text: 'Disable'),
    Tab(text: 'Enable'),
  ],
),
        ),
        body: TabBarView(
          children: [
            // Disable Tab Content
            isloading
                ? Container(
                    decoration: BoxDecoration(),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: fetchalldata.length,
                            itemBuilder: (context, index) {
                              String cl_us_id = fetchalldata[index]['us_id'];
                              String cl_name = fetchalldata[index]['nm'];

                               // Check if cl_us_id exists in fetchDisablelist
                              bool isDisabled = fetchDisablelist.any((disableItem) => disableItem['cli_id'] == cl_us_id);

                                // If isDisabled is true, skip rendering this item
                                if (isDisabled) {
                                  return SizedBox.shrink(); // Skip rendering this item
                                }

                              return Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
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
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(color: Colors.transparent),
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  toggleClientSelection(cl_us_id);
                                                },
                                                child: Checkbox(
                                                  value: selectedClients.contains(cl_us_id),
                                                  onChanged: (value) {
                                                    toggleClientSelection(cl_us_id);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: submitSelectedClients,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            minimumSize: Size(150, 40),
                          ),
                          child: Text(
                            'Disable',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  )
                : Center(child: CircularProgressIndicator()),


 ////////////////////////////////////////////////////////////////////////////////////////////////////////////               

            // Enable Tab Content
            // Add your content for the 'Enable' tab here
            isloading
                ? Container(
                    decoration: BoxDecoration(),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
Expanded(
  child: ListView.builder(
    itemCount: fetchDisablelist.length,
    itemBuilder: (context, index) {
      String cl_us_id = fetchDisablelist[index]['cli_id'];

      // Find the corresponding client name in fetchalldata
      var matchingClient = fetchalldata.firstWhere(
        (data) => data['us_id'] == cl_us_id,
        orElse: () => null, // Return null if no matching client found
      );

      // If a matching client is found, display its name
      if (matchingClient != null) {
        String cl_name = matchingClient['nm'];
        
        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            toggleClientSelection(cl_us_id);
                          },
                          child: Checkbox(
                            value: selectedClients.contains(cl_us_id),
                            onChanged: (value) {
                              toggleClientSelection(cl_us_id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider()
            ],
          ),
        );
      } else {
        return SizedBox.shrink(); 
      }
    },
  ),
),


                        ElevatedButton(
                          onPressed: submitSelectedClientsuncheck,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            minimumSize: Size(150, 40),
                          ),
                          child: Text(
                            'Enable',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
