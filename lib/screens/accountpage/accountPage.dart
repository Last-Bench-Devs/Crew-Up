import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

List contactsall = [];

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final flexController = TextEditingController();
  final nameController = TextEditingController();
  bool showPassword = false;
  var usernumber = "";
  bool showLoading = false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    var _auth = FirebaseAuth.instance;
    var _user = await _auth.currentUser!;
    setState(() {
      usernumber = _user.phoneNumber
          .toString()
          .substring(_user.phoneNumber.toString().length - 10);
    });
    print(_user);
    getUserProfile();
  }

  void getUserProfile() async {
    final response = await http.post(
      Uri.parse(
          'https://Projext-x-agora-dynamic-key.lastbenchbench.repl.co/getUserList'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, List>{
        'contacts': [
          [usernumber]
        ]
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        contactsall = jsonDecode(response.body);
        print(contactsall);
      });
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.statusCode);
    }
  }

  Future createUser() async {
    final response = await http.post(
      Uri.parse(
          'https://Projext-x-agora-dynamic-key.lastbenchbench.repl.co/createUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': nameController.text,
        'profilePic':
            'https://robohash.org/${contactsall[0]['phoneNumber']}?set=set1&bgset=bg2&size=200x200',
        'phoneNumber': contactsall[0]['phoneNumber'],
        'flex': flexController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        contactsall = [];
      });

      getUserProfile();
    } else {
      setState(() {
        contactsall = [];
      });
      getCurrentUser();
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return contactsall.isNotEmpty
        ? Scaffold(
            body: Container(
              padding: EdgeInsets.only(left: 16, top: 25, right: 16),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 10))
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      contactsall[0]['profilePic'],
                                    ))),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  BottomCard(context);
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: Colors.purple[800],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        contactsall[0]['name'],
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {},
                          child: Text(contactsall[0]["phoneNumber"],
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.black)),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(contactsall[0]['flex']),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  // Widget buildTextField(
  //     String labelText, String placeholder, bool isPasswordTextField) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextField(
  //       obscureText: isPasswordTextField ? showPassword : false,
  //       decoration: InputDecoration(
  //           suffixIcon: isPasswordTextField
  //               ? IconButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       showPassword = !showPassword;
  //                     });
  //                   },
  //                   icon: Icon(
  //                     Icons.remove_red_eye,
  //                     color: Colors.grey,
  //                   ),
  //                 )
  //               : null,
  //           contentPadding: EdgeInsets.only(bottom: 3),
  //           labelText: labelText,
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           hintText: placeholder,
  //           hintStyle: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           )),
  //     ),
  //   );
  // }

  void BottomCard(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 35.0, right: 20, left: 20),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: "Name",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 35.0, left: 20, right: 20),
                child: TextField(
                  controller: flexController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Flex',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: "Flex",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ),
              ),
              RaisedButton(
                color: Color(0xFF122543),
                child: Text(
                  "UPDATE",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  if (nameController.text.length == 0 ||
                      flexController.text.length == 0) {
                    Fluttertoast.showToast(
                        msg: "Name and Flex cannot be empty",
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  if (nameController.text.length >= 50 ||
                      flexController.text.length >= 50) {
                    Fluttertoast.showToast(
                        msg: "Name and Flex must have less than 50 characters",
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }

                  createUser();
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                height: 400,
              )
            ],
          )),
    );
  }
}
