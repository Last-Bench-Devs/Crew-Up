import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:us/screens/chat-ui/style.dart';
import 'package:us/screens/conference/index.dart';
import 'package:http/http.dart' as http;
import 'package:us/screens/home-main/main_page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fluttertoast/fluttertoast.dart';

var client = http.Client();
// import 'package:http/http.dart' as http;

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  bool showLoading = false;

  //user id
  late String userUid;

  //user id.....

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
            'https://robohash.org/${phoneController.text}?set=set1&bgset=bg2&size=200x200',
        'phoneNumber': phoneController.text,
        'flex': 'Life is full of flex'
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        showLoading = false;
      });
      userMobileStore();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
      var res = jsonEncode(response.body);
      print(res.substring(11, res.length - 4));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.statusCode);
    }
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      final User? user = _auth.currentUser;
      final uid = user!.uid;

      setState(() {
        // showLoading = false;
        userUid = uid;
      });

      if (authCredential.user != null) {
        createUser();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  getMobileFormWidget(context) {
    return Scaffold(
      backgroundColor: Color(0xFF122543),
      body: Column(
        children: [
          Spacer(),
          Image.asset('lib/assets/font-logo.png'),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              // padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(5),
              //     border: Border.all(color: Colors.purple)),
              child: Column(
                children: [
                  PrimaryText(
                    text: 'CREW UP',
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  PrimaryText(
                    text: 'Connect with your friends',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: "Phone Number",
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      // hintText: "Phone Number",
                      // hintStyle: TextStyle(
                      //   color: Colors.white,
                      // )
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      // hintStyle: TextStyle(
                      //   color: Colors.white,
                      // )
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          FlatButton(
            onPressed: () async {
              if (phoneController.text.length != 10 ||
                  nameController.text.length == 0) {
                Fluttertoast.showToast(
                    msg: "Invalid Name or Phone Number",
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                return;
              }
              setState(() {
                showLoading = true;
              });

              await _auth.verifyPhoneNumber(
                phoneNumber: '+91' + phoneController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  //signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (verificationFailed) async {
                  setState(() {
                    showLoading = false;
                  });
                  _scaffoldKey.currentState!.showSnackBar(SnackBar(
                      content: Text(verificationFailed.message.toString())));
                },
                codeSent: (verificationId, resendingToken) async {
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationId = verificationId;
                  });
                },
                codeAutoRetrievalTimeout: (verificationId) async {},
              );
            },
            minWidth: 300.0,
            child: Text(
              "GET OTP",
              style: TextStyle(color: Color(0xFF122543)),
            ),
            color: Color(0xFFf7b5b9),
          ),
          Spacer(),
        ],
      ),
    );
  }

  getOtpFormWidget(context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFF122543)),
      child: Column(
        children: [
          Spacer(),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('lib/assets/font-logo.png')),
          SizedBox(
            height: 5,
          ),
          Container(
            child: Column(
              children: [
                PrimaryText(
                  text: 'CREW UP',
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(
                  height: 10,
                ),
                PrimaryText(
                  text: 'Connect with your friends',
                  fontSize: 16,
                  color: Colors.white70,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    // padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(5),
                    //     border: Border.all(color: Colors.purple)),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        labelText: "Enter OTP",
                        labelStyle: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        // hintStyle: TextStyle(
                        //   color: Colors.white,
                        // )
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          FlatButton(
            minWidth: 300.0,
            onPressed: () async {
              PhoneAuthCredential phoneAuthCredential =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text);

              signInWithPhoneAuthCredential(phoneAuthCredential);
            },
            //"                                       VERIFY                                      "
            child: Text(
              "VERIFY",
              style: TextStyle(color: Color(0xFF122543)),
            ),
            color: Color(0xFFf7b5b9),
          ),
          Spacer(),
        ],
      ),
    );
  }

  RestartAppWidger(context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.asset('lib/assets/splash1.png')),
          Spacer(),
          SizedBox(
            height: 16,
          ),
          FlatButton(
            onPressed: () async {
              exit(0);
            },
            child: Text(
                "                             CLOSE APP                                    "),
            color: Colors.purple[800],
            textColor: Colors.white,
          ),
          Spacer(),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            child: showLoading
                ? Container(
                    decoration: new BoxDecoration(color: Color(0xFF122543)),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFf7b5b9),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            PrimaryText(
                              text: 'Verifying...',
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ]),
                    ),
                  )
                : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget(context)));
  }

  Future userMobileStore() async {
    final phone = phoneController.text;

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userUid)
        .set({'phone': phone});
  }
}
