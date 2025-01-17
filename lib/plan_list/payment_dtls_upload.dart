// ignore_for_file: camel_case_types, non_constant_identifier_names, library_private_types_in_public_api, avoid_print, prefer_const_constructors, use_build_context_synchronously, unused_element, sized_box_for_whitespace, unnecessary_cast, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../pages/bottom_navigate.dart';
//import 'add_plans.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../pages/widget.dart';

class Payment_Dtls_Upload extends StatefulWidget {
  const Payment_Dtls_Upload({Key? key}) : super(key: key);

  @override
  _Payment_Dtls_UploadState createState() => _Payment_Dtls_UploadState();
}

class _Payment_Dtls_UploadState extends State<Payment_Dtls_Upload> {
  String id = '';
  String cli_id = '';
  String cli_nm = '';
  String plan_title = '';
  String whoIs = '';
  var backendIP = ApiConstants.backendIP;

  String contenttitle = '';

  @override
  void initState() {
    super.initState();
    contenttitle = '';
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var plan_title11 = sharedPreferences.getString('pay_title');
    var id11 = sharedPreferences.getString('id');
    var user_id11 = sharedPreferences.getString('cli_id');
    var user_nm11 = sharedPreferences.getString('cli_nm');
    var whoIs1 = sharedPreferences.getString('whoIs');
    if (user_id11 != null) {
      setState(() {
        cli_id = user_id11;
        cli_nm = user_nm11!;
        id = id11!;
        plan_title = plan_title11!;
        whoIs = whoIs1!;
        print(id);
        print(cli_id);
        print(plan_title);
        print(cli_nm);
        print(whoIs);
        if (plan_title == 'Payment Details') {
          getClidata('DTL-FT-PAYMENT');
        } else if (plan_title == 'Shedule') {
          getClidata('DTL-FT-SHEDULE');
        } else if (plan_title == 'Check List') {
          getClidata('DTL-FT-CHECK');
        } else {
          print('error');
        }

        rmrkClidata();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home_Navigator()),
      );
    }
  }

  List fetchclidata = [];

  Future<void> getClidata(String categry) async {
    print(categry);
    print(cli_id);

    try {
      var apiUrl = Uri.parse('$backendIP/Fetch_pay_shed_check.php');
      var response = await http
          .post(apiUrl, body: {'action': categry, 'clius_id': cli_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchclidata = json.decode(response.body);
          print(fetchclidata);

          if (contenttitle.isNotEmpty) {
            title = contenttitle;
          } else {
            if (plan_title != 'Payment Details') {
              title = fetchclidata[0]['titl'];
            } else {
              null;
            }
          }
        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  Map<String, dynamic> fetchrmrkdata = {};

  Future<void> rmrkClidata() async {
    print(cli_id);

    try {
      var apiUrl = Uri.parse('$backendIP/Fetch_pay_shed_check.php');
      var response = await http
          .post(apiUrl, body: {'action': 'Titl-Rmrk_Data', 'clius_id': cli_id});
      if (response.statusCode == 200) {
        setState(() {
          fetchrmrkdata = json.decode(response.body);
          // _chktitle.text = fetchrmrkdata['chk_titl'];
          _chkrmrk.text = fetchrmrkdata['chk_rmk'];
          _shetitle.text = fetchrmrkdata['shed_titl'];
          _shermrk.text = fetchrmrkdata['shed_rmk'];
          print(fetchrmrkdata);
        });
      } else {
        print('Error fetchingn Data');
      }
    } catch (e) {
      print('error $e');
    }
  }

  File? _pickedFile;
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Set to true if you allow multiple file selection
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png'
      ], // Add the extensions you want to allow
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString();
    String day = now.day.toString();
    String date = '$year-$month-$day';

    if (_pickedFile != null) {
      try {
        var apiUrl = '$backendIP/Add_payment_Dtls.php';
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields['pay_title'] = plan_title;
        request.fields['user_id'] = cli_id;
        request.fields['pay_date'] = date;
        request.files.add(await http.MultipartFile.fromPath(
          'user_file',
          _pickedFile!.path,
        ));

        final response = await request.send();
        if (response.statusCode == 200) {
          // Handle success
          final responseData = await response.stream.toBytes();
          final responseString = String.fromCharCodes(responseData);
          print('Response: $responseString');

          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.remove('cli_id');
          sharedPreferences.remove('id');
          sharedPreferences.remove('pay_title');
          sharedPreferences.remove('paytitle');

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Layout_Works()),
          // );
          Navigator.pop(context);
          Navigator.pop(context);
          DialogUtils.showSuccessDialog(context);
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File upload failed'),
            ),
          );
        }
      } catch (e) {
        // Handle exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
          ),
        );
      }
    }
  }

  Widget _displayFile() {
    if (_pickedFile != null) {
      String extension = _pickedFile!.path.split('.').last.toLowerCase();

      if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
        return Image.file(
          _pickedFile!,
          width: 250,
          height: 200,
          fit: BoxFit.cover,
        );
      } else if (extension == 'pdf') {
        // Display a PDF icon or placeholder
        return Icon(Icons.picture_as_pdf, size: 50);
      } else if (extension == 'doc' || extension == 'docx') {
        // Display a document icon or placeholder
        return Icon(Icons.description, size: 50);
      } else {
        // Display a generic icon or placeholder for other file types
        return Icon(Icons.insert_drive_file, size: 50);
      }
    } else {
      return Center(
          child: OutlinedButton(
              onPressed: () {
                _pickFile();
              },
              child: Text('Choose File')));
    }
  }

