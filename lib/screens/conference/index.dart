import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:us/call-notification/callNoti.dart';
import 'package:us/screens/call/sharecall.dart';
import 'package:us/screens/chat-ui/constant.dart';
import 'package:us/screens/chat-ui/style.dart';
import 'package:us/screens/conference/cam_preview/CamPre.dart';

import '../call/call.dart';
import 'package:http/http.dart' as http;

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  List contactsall = [];

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole? _role = ClientRole.Broadcaster;

  late Map lastMsgs = {};
  late FirebaseAuth _auth;
  AgoraRtmClient? _client;
  late User _user;
  var usernumber = "";
  var box;
  bool isLoading = true;

  @override
  void initState() {
    // _createClient(context);
    getContacts();
    super.initState();
  }

  // void _createClient(context) async {
  //   print("create client called");
  //   _client =
  //       await AgoraRtmClient.createInstance("8b3f1a86336a476ca0bec49aa0061c51");

  //   _login(context);
  //   _client?.onMessageReceived =
  //       (AgoraRtmMessage message, String peerId) async {
  //     print("Private Message from " + peerId + ": " + message.text);
  //     var box = await Hive.box("messages");
  //     List msgList = await box.get(peerId);
  //     if (msgList == null) {
  //       await box.put(peerId, []);
  //     }
  //     msgList = await box.get(peerId);
  //     var dt = DateTime.now().toString();
  //     var date = dt.split(" ")[0];
  //     var time = dt.split(" ")[1];
  //     time = time.substring(0, time.indexOf('.'));
  //     var dateTime = date + "\n" + time;
  //     print(dateTime);
  //     //2021-07-12 16:53:10.200373
  //     if (message.text.contains(
  //         "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE")) {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => CallNoti(fullstring: message.text)));
  //     } else {
  //       msgList.add({
  //         'from': 'reciver',
  //         'message': message.text,
  //         'time': dateTime,
  //         'datetime': dt
  //       });
  //     }

  //     await box.put(peerId, msgList);
  //     setState(() {
  //       if (!message.text.contains(
  //           "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE")) {
  //         lastMsgs[peerId]["message"] = message.text;
  //         lastMsgs[peerId]["time"] = dateTime;
  //         var ind;
  //         for (var i = 0; i < contactsall.length; i++) {
  //           if (contactsall[i]["phoneNumber"].toString() == peerId) {
  //             ind = i;
  //             break;
  //           }
  //         }
  //         contactsall[ind]["time"] = dateTime;
  //       }
  //       //var dateTime = DateTime.parse("dateTimeString");
  //       //someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));

  //       contactsall.sort((a, b) => (b["time"]).compareTo(a["time"]));
  //       print(contactsall);
  //     });
  //     /* Update contactList with recent message at first */
  //   };

  //   _client?.onConnectionStateChanged = (int state, int reason) {
  //     print('Connection state changed: ' +
  //         state.toString() +
  //         ', reason: ' +
  //         reason.toString());
  //     if (state == 5) {
  //       _client?.logout();
  //       print('Logout.');
  //     }
  //   };
  // }

  // void _login(BuildContext context) async {
  //   //print(jsonDecode(_user.toString()));
  //   String userId = usernumber;
  //   if (userId.isEmpty) {
  //     print('Please input your user id to login.');
  //     return;
  //   }

  //   try {
  //     await _client?.login(null, userId);
  //     print('Login success: ' + userId);
  //     // _joinChannel(context);
  //   } catch (errorCode) {
  //     print('Login error: ' + errorCode.toString());
  //   }
  // }

  void getContacts() async {
    var box = await Hive.box("contactsBox");
    contactsall = await box.get("contactsall");
    setState(() {});
    print("Contact LIST PRINTING");
    print(contactsall);
  }

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF122543),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 30, left: 40),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  text: 'Join or create a conference call',
                  fontSize: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 25),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: contactsall.length,
                    itemBuilder: (context, index) => Avatar(
                        avatarUrl:
                            "https://robohash.org/${contactsall[index]['phoneNumber']}?set=set1&bgset=bg2&size=200x200"),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 0, left: 20, right: 20),
            height: MediaQuery.of(context).size.height - 260,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(width: 200, height: 340, child: CamPre()),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                            controller: _channelController,
                            decoration: InputDecoration(
                              errorText: _validateError
                                  ? 'Conference code is mandatory'
                                  : null,
                              hintText: 'Enter the conference code',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff5b61b9), width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff5b61b9), width: 3.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                            ),
                          ))
                        ],
                      ),
                      // Column(
                      //   children: [
                      //     ListTile(
                      //       title: Text(ClientRole.Broadcaster.toString()),
                      //       leading: Radio(
                      //         value: ClientRole.Broadcaster,
                      //         groupValue: _role,
                      //         onChanged: (ClientRole? value) {
                      //           setState(() {
                      //             _role = value;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     ListTile(
                      //       title: Text(ClientRole.Audience.toString()),
                      //       leading: Radio(
                      //         value: ClientRole.Audience,
                      //         groupValue: _role,
                      //         onChanged: (ClientRole? value) {
                      //           setState(() {
                      //             _role = value;
                      //           });
                      //         },
                      //       ),
                      //     )
                      //   ],
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onJoin,
                                child: Text('Join'),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFF122543)),
                                    foregroundColor: MaterialStateProperty.all(
                                        Colors.white)),
                              ),
                            ),
                            // Expanded(
                            //   child: RaisedButton(
                            //     onPressed: onJoin,
                            //     child: Text('Join'),
                            //     color: Colors.blueAccent,
                            //     textColor: Colors.white,
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 40.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onCreate,
                                child: Text('Create'),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFF122543)),
                                    foregroundColor: MaterialStateProperty.all(
                                        Colors.white)),
                              ),
                            ),
                            // Expanded(
                            //   child: RaisedButton(
                            //     onPressed: onJoin,
                            //     child: Text('Join'),
                            //     color: Colors.blueAccent,
                            //     textColor: Colors.white,
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  fetchtoken(var channel) async {
    var response = await http.get(Uri.parse(
        "https://Projext-x-agora-dynamic-key.lastbenchbench.repl.co/rtcToken?channelName=$channel"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['key'];
      // ignore: dead_code
      print(data['key']);
    }
    //http.get(Uri.parse("url"));
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      var key = await fetchtoken(_channelController.text);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
              channelName: _channelController.text,
              tokenid: key,
              role: _role,
              code: _channelController.text),
        ),
      );
    }
  }

  onCreate() async {
    var response = await http.get(Uri.parse(
        "https://Projext-x-agora-dynamic-key.lastbenchbench.repl.co/generateCode"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var code = data['code'].toString();
      // ignore: dead_code
      print(data['code']);
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      var key = await fetchtoken(code);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShareCall(
              channelName: code, tokenid: key, role: _role, code: code),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late FirebaseAuth _auth;

//   late User _user;

//   bool isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _auth = FirebaseAuth.instance;
//     _user = _auth.currentUser!;
//     isLoading = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           )
//         : Scaffold(
//             body: Center(
//               child: Text(_user.toString()),
//             ),
//           );
//   }
// }
