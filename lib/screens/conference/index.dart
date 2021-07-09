import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:us/screens/chat-ui/constant.dart';
import 'package:us/screens/chat-ui/style.dart';

import '../call/call.dart';
import 'package:http/http.dart' as http;

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(

    //   body: Center(
    //     child: Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 20),
    //       height: 400,
    //       child: Column(
    //         children: <Widget>[
    //           Row(
    //             children: <Widget>[
    //               Expanded(
    //                   child: TextField(
    //                 controller: _channelController,
    //                 decoration: InputDecoration(
    //                   errorText:
    //                       _validateError ? 'Channel name is mandatory' : null,
    //                   border: UnderlineInputBorder(
    //                     borderSide: BorderSide(width: 1),
    //                   ),
    //                   hintText: 'Channel name',
    //                 ),
    //               ))
    //             ],
    //           ),
    //           Column(
    //             children: [
    //               ListTile(
    //                 title: Text(ClientRole.Broadcaster.toString()),
    //                 leading: Radio(
    //                   value: ClientRole.Broadcaster,
    //                   groupValue: _role,
    //                   onChanged: (ClientRole? value) {
    //                     setState(() {
    //                       _role = value;
    //                     });
    //                   },
    //                 ),
    //               ),
    //               ListTile(
    //                 title: Text(ClientRole.Audience.toString()),
    //                 leading: Radio(
    //                   value: ClientRole.Audience,
    //                   groupValue: _role,
    //                   onChanged: (ClientRole? value) {
    //                     setState(() {
    //                       _role = value;
    //                     });
    //                   },
    //                 ),
    //               )
    //             ],
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.symmetric(vertical: 20),
    //             child: Row(
    //               children: <Widget>[
    //                 Expanded(
    //                   child: ElevatedButton(
    //                     onPressed: onJoin,
    //                     child: Text('Join'),
    //                     style: ButtonStyle(
    //                         backgroundColor:
    //                             MaterialStateProperty.all(Colors.blueAccent),
    //                         foregroundColor:
    //                             MaterialStateProperty.all(Colors.white)),
    //                   ),
    //                 ),
    //                 // Expanded(
    //                 //   child: RaisedButton(
    //                 //     onPressed: onJoin,
    //                 //     child: Text('Join'),
    //                 //     color: Colors.blueAccent,
    //                 //     textColor: Colors.white,
    //                 //   ),
    //                 // )
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: Color(0xff5b61b9),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 30, left: 40),
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryText(
                  text: 'CREW-UP',
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(height: 25),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatarList.length,
                    itemBuilder: (context, index) => Avatar(
                        avatarUrl: avatarList[index]['avatar'].toString()),
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
                height: 400,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: _channelController,
                          decoration: InputDecoration(
                            errorText: _validateError
                                ? 'Channel name is mandatory'
                                : null,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: 'Channel name',
                          ),
                        ))
                      ],
                    ),
                    Column(
                      children: [
                        ListTile(
                          title: Text(ClientRole.Broadcaster.toString()),
                          leading: Radio(
                            value: ClientRole.Broadcaster,
                            groupValue: _role,
                            onChanged: (ClientRole? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(ClientRole.Audience.toString()),
                          leading: Radio(
                            value: ClientRole.Audience,
                            groupValue: _role,
                            onChanged: (ClientRole? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onJoin,
                              child: Text('Join'),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueAccent),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),
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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onCreate,
                              child: Text('CREATE'),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueAccent),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),
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
                    )
                  ],
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
        "https://project-x-agora.herokuapp.com/rtcToken?channelName=$channel"));
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
    var response = await http
        .get(Uri.parse("https://project-x-agora.herokuapp.com/generateCode"));
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
          builder: (context) => CallPage(
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