////////////////////////////////////////////////////////////////////////////////
  final _paymentdtls = GlobalKey<FormState>();
  String description = '';
  String prectange = '';
  String amount = '';
  String _selectedOption = '';
  bool alertsts = false;

  DateTime paymentDT = DateTime.now();
  Future<void> _paymentDT(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: paymentDT,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != paymentDT) {
      setState(() {
        paymentDT = picked;
      });
    }
  }

  void paymentfun() async {
    try {
      print(description);
      print(prectange);
      print(amount);
      print(_selectedOption);
      print(cli_id);
      print(paymentDT);

      var apiUrl = Uri.parse(
          '$backendIP/Add_payment_Dtls.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'PAYMENT-DTL',
        'descrpt': description.toString(),
        'pretng': prectange.toString(),
        'amt': amount.toString(),
        'sts': _selectedOption,
        'userId': cli_id,
        'date': paymentDT.toString(),
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
                  'Payment Details Added',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ),
        );
        setState(() {
          description = '';
          prectange = '';
          amount = '';
          _selectedOption = '';
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
                'Failed Submit',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('insert error $e');
    }
  }

//////////////////////////////////////////////////////////////////////////////

  DateTime StartedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: StartedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != StartedDate) {
      setState(() {
        StartedDate = picked;
      });
    }
  }

  DateTime Finishdate = DateTime.now();

  Future<void> _FinishDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Finishdate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != Finishdate) {
      setState(() {
        Finishdate = picked;
      });
    }
  }

  String content123 = '';
  String sts = '';

  bool checkBox1 = false;
  bool checkBox2 = false;

  void toggleCheckBox1(bool newValue) {
    setState(() {
      checkBox1 = newValue;
      if (newValue) checkBox2 = false;
    });
  }

  void toggleCheckBox2(bool newValue) {
    setState(() {
      checkBox2 = newValue;
      if (newValue) checkBox1 = false;
    });
  }

  int textFieldCount = 1;
  final _shedulekey = GlobalKey<FormState>();
  bool alertsdul = false;
  List<String> sheduleList = [];
  List<String> presentageList = [];
  List<Map<String, dynamic>> combinedList = [];

  void shedulefun() async {
    for (int i = 0; i < sheduleList.length; i++) {
      Map<String, dynamic> item = {
        'content': sheduleList[i],
        'percentage': presentageList.length > i
            ? presentageList[i]
            : '', // Ensure presentageList has value for each index
      };
      combinedList.add(item);
    }

    try {
      print(StartedDate);
      print(Finishdate);
      print(combinedList);
      print(sts);
      print(cli_id);
      print(_chktitle);

      var apiUrl = Uri.parse(
          '$backendIP/Add_payment_Dtls.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'SHEDULE-DTL',
        'srt_dt': StartedDate.toString(),
        'fin_dt': Finishdate.toString(),
        'combinedList': jsonEncode(combinedList),
        'sts': sts,
        'userId': cli_id,
        //'title': _shetitle.text,
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
                  'Shedule Added',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkBox1 = false;
          checkBox2 = false;
          sts = '';
          _selectedOption = '';
          sheduleList = [];
          presentageList = [];
          textFieldCount = 1;
          sheduleList.clear();
          presentageList.clear();
          combinedList.clear();
          checkLoginStatus();
          // Schedule notification at Finishdate
        });
      } else {
        print('Error occurred during upload: ${response.body}');
        SnackBar(
          backgroundColor: Colors.red,
          content: Container(
            height: 30,
            child: Center(
              child: Text(
                'Failed Submit',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('insert error $e');
    }
  }

  DateTime chgeStartedDate = DateTime.now();
  Future<void> _chngselectDate1(BuildContext context, abcd, uid, id) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: StartedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != StartedDate) {
      setState(() {
        chgeStartedDate = picked;
        updateDatechange(uid, id, chgeStartedDate, abcd);
      });
    }
  }

  DateTime chgeFinishDate = DateTime.now();
  Future<void> _chngselectDate2(BuildContext context, abcd, uid, id) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: StartedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != StartedDate) {
      setState(() {
        chgeFinishDate = picked;
        updateDatechange(uid, id, chgeFinishDate, abcd);
      });
    }
  }

  void updateDatechange(uid, id, dt, titl) async {
    print(dropdownValues);
    print(uid);
    print(id);
    print(dt);
    print(titl);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/sts_update.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': titl,
        'updt': dt.toString(),
        'empid': uid,
        'id': id,
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Color(0xFF0078C6),
              child: Center(
                child: Text(
                  'Update Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }

/////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
  List<String> contentList = [];
  final _checklistkey = GlobalKey<FormState>();
  bool alertcheck = false;

  void checkfun() async {
    try {
      print(StartedDate);
      print(Finishdate);
      print(sts);
      print(cli_id);
      print(contentList);
      print(_chktitle);

      var apiUrl = Uri.parse('$backendIP/Add_payment_Dtls.php');

      var response = await http.post(apiUrl, body: {
        'action': 'CHECKLIST-DTL',
        'srt_dt': '0000-00-00',
        'fin_dt': '0000-00-00',
        'content': jsonEncode(contentList), // Serialize the list to JSON
        'sts': sts,
        'userId': cli_id,
        'title': _chktitle.text,
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
                  'CheckList Added successfully',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ),
        );
        setState(() {
          contentList.clear();
          textFieldCount = 1;
          checkLoginStatus();
        });
      } else {
        print('Error occurred during upload: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Failed Submit',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ),
        );
        setState(() {
          contentList.clear();
          textFieldCount = 1;
          checkLoginStatus();
        });
      }
    } catch (e) {
      print('insert error $e');
    }
  }

//////////////////////////////////
  ///
  String title = 'All';

////////////////////////////////////////////////////////////////////
  Map<int, String> dropdownValues = {}; // Store dropdown values per index
  Map<int, String> tlnameValues = {};

  void updatePossition(uid, id, selevalue, titl) async {
    print(dropdownValues);
    print(uid);
    print(id);
    print(selevalue);
    print(titl);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/sts_update.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': titl,
        'upt': selevalue,
        'empid': uid,
        'id': id,
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Color(0xFF0078C6),
              child: Center(
                child: Text(
                  'Update Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          dropdownValues.clear();
          contenttitle = title;
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }
////////////////////////////////////////////////////////////

  void deletethat(category, id, uid) async {
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Delete_Table_list.php'); // Replace with your API endpoint
      var response = await http.post(apiUrl, body: {
        'action': category,
        'id': id,
        'uid': uid,
      });
      print(category);
      print(id);
      print(uid);
      if (response.statusCode == 200) {
        print(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Container(
              height: 30,
              child: Center(
                child: Text(
                  'Deleted',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      }
    } catch (e) {
      print('the error is $e');
    }
  }

////////////////////////////////////////////////////////////////////////
  ///
  final TextEditingController _chktitle = TextEditingController();
  String chktitle = '';

  void titl_rmk(uid, titl, rmrk, action) async {
    print(uid);
    print(titl);
    print(rmrk);
    try {
      var apiUrl = Uri.parse(
          '$backendIP/Title_Remark.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': action,
        'empid': uid,
        'title': titl,
        'rmrk': rmrk,
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Color(0xFF0078C6),
              child: Center(
                child: Text(
                  'Remark Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }

  final TextEditingController _chkrmrk = TextEditingController();
  String chkrmrk = '';

  final TextEditingController _shetitle = TextEditingController();
  final TextEditingController _shermrk = TextEditingController();

///////////////////////////////////////////////////////////////////

  double calculateSubtotal(List dataList) {
    double subtotal = 0;
    for (var data in dataList) {
      subtotal += double.parse(data['amt'].toString());
    }
    return subtotal;
  }

//////////////////////////////////////////////////////////////////////

  int editingIndex = -1;
  final TextEditingController _percentage = TextEditingController();
  final TextEditingController _amt = TextEditingController();

  void updt_Payment_Dtls(uid, id, presentage, amnt) async {
    print(uid);
    print(id);
    print(presentage);
    print(amnt);

    try {
      var apiUrl = Uri.parse(
          '$backendIP/sts_update.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Upt-Pymnt_Dtls',
        'usId': uid,
        'id': id,
        'presentage': presentage,
        'amnt': amnt,
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Update Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          editingIndex = -1;
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////

  DateTime selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context, uid, id) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != StartedDate) {
      setState(() {
        updt_Payment_Dtls_time(uid, id, pickedDate);
      });
    }
  }

  void updt_Payment_Dtls_time(usid, id, datetime) async {
    print(usid);
    print(id);
    print(datetime);

    try {
      var apiUrl = Uri.parse(
          '$backendIP/sts_update.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Upt-Pymnt_Dtls_Time',
        'usId': usid,
        'id': id,
        'datetime': datetime.toString(),
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Date And Time Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }

//////////////////////////////////////////////////////////////////////////////////

  final TextEditingController _prntge = TextEditingController();

  void updt_shedule_prntge(uid, id, presentage) async {
    print(uid);
    print(id);
    print(presentage);

    try {
      var apiUrl = Uri.parse(
          '$backendIP/sts_update.php'); // Replace with your API endpoint

      var response = await http.post(apiUrl, body: {
        'action': 'Upt-she-prtge',
        'usId': uid,
        'id': id,
        'presentage': presentage,
      });

      if (response.statusCode == 200) {
        print('Success Changed: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Container(
              height: 40,
              width: double.infinity,
              color: Colors.green,
              child: Center(
                child: Text(
                  'Update Changed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        setState(() {
          editingIndex = -1;
          checkLoginStatus();
        });
      } else {
        print('Error occurred during change: ${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed change')),
          ),
        );
      }
    } catch (e) {
      print('Change error $e');
    }
  }
//////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 31, 70, 85),
          elevation: 10,
          title: Text(
            plan_title.toUpperCase(),
            style:
                TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
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
              )),
        ),
        body: plan_title == 'Payment Details'
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          color: const Color.fromARGB(255, 226, 226, 226),
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                                '*Note : Add your Payment Details $cli_nm'),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 30),
                        child: Form(
                          key: _paymentdtls,
                          child: Column(
                            children: [
                              TextFormField(
                                // controller: _userName,
                                onChanged: (value) {
                                  setState(() {
                                    description = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Type Description';
                                  }
                                  return null;
                                },
                                // keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  labelText: "Description",
                                  hintStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                // controller: _userName,
                                onChanged: (value) {
                                  setState(() {
                                    prectange = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Type prectange';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  labelText: "Prectange",
                                  hintStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                // controller: _userName,
                                onChanged: (value) {
                                  setState(() {
                                    amount = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Type Amount';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  labelText: "Amount",
                                  hintStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 60,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text:
                                        '${paymentDT.day}-${paymentDT.month}-${paymentDT.year}',
                                  ),
                                  onTap: () {
                                    _paymentDT(context);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Payment Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedOption = 'paid';
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: _selectedOption == 'paid'
                                                  ? Colors
                                                      .green // Change color if selected
                                                  : Colors
                                                      .transparent, // Keep transparent otherwise
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                              child: Text(
                                            'PAID',
                                          )),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedOption = 'pending';
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: _selectedOption ==
                                                      'pending'
                                                  ? Colors
                                                      .green // Change color if selected
                                                  : Colors
                                                      .transparent, // Keep transparent otherwise
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                              child: Text(
                                            'PENDING',
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              alertsts
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          'Select any Status ',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    )
                                  : Text(''),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    if (_paymentdtls.currentState!.validate()) {
                                      if (_selectedOption.isEmpty) {
                                        setState(() {
                                          alertsts = true;
                                        });
                                      } else {
                                        setState(() {
                                          alertsts = false;
                                          paymentfun();
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 150,
                                    child: Card(
                                      color: Color.fromARGB(255, 3, 98, 177),
                                      elevation: 10,
                                      shadowColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Submit',
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateColor.resolveWith(
                                    (Set<MaterialState> states) {
                                  // For the default or other states
                                  return Color.fromARGB(255, 31, 70,
                                      85); // Set your desired color
                                }),
                                headingTextStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight
                                      .bold, // Set your desired font weight
                                  color: Colors
                                      .white, // Set your desired text color
                                ),
                                columnSpacing:
                                    30, // Adjust the spacing between columns as needed
                                dataRowHeight: 80,
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text('SL.NO.',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Description',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Percentage',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Amount',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Edit',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Status',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Date',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  DataColumn(
                                    label: Text('Delete',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                                rows: fetchclidata
                                    .asMap()
                                    .entries
                                    .map<DataRow>((entry) {
                                  int index = entry.key;
                                  dynamic data = entry.value;
                                  int currentSerialNumber = index + 1;
                                  Color rowColor = index.isEven
                                      ? Color.fromARGB(36, 158, 158, 158)
                                      : Colors.white;
                                  return DataRow(
                                    color: MaterialStateColor.resolveWith(
                                        (Set<MaterialState> states) {
                                      return rowColor; // Set the row color
                                    }),
                                    cells: [
                                      DataCell(Text(
                                          currentSerialNumber.toString(),
                                          style: TextStyle(fontSize: 18))),
                                      DataCell(Text(
                                          data['description'].toString(),
                                          style: TextStyle(fontSize: 18))),
                                      DataCell(editingIndex == index
                                          ? Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                child: TextFormField(
                                                  controller: _percentage,

                                                  // initialValue: data['name'].toString(),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        data['percentage']
                                                            .toString(),
                                                    border: InputBorder.none,
                                                    // fillColor: Colors.grey[100],
                                                    // filled: true
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(data['percentage'].toString(),
                                              style: TextStyle(fontSize: 18))),
                                      DataCell(editingIndex == index
                                          ? Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                child: TextFormField(
                                                  controller: _amt,

                                                  // initialValue: data['name'].toString(),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    labelText:
                                                        data['amt'].toString(),
                                                    // fillColor: Colors.grey[100],
                                                    // filled: true
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(data['amt'].toString(),
                                              style: TextStyle(fontSize: 18))),
                                      DataCell(
                                        editingIndex == index
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  if (_percentage
                                                          .text.isNotEmpty ||
                                                      _amt.text.isNotEmpty) {
                                                    setState(() {
                                                      editingIndex = -1;
                                                      updt_Payment_Dtls(
                                                          data['us_nm']
                                                              .toString(),
                                                          data['id'].toString(),
                                                          _percentage.text,
                                                          _amt.text);
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(context
                                                            as BuildContext)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Container(
                                                          height: 40,
                                                          width:
                                                              double.infinity,
                                                          color: Color.fromARGB(
                                                              255, 198, 0, 0),
                                                          child: Center(
                                                            child: Text(
                                                              'Enter New Values',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors
                                                      .green, // Set the background color here
                                                ),
                                                child: Text('Submit',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white)),
                                              )
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    editingIndex = index;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.green,
                                                ),
                                              ),
                                      ),
                                      DataCell(
                                        Container(
                                          height: 50,
                                          width: 150,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                DropdownButton<String>(
                                                  value:
                                                      dropdownValues[index] ??
                                                          'default_value',
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      dropdownValues[index] =
                                                          newValue ??
                                                              'default_value';
                                                      String? selevalue =
                                                          newValue;
                                                      updatePossition(
                                                          data['us_nm']
                                                              .toString(),
                                                          data['id'].toString(),
                                                          selevalue,
                                                          plan_title);
                                                    });
                                                  },
                                                  items: [
                                                    DropdownMenuItem<String>(
                                                      value: 'default_value',
                                                      child: Text(data['sts']),
                                                    ),
                                                    DropdownMenuItem<String>(
                                                      value: 'Paid',
                                                      child: Text('Paid'),
                                                    ),
                                                    DropdownMenuItem<String>(
                                                      value: 'Pending',
                                                      child: Text('Pending'),
                                                    ),
                                                    // Other DropdownMenuItem values here
                                                  ],
                                                  underline: Container(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _selectDateTime(
                                              context,
                                              data['us_nm'].toString(),
                                              data['id'].toString()),
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Text(
                                              DateFormat(
                                                      'dd-MM-yyyy') // 'a' represents AM/PM
                                                  .format(DateTime.parse(
                                                      data['date'].toString())),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(IconButton(
                                          onPressed: () {
                                            deletethat(
                                              'PAY-LIST-DEL',
                                              data['id'].toString(),
                                              data['us_nm'].toString(),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            size: 30,
                                            color: Colors.red,
                                          ))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              height: 80,
                              width: double.infinity,
                              color: Color.fromARGB(255, 0, 53, 83),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Sub Total :',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                    Text(' ${calculateSubtotal(fetchclidata)}',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            fetchclidata.isNotEmpty
                                ? Container()
                                : Container(
                                    child: Column(
                                      children: [
                                        Text('No data found'),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : plan_title == 'Shedule'
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _shedulekey,
                        child: Column(
                          children: [
                            Container(
                                color: const Color.fromARGB(255, 226, 226, 226),
                                height: 50,
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                        '*Note : Add your Shedule $cli_nm'))),
                            whoIs == 'STAFF'
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 20),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text:
                                                '${StartedDate.year}-${StartedDate.month}-${StartedDate.day}',
                                          ),
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Start Date',
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text:
                                                '${Finishdate.year}-${Finishdate.month}-${Finishdate.day}',
                                          ),
                                          onTap: () {
                                            _FinishDate(context);
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Finish Date',
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (int i = 0;
                                                      i < textFieldCount;
                                                      i++)
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 10),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width:
                                                                    textFieldCount >
                                                                            1
                                                                        ? 250
                                                                        : 300,
                                                                child:
                                                                    TextFormField(
                                                                  // Additional Text Form Field
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Content ${i + 1}',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    fillColor: Color
                                                                        .fromARGB(
                                                                            141,
                                                                            219,
                                                                            217,
                                                                            217),
                                                                    filled:
                                                                        true,
                                                                  ),
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the corresponding element in the list
                                                                    if (i <
                                                                        sheduleList
                                                                            .length) {
                                                                      setState(
                                                                          () {
                                                                        sheduleList[i] =
                                                                            value;
                                                                        value =
                                                                            "";
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        sheduleList
                                                                            .add(value);
                                                                        value =
                                                                            "";
                                                                      });
                                                                    }
                                                                  },
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Type Content';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ),
                                                              textFieldCount > 1
                                                                  ? IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textFieldCount--;
                                                                          if (i <
                                                                              sheduleList.length) {
                                                                            sheduleList.removeAt(i);
                                                                            presentageList.removeAt(i);
                                                                          }
                                                                        });
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width:
                                                                textFieldCount >
                                                                        1
                                                                    ? 250
                                                                    : 300,
                                                            child:
                                                                TextFormField(
                                                              // Additional Text Form Field
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Presentage ${i + 1}',
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                fillColor: Color
                                                                    .fromARGB(
                                                                        141,
                                                                        219,
                                                                        219,
                                                                        219),
                                                                filled: true,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                // Update the corresponding element in the list
                                                                if (i <
                                                                    presentageList
                                                                        .length) {
                                                                  setState(() {
                                                                    presentageList[
                                                                            i] =
                                                                        value;
                                                                    value = "";
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    presentageList
                                                                        .add(
                                                                            value);
                                                                    value = "";
                                                                  });
                                                                }
                                                              },
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Enter Presentage';
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        textFieldCount++; // Increment text field count on icon tap
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 200,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 3, 98, 177),
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            size: 30,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            'Add',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Card(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Checkbox(
                                                          value: checkBox1,
                                                          onChanged:
                                                              (newvalue) {
                                                            toggleCheckBox1(
                                                                newvalue!);
                                                            sts = 'start date';
                                                          },
                                                          visualDensity:
                                                              VisualDensity
                                                                  .adaptivePlatformDensity,
                                                        ),
                                                        Text(
                                                          'Start Date',
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                        SizedBox(width: 40),
                                                        Checkbox(
                                                          value: checkBox2,
                                                          onChanged: (value) {
                                                            toggleCheckBox2(
                                                                value!);
                                                            sts = 'finish date';
                                                          },
                                                          visualDensity:
                                                              VisualDensity
                                                                  .adaptivePlatformDensity,
                                                        ),
                                                        Text(
                                                          'Finish Date',
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  alertsdul
                                                      ? Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              'Select any Option ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(''),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (_shedulekey
                                                            .currentState!
                                                            .validate()) {
                                                          if (sts.isEmpty) {
                                                            setState(() {
                                                              alertsdul = true;
                                                              // Clear the text fields
                                                              sheduleList
                                                                  .clear();
                                                              presentageList
                                                                  .clear();
                                                              // Reset textFieldCount
                                                              textFieldCount =
                                                                  0;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              alertsdul = false;
                                                              shedulefun();
                                                              // Clear the text fields
                                                              sheduleList
                                                                  .clear();
                                                              presentageList
                                                                  .clear();
                                                              // Reset textFieldCount
                                                              textFieldCount =
                                                                  0;
                                                            });
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width: 150,
                                                        child: Card(
                                                          color: Color.fromARGB(
                                                              255, 3, 98, 177),
                                                          elevation: 10,
                                                          shadowColor:
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Submit',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    letterSpacing:
                                                                        1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Card(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Shedule Title :',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        81,
                                                                        146)),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 80,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  _shetitle,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  chktitle =
                                                                      value;
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15),
                                                                labelText:
                                                                    'Enter Title',
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Remark :',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        81,
                                                                        146)),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 80,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  _shermrk,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  chkrmrk =
                                                                      value;
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            15),
                                                                labelText:
                                                                    fetchrmrkdata[
                                                                        'shed_rmk'],
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                          Center(
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                if (_shetitle
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    _shermrk
                                                                        .text
                                                                        .isNotEmpty) {
                                                                  setState(() {
                                                                    titl_rmk(
                                                                        cli_id
                                                                            .toString(),
                                                                        _shetitle
                                                                            .text,
                                                                        _shermrk
                                                                            .text,
                                                                        'Shedule-Insert-upt');
                                                                  });
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context
                                                                              as BuildContext)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        width: double
                                                                            .infinity,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            198,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Please Enter Title & Remarks',
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        3,
                                                                        98,
                                                                        177), // Set the background color here
                                                              ),
                                                              child: Text(
                                                                  'Change',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            // Container(
                            //     height: 30,
                            //     width: MediaQuery.of(context).size.width,
                            //     color: Color.fromARGB(255, 31, 70, 85),
                            //     child: Center(
                            //         child: Text(
                            //       'Content Title:',
                            //       style: TextStyle(
                            //           letterSpacing: 4,
                            //           wordSpacing: 5,
                            //           color: Colors.white),
                            //     ))),
                            // Card(
                            //   elevation: 10,
                            //   child: Container(
                            //     height: 60,
                            //     width: MediaQuery.of(context).size.width,
                            //     padding:
                            //         const EdgeInsets.symmetric(vertical: 5),
                            //     decoration: BoxDecoration(
                            //       color: Color.fromARGB(255, 255, 255, 255),
                            //       borderRadius: BorderRadius.circular(0),
                            //       border: Border.all(
                            //         color: Colors.grey,
                            //         width: 1,
                            //       ),
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(left: 30.0),
                            //       child: DropdownButton<String>(
                            //         value: title,
                            //         onChanged: (String? newValue) async {
                            //           if (newValue != null) {
                            //             setState(() {
                            //               title = newValue;
                            //             });
                            //           }
                            //         },
                            //         items: [
                            //           DropdownMenuItem<String>(
                            //             value: 'All',
                            //             child: Container(
                            //               width: 150,
                            //               child: Text(
                            //                 'Select Title',
                            //                 style: TextStyle(
                            //                   fontSize: 16,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Colors
                            //                       .grey, // You can set a different color to indicate it's disabled
                            //                 ),
                            //                 overflow: TextOverflow.ellipsis,
                            //               ),
                            //             ),
                            //             onTap:
                            //                 null, // Set onTap to null to make it not clickable
                            //           ),
                            //           ...Set<String>.from(fetchclidata
                            //                   .map((data) => data['titl']))
                            //               .where((value) => value.isNotEmpty)
                            //               .map((value) =>
                            //                   DropdownMenuItem<String>(
                            //                     value: value,
                            //                     child: Container(
                            //                       width:
                            //                           250, // Set the maximum width you prefer
                            //                       child: Text(
                            //                         value,
                            //                         style: TextStyle(
                            //                           fontSize: 16,
                            //                           fontWeight: title == value
                            //                               ? FontWeight.bold
                            //                               : FontWeight.normal,
                            //                         ),
                            //                         overflow:
                            //                             TextOverflow.ellipsis,
                            //                       ),
                            //                     ),
                            //                   ))
                            //               .toList(),
                            //         ],
                            //         underline: Container(),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (Set<MaterialState> states) {
                                        // For the default or other states
                                        return Color.fromARGB(255, 31, 70,
                                            85); // Set your desired color
                                      }),
                                      headingTextStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight
                                            .bold, // Set your desired font weight
                                        color: Colors
                                            .white, // Set your desired text color
                                      ),
                                      columnSpacing:
                                          30, // Adjust the spacing between columns as needed
                                      dataRowHeight: 60,
                                      columns: <DataColumn>[
                                        DataColumn(
                                          label: Text('SL.NO.',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('Start Date',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('End Date',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('Content',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('Presentage',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('Edit',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        DataColumn(
                                          label: Text('Status',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        // DataColumn(
                                        //   label: Text('Time',
                                        //       style: TextStyle(fontSize: 16)),
                                        // ),

                                        whoIs == 'STAFF'
                                            ? DataColumn(label: Text(''))
                                            : DataColumn(
                                                label: Text('Delete',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                      ],
                                      rows: fetchclidata
                                          .asMap()
                                          .entries
                                          .map<DataRow>((entry) {
                                        int index = entry.key;
                                        dynamic data = entry.value;
                                        int currentSerialNumber = index + 1;
                                        Color rowColor = index.isEven
                                            ? Color.fromARGB(36, 158, 158, 158)
                                            : Colors.white;
                                        return DataRow(
                                          color: MaterialStateColor.resolveWith(
                                              (Set<MaterialState> states) {
                                            return rowColor; // Set the row color
                                          }),
                                          cells: [
                                            DataCell(Text(
                                                currentSerialNumber.toString(),
                                                style:
                                                    TextStyle(fontSize: 18))),
                                            DataCell(Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        data['st_dt']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 18)),
                                                    IconButton(
                                                        onPressed: () {
                                                          _chngselectDate1(
                                                              context,
                                                              'Start-Dt-Change',
                                                              data['us_nm']
                                                                  .toString(),
                                                              data['id']
                                                                  .toString());
                                                        },
                                                        icon: Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.blue,
                                                        ))
                                                  ],
                                                ))),
                                            DataCell(Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        data['ed_dt']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 18)),
                                                    IconButton(
                                                        onPressed: () {
                                                          _chngselectDate2(
                                                              context,
                                                              'End-Dt-Change',
                                                              data['us_nm']
                                                                  .toString(),
                                                              data['id']
                                                                  .toString());
                                                        },
                                                        icon: Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.blue,
                                                        ))
                                                  ],
                                                ))),
                                            DataCell(Text(
                                                data['content'].toString(),
                                                style:
                                                    TextStyle(fontSize: 18))),
                                            DataCell(
                                              editingIndex == index
                                                  ? Container(
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                        ),
                                                        child: TextFormField(
                                                          controller: _prntge,

                                                          // initialValue: data['name'].toString(),
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            labelText: data[
                                                                    'presentage']
                                                                .toString(),
                                                            // fillColor: Colors.grey[100],
                                                            // filled: true
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      data['presentage']
                                                              .isNotEmpty
                                                          ? data['presentage']
                                                                  .toString() +
                                                              '%'
                                                          : '0%',
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                            ),
                                            DataCell(
                                              editingIndex == index
                                                  ? ElevatedButton(
                                                      onPressed: () {
                                                        if (_prntge
                                                            .text.isNotEmpty) {
                                                          setState(() {
                                                            editingIndex = -1;
                                                            updt_shedule_prntge(
                                                              data['us_nm']
                                                                  .toString(),
                                                              data['id']
                                                                  .toString(),
                                                              _prntge.text,
                                                            );
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context
                                                                      as BuildContext)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content:
                                                                  Container(
                                                                height: 40,
                                                                width: double
                                                                    .infinity,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        198,
                                                                        0,
                                                                        0),
                                                                child: Center(
                                                                  child: Text(
                                                                    'Enter New Values',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors
                                                            .green, // Set the background color here
                                                      ),
                                                      child: Text('Submit',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .white)),
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          editingIndex = index;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                            ),
                                            DataCell(
                                              Container(
                                                height: 50,
                                                width: 150,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      DropdownButton<String>(
                                                        value: dropdownValues[
                                                                index] ??
                                                            'default_value',
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            dropdownValues[
                                                                    index] =
                                                                newValue ??
                                                                    'default_value';
                                                            String? selevalue =
                                                                newValue;
                                                            updatePossition(
                                                                data['us_nm']
                                                                    .toString(),
                                                                data['id']
                                                                    .toString(),
                                                                selevalue,
                                                                plan_title);
                                                          });
                                                        },
                                                        items: [
                                                          DropdownMenuItem<
                                                              String>(
                                                            value:
                                                                'default_value',
                                                            child: Text(
                                                                data['sts']),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'Start Date',
                                                            child: Text(
                                                                'Start Date'),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value:
                                                                'Finish Date',
                                                            child: Text(
                                                                'Finish Date'),
                                                          ),
                                                          // Other DropdownMenuItem values here
                                                        ],
                                                        underline: Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // DataCell(Text(DateFormat(
                                            //         'dd-MM-yyyy   HH:mm:ss')
                                            //     .format(DateTime.parse(
                                            //         data['time'].toString())))),

                                            whoIs == 'STAFF'
                                                ? DataCell(Text(''))
                                                : DataCell(IconButton(
                                                    onPressed: () {
                                                      deletethat(
                                                        'SHEDULE-LIST-DEL',
                                                        data['id'].toString(),
                                                        data['us_nm']
                                                            .toString(),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      size: 30,
                                                      color: Colors.red,
                                                    ))),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  fetchclidata.isNotEmpty
                                      ? Container()
                                      : Container(
                                          child: Column(
                                            children: [
                                              Text('No data found'),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )

                ////////////////////////////////////////////////////////////////////////////////////////////////////
                ///
                ///
                ///
                : plan_title == 'Check List'
                    ? Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _checklistkey,
                            child: Column(
                              children: [
                                Container(
                                    color: const Color.fromARGB(
                                        255, 226, 226, 226),
                                    height: 50,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                          '*Note : Add your CheckList $cli_nm'),
                                    )),
                                whoIs == 'STAFF'
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 30),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CheckList Title :',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 0, 81, 146)),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              height: 80,
                                              child: TextFormField(
                                                controller: _chktitle,
                                                onChanged: (value) {
                                                  setState(() {
                                                    chktitle = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Enter Title';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 15),
                                                  labelText: 'Type Title',
                                                  hintStyle: TextStyle(
                                                      color: Colors.black),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      for (int i = 0;
                                                          i < textFieldCount;
                                                          i++)
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 10),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width:
                                                                    textFieldCount >
                                                                            1
                                                                        ? 250
                                                                        : 300,
                                                                child:
                                                                    TextFormField(
                                                                  // Additional Text Form Field
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Content ${i + 1}',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    fillColor: Color
                                                                        .fromARGB(
                                                                            141,
                                                                            219,
                                                                            217,
                                                                            217),
                                                                    filled:
                                                                        true,
                                                                  ),
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the corresponding element in the list
                                                                    if (i <
                                                                        contentList
                                                                            .length) {
                                                                      setState(
                                                                          () {
                                                                        contentList[i] =
                                                                            value;
                                                                        value =
                                                                            "";
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        contentList
                                                                            .add(value);
                                                                        value =
                                                                            "";
                                                                      });
                                                                    }
                                                                  },
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Type Content';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ),
                                                              textFieldCount > 1
                                                                  ? IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textFieldCount--;
                                                                          if (i <
                                                                              contentList.length) {
                                                                            contentList.removeAt(i);
                                                                          }
                                                                        });
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          ),
                                                        ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            textFieldCount++; // Increment text field count on icon tap
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                3, 98, 177),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.add,
                                                                size: 30,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                'Add',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Center(
                                                        child: InkWell(
                                                          onTap: () {
                                                            if (_checklistkey
                                                                .currentState!
                                                                .validate()) {
                                                              setState(() {
                                                                checkfun();

                                                                contentList
                                                                    .clear();

                                                                textFieldCount =
                                                                    0;
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: 150,
                                                            child: Card(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      3,
                                                                      98,
                                                                      177),
                                                              elevation: 10,
                                                              shadowColor:
                                                                  Colors.black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      'Submit',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        letterSpacing:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Remark :',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            0,
                                                                            81,
                                                                            146)),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              SizedBox(
                                                                height: 80,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _chkrmrk,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      chkrmrk =
                                                                          value;
                                                                    });
                                                                  },
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            15),
                                                                    labelText:
                                                                        fetchrmrkdata[
                                                                            'chk_rmk'],
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              Center(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (chkrmrk
                                                                        .isNotEmpty) {
                                                                      setState(
                                                                          () {
                                                                        titl_rmk(
                                                                            cli_id.toString(),
                                                                            _chktitle.text,
                                                                            _chkrmrk.text,
                                                                            'ChkList-Insert-upt');
                                                                      });
                                                                    } else {
                                                                      ScaffoldMessenger.of(context
                                                                              as BuildContext)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Container(
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                double.infinity,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                198,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                'Please Enter Remarks',
                                                                                style: TextStyle(color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    primary: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            3,
                                                                            98,
                                                                            177), // Set the background color here
                                                                  ),
                                                                  child: Text(
                                                                      'Change',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width,
                                    color: Color.fromARGB(255, 31, 70, 85),
                                    child: Center(
                                        child: Text(
                                      'Content Title:',
                                      style: TextStyle(
                                          letterSpacing: 4,
                                          wordSpacing: 5,
                                          color: Colors.white),
                                    ))),
                                Card(
                                  elevation: 10,
                                  child: Container(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 30.0),
                                      child: DropdownButton<String>(
                                        value: title,
                                        onChanged: (String? newValue) async {
                                          if (newValue != null) {
                                            setState(() {
                                              title = newValue;
                                            });
                                          }
                                        },
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'All',
                                            child: Container(
                                              width: 150,
                                              child: Text(
                                                'Select Title',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .grey, // You can set a different color to indicate it's disabled
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            onTap:
                                                null, // Set onTap to null to make it not clickable
                                          ),
                                          ...Set<String>.from(fetchclidata
                                                  .map((data) => data['titl']))
                                              .where(
                                                  (value) => value.isNotEmpty)
                                              .map((value) =>
                                                  DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Container(
                                                      width:
                                                          250, // Set the maximum width you prefer
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: title ==
                                                                  value
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ],
                                        underline: Container(),
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingRowColor:
                                              MaterialStateColor.resolveWith(
                                                  (Set<MaterialState> states) {
                                            // For the default or other states
                                            return Color.fromARGB(255, 31, 70,
                                                85); // Set your desired color
                                          }),
                                          headingTextStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight
                                                .bold, // Set your desired font weight
                                            color: Colors
                                                .white, // Set your desired text color
                                          ),
                                          columnSpacing:
                                              30, // Adjust the spacing between columns as needed
                                          dataRowHeight: 60,
                                          columns: <DataColumn>[
                                            DataColumn(
                                              label: Text('SL.NO.',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                            // DataColumn(
                                            //   label: Text('Start Date', style: TextStyle(fontSize: 16)),
                                            // ),
                                            // DataColumn(
                                            //   label: Text('End Date', style: TextStyle(fontSize: 16)),
                                            // ),
                                            DataColumn(
                                              label: Text('Content',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                            DataColumn(
                                              label: Text('Status',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),

                                            // DataColumn(
                                            //   label: Text('Time',
                                            //       style:
                                            //           TextStyle(fontSize: 16)),
                                            // ),
                                            whoIs == 'STAFF'
                                                ? DataColumn(label: Text(''))
                                                : DataColumn(
                                                    label: Text('Delete',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                          ],
                                          rows: fetchclidata
                                              .where((data) =>
                                                  title == 'All' ||
                                                  data['titl'] == title)
                                              .toList()
                                              .asMap()
                                              .entries
                                              .map<DataRow>((entry) {
                                            int index = entry.key;
                                            dynamic data = entry.value;
                                            int currentSerialNumber = index + 1;
                                            Color rowColor = index.isEven
                                                ? Color.fromARGB(
                                                    36, 158, 158, 158)
                                                : Colors.white;
                                            return DataRow(
                                              color: MaterialStateColor
                                                  .resolveWith(
                                                      (Set<MaterialState>
                                                          states) {
                                                return rowColor; // Set the row color
                                              }),
                                              cells: [
                                                DataCell(Text(
                                                    currentSerialNumber
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 18))),
                                                // DataCell(Text(data['st_dt'].toString(),style: TextStyle(fontSize: 18))),
                                                // DataCell(Text(data['ed_dt'].toString(),style: TextStyle(fontSize: 18))),
                                                DataCell(Text(
                                                    data['content'].toString(),
                                                    style: TextStyle(
                                                        fontSize: 18))),
                                                DataCell(
                                                  Container(
                                                    height: 50,
                                                    width: 150,
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          DropdownButton<
                                                              String>(
                                                            value: dropdownValues[
                                                                    index] ??
                                                                'default_value',
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                dropdownValues[
                                                                        index] =
                                                                    newValue ??
                                                                        'default_value';
                                                                String?
                                                                    selevalue =
                                                                    newValue;
                                                                updatePossition(
                                                                    data['us_nm']
                                                                        .toString(),
                                                                    data['id']
                                                                        .toString(),
                                                                    selevalue,
                                                                    plan_title);
                                                              });
                                                            },
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value:
                                                                    'default_value',
                                                                child: Text(
                                                                    data[
                                                                        'sts']),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: 'yes',
                                                                child:
                                                                    Text('yes'),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: 'no',
                                                                child:
                                                                    Text('no'),
                                                              ),
                                                              // Other DropdownMenuItem values here
                                                            ],
                                                            underline:
                                                                Container(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // DataCell(Text(DateFormat(
                                                //         'dd-MM-yyyy   HH:mm:ss')
                                                //     .format(DateTime.parse(
                                                //         data['time']
                                                //             .toString())))),
                                                whoIs == 'STAFF'
                                                    ? DataCell(Text(''))
                                                    : DataCell(IconButton(
                                                        onPressed: () {
                                                          deletethat(
                                                            'CHECK-LIST-DEL',
                                                            data['id']
                                                                .toString(),
                                                            data['us_nm']
                                                                .toString(),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.delete,
                                                          size: 30,
                                                          color: Colors.red,
                                                        ))),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      fetchclidata.isNotEmpty
                                          ? Container()
                                          : Container(
                                              child: Column(
                                                children: [
                                                  Text('No data found'),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container());
  }
}
