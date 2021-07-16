import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contact/contacts.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:us/call-notification/callNoti.dart';
import 'package:us/utils/settings.dart';
import './chat.dart';
import './constant.dart';
import './style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  
  


  List contactsall = [];
  late Map lastMsgs = {};
  late FirebaseAuth _auth;
  AgoraRtmClient? _client;
  late User _user;
  var usernumber = "";
  var box;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getcontacts();
    // _auth = FirebaseAuth.instance;
    // _user = _auth.currentUser!;
    // print(_user);
    getCurrentUser();
    getBox();
    _createClient(context);
    isLoading = false;
    
    

    
  }

  

  void getBox() async {
    // ignore: await_only_futures
    box = await Hive.box("messages");
  }

  void getLastMessages() async {
    for (var i = 0; i < contactsall.length; i++) {
      var currContact = contactsall[i]["phoneNumber"].toString();
      var msg = await box.get(currContact);
      if (msg == null || msg.length == 0) {
        lastMsgs[currContact] = {
          "message": "No Messages",
          "time": "",
        };
      } else {
        lastMsgs[currContact] = {
          "message": msg[msg.length - 1]["message"],
          "time": msg[msg.length - 1]["time"],
        };
      }
    }
    for (var i = 0; i < contactsall.length; i++) {
      contactsall[i]["time"] = lastMsgs[contactsall[i]["phoneNumber"]]["time"];
    }
    //var dateTime = DateTime.parse("dateTimeString");
    //someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));
    contactsall.sort((a, b) => (b["time"]).compareTo(a["time"]));
    var contactsBox = await Hive.box("contactsBox");
    await contactsBox.put("contactsall", contactsall);
    setState(() {});
    print(contactsall);
  }

  void getCurrentUser() async {
    _auth = FirebaseAuth.instance;
    // ignore: await_only_futures
    _user = await _auth.currentUser!;
    setState(() {
      usernumber = _user.phoneNumber
          .toString()
          .substring(_user.phoneNumber.toString().length - 10);
    });
  }

  void _createClient(context) async {
    print("create client called");
    _client =
        await AgoraRtmClient.createInstance("8b3f1a86336a476ca0bec49aa0061c51");

    _login(context);
    _client?.onMessageReceived =
        (AgoraRtmMessage message, String peerId) async {
      print("Private Message from " + peerId + ": " + message.text);
      var box = await Hive.box("messages");
      List msgList = await box.get(peerId);
      if (msgList == null) {
        await box.put(peerId, []);
      }
      msgList = await box.get(peerId);
      var dt = DateTime.now().toString();
      var date = dt.split(" ")[0];
      var time = dt.split(" ")[1];
      time = time.substring(0, time.indexOf('.'));
      var dateTime = date + "\n" + time;
      print(dateTime);
      //2021-07-12 16:53:10.200373
      if (message.text.contains(
          "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE")) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CallNoti(fullstring: message.text)));
      } else {
        msgList.add({
          'from': 'reciver',
          'message': message.text,
          'time': dateTime,
          'datetime': dt
        });
      }

      await box.put(peerId, msgList);
      setState(() {
        if (!message.text.contains(
            "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE")) {
          lastMsgs[peerId]["message"] = message.text;
          lastMsgs[peerId]["time"] = dateTime;
          var ind;
          for (var i = 0; i < contactsall.length; i++) {
            if (contactsall[i]["phoneNumber"].toString() == peerId) {
              ind = i;
              break;
            }
          }
          contactsall[ind]["time"] = dateTime;
        }
        //var dateTime = DateTime.parse("dateTimeString");
        //someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));

        contactsall.sort((a, b) => (b["time"]).compareTo(a["time"]));
        print(contactsall);
      });
      /* Update contactList with recent message at first */
    };

    _client?.onConnectionStateChanged = (int state, int reason) {
      print('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client?.logout();
        print('Logout.');
      }
    };
  }

  void _login(BuildContext context) async {
    //print(jsonDecode(_user.toString()));
    String userId = usernumber;
    if (userId.isEmpty) {
      print('Please input your user id to login.');
      return;
    }

    try {
      await _client?.login(null, userId);
      print('Login success: ' + userId);
      // _joinChannel(context);
    } catch (errorCode) {
      print('Login error: ' + errorCode.toString());
    }
  }

  void getcontacts() async {
    await _handleCameraAndMic(Permission.contacts);
    if (await Permission.contacts.isGranted) {
      List<Contact> contacts =
          (await Contacts.getContacts(withThumbnails: false)).toList();

      List finalContacts = [];
      for (int i = 0; i < contacts.length; i++) {
        List curPerson = [];
        if (contacts[i].phones != null) {
          for (var j = 0; j < contacts[i].phones.length; j++) {
            var len = contacts[i].phones.elementAt(j).value.length;
            var no = contacts[i].phones.elementAt(j).value.split(" ");
            // print("Split nos");
            // print(no);
            String cont = "";
            for (var k = 0; k < no.length; k++) {
              cont += no[k].trim();
            }
            if (len > 10) {
              cont = cont.substring(cont.length - 10);
            }
            curPerson.add(cont);
          }
          if (curPerson.contains(_user.phoneNumber
              .toString()
              .substring(_user.phoneNumber.toString().length - 10))) {
          } else {
            finalContacts.add(curPerson);
          }
        }
      }
      print(finalContacts);
      final response = await http.post(
        Uri.parse(
            'https://Projext-x-agora-dynamic-key.lastbenchbench.repl.co/getUserList'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List>{'contacts': finalContacts.toList()}),
      );

      if (response.statusCode == 200) {
        contactsall = jsonDecode(response.body);

        getLastMessages();

        //print(contactsall);
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        print(response.statusCode);
      }

      print(contacts[0]);
    }
  }

  // contacts: [[1313213,3123123], [123213]]
  // http://project-x-agora.herokuapp.com/getUserList
  /* 
    [
        {
            "id": "60e97b87c497a5b9bf322aae",
            "name": "Sahil Saha",
            "profilePic": " ",
            "phoneNumber": "6295489435",
            "flex": "Fsad"
        }
    ]
  */
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
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
                  text: 'Chat with your friends',
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
              padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 50),
              height: MediaQuery.of(context).size.height - 260,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: contactsall.isNotEmpty
                  ? ListView.builder(
                      itemCount: contactsall.length,
                      itemBuilder: (context, index) {
                        return chatElement(
                          "https://robohash.org/${contactsall[index]['phoneNumber']}?set=set1&bgset=bg2&size=200x200",
                          context,
                          contactsall[index]['name'].toString(),
                          contactsall[index]['phoneNumber'].toString(),
                          lastMsgs[contactsall[index]['phoneNumber'].toString()]
                                  ['message']
                              .toString(),
                          lastMsgs[contactsall[index]['phoneNumber'].toString()]
                                  ['time']
                              .toString(),
                          contactsall[index]['flex'].toString(),
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF122543),
                      ),
                    ))
        ],
      ),
    );
  }

  Widget chatElement(String avatarUrl, BuildContext context, String name,
      String phoneNumber, String message, String time, String flex) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        name: name,
                        profile: avatarUrl,
                        phoneNumber: phoneNumber,
                        currentUserNumber: usernumber,
                        flex: flex,
                      )));
        },
        leading: Avatar(avatarUrl: avatarUrl),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryText(text: name, fontSize: 18),
            PrimaryText(text: time, color: Colors.grey.shade400, fontSize: 14),
          ],
        ),
        subtitle: PrimaryText(
            text: message,
            color: Colors.grey.shade600,
            fontSize: 14,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
