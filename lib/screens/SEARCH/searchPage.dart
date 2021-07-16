import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contact/contacts.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:us/call-notification/callNoti.dart';
import 'package:us/screens/accountpage/accountPage.dart';
import 'package:us/screens/chat-ui/chat.dart';
import 'package:us/screens/chat-ui/style.dart';
import 'package:us/utils/settings.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autotrie/autotrie.dart';

class searchPage extends StatefulWidget {
  @override
  _searchPageState createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  final searchcontroller = TextEditingController();

  var engine = AutoComplete(
      engine: SortEngine.configMulti(Duration(seconds: 1), 10000, 0.5,
          0.5)); //You can also initialize with a starting databank.

  var interval = Duration(milliseconds: 1);

  List contactsall = [];
  List all = [];
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

    // _auth = FirebaseAuth.instance;
    // _user = _auth.currentUser!;
    // print(_user);
    getCurrentUser();
    getBox();
    getContacts();
    getLastMessages();
    _createClient(context);

    searchcontroller.addListener(getSearch);
    isLoading = false;
  }

  void getSearch() {
    if (searchcontroller.text.length > 0) {
      setState(() {
        all = [];
      });
      List res = engine.suggest(searchcontroller.text.toLowerCase());
      for (int i = 0; i < res.length; i++) {
        var a = contactsall.indexWhere(
            (element) => element["name"].toString().toLowerCase() == res[i]);
        if (!all.contains(contactsall[a])) {
          all.add(contactsall[a]);
        }
      }
      setState(() {});
      //print(searchcontroller.text);
    }
  }

  void getContacts() async {
    var box = await Hive.box("contactsBox");
    contactsall = await box.get("contactsall");
    setState(() {});
    print("Contact LIST PRINTING");
    print(contactsall);
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
    for (int i = 0; i < contactsall.length; i++) {
      engine.enter(contactsall[i]["name"].toString().toLowerCase());
      print(contactsall[i]["name"]);
    }
    all = contactsall;
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
                  text: 'Search Your Contact',
                  fontSize: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Center(
                      child: TextField(
                    controller: searchcontroller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Search Users in your contact'),
                  )),
                )
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
                      itemCount: all.length,
                      itemBuilder: (context, index) {
                        return chatElement(
                          "https://robohash.org/${all[index]['phoneNumber']}?set=set1&bgset=bg2&size=200x200",
                          context,
                          all[index]['name'].toString(),
                          all[index]['phoneNumber'].toString(),
                          // lastMsgs[contactsall[index]['phoneNumber'].toString()]
                          //         ['message']
                          //     .toString(),
                          all[index]['flex'].toString(),
                          // lastMsgs[contactsall[index]['phoneNumber'].toString()]
                          //         ['time']
                          //     .toString(),
                          "",
                          all[index]['flex'].toString(),
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
