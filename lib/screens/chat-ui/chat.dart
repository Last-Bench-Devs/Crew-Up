import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:us/call-notification/callNoti.dart';
import 'package:us/screens/call/call.dart';
import 'package:us/screens/chat-ui/home.dart';
import 'package:us/screens/home-main/main_page.dart';
import 'package:us/screens/login/login.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import './constant.dart';
import './style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String? name;
  final String? profile;
  final String? phoneNumber;
  final String? currentUserNumber;
  final String? flex;

  const ChatScreen(
      {Key? key,
      this.name,
      this.profile,
      this.phoneNumber,
      this.currentUserNumber,
      this.flex})
      : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ClientRole? _role = ClientRole.Broadcaster;
  ScrollController _scrollController = new ScrollController();
  final _peerMessage = TextEditingController();
  AgoraRtmClient? _client;
  var box;
  List messages = [];
  @override
  void initState() {
    _initilizeMessages();
    _createClient(context);
    // if (_scrollController.hasClients)
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    Timer.run(() {
      // print("RUNNING");
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 3000);
    });
    super.initState();
  }

  void _initilizeMessages() async {
    box = await Hive.box("messages");
    messages = await box.get(widget.phoneNumber);
    if (messages == null) {
      await box.put(widget.phoneNumber, []);
    }
    messages = await box.get(widget.phoneNumber);
    setState(() {});
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _createClient(context) async {
    print("create client called");
    _client =
        await AgoraRtmClient.createInstance("8b3f1a86336a476ca0bec49aa0061c51");

    _login(context);
    _client?.onMessageReceived =
        (AgoraRtmMessage message, String peerId) async {
      print(widget.phoneNumber);
      print(peerId);
      var msgList = await box.get(peerId);
      var dt = DateTime.now().toString();
      var date = dt.split(" ")[0];
      var time = dt.split(" ")[1];
      time = time.substring(0, time.indexOf('.'));
      var dateTime = date + "\n" + time;
      print(dateTime);
      if (message.text.contains(
          "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE")) {
        print("call messege get");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CallNoti(fullstring: message.text)));
      } else {
        msgList.add({
          'from': 'reciver',
          'message': message.text,
          'time': dateTime,
        });
      }

      await box.put(peerId, msgList);
      messages = await box.get(peerId);
      setState(() {});
      // if (widget.phoneNumber == peerId) {
      //   setState(() {
      //     messages.add({
      //       'from': 'reciver',
      //       'message': message.text,
      //       'time': '18:35',
      //     });
      //   });

      print("Private Message from " + peerId + ": " + message.text);

      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 3000.00);
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
    String userId = widget.currentUserNumber.toString();
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

  void _callMessege({required String msgcall}) async {
    // var msgListcall = await box.get(widget.phoneNumber.toString());

    AgoraRtmMessage message = AgoraRtmMessage.fromText(msgcall);
    await _client!.sendMessageToPeer(widget.phoneNumber, message, true);
    _peerMessage.clear();
    _peerMessage.text = "";
    message.offline = true;

    // var dt = DateTime.now().toString();
    // var date = dt.split(" ")[0];
    // var time = dt.split(" ")[1];
    // time = time.substring(0, time.indexOf('.'));
    // var dateTime = date + "\n" + time;
    // print(dateTime);
    // msgListcall.add({
    //   'from': 'sender',
    //   'message': message.text,
    //   'time': dateTime,
    // });
    print('Send peer message success.');
  }

  void _sendPeerMessage() async {
    if (_peerMessage.text.isEmpty) {
      print('Please input text to send.');
      return;
    }
    var msgList = await box.get(widget.phoneNumber.toString());

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(_peerMessage.text);
      await _client!.sendMessageToPeer(widget.phoneNumber, message, true);
      _peerMessage.clear();
      _peerMessage.text = "";
      message.offline = true;

      var dt = DateTime.now().toString();
      var date = dt.split(" ")[0];
      var time = dt.split(" ")[1];
      time = time.substring(0, time.indexOf('.'));
      var dateTime = date + "\n" + time;
      print(dateTime);
      msgList.add({
        'from': 'sender',
        'message': message.text,
        'time': dateTime,
      });
      await box.put(widget.phoneNumber.toString(), msgList);
      messages = await box.get(widget.phoneNumber.toString());
      setState(() {});
      print('Send peer message success.');
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 3000.00);
    } catch (errorCode) {
      if (errorCode.toString().trim() ==
          "sendMessageToPeer failed errorCode:4") {
        var dt = DateTime.now().toString();
        var date = dt.split(" ")[0];
        var time = dt.split(" ")[1];
        time = time.substring(0, time.indexOf('.'));
        var dateTime = date + "\n" + time;
        print(dateTime);
        messages.add({
          'from': 'sender',
          'message': _peerMessage.text,
          'time': dateTime,
          'datetime': dt,
        });
        await box.put(widget.phoneNumber.toString(), msgList);
        messages = await box.get(widget.phoneNumber.toString());
        setState(() {});
        print('Send peer message success.');
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 3000.00);
        _peerMessage.clear();
      }

      print('Send peer message error: ' + errorCode.toString());
      print(errorCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFF122543),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainPage()));
          return true;
        },
        child: ListView(
          children: [customAppBar(context), header(), chatArea(context)],
        ),
      ),
    );
  }

  Container chatArea(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height - 210,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 300,
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      messages[index]['from'] == 'sender'
                          ? sender(messages[index]['message'].toString(),
                              messages[index]['time'].toString())
                          : receiver(messages[index]['message'].toString(),
                              messages[index]['time'].toString())),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: TextField(
                controller: _peerMessage,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawMaterialButton(
                      constraints: BoxConstraints(minWidth: 0),
                      onPressed: () {
                        _sendPeerMessage();
                      },
                      elevation: 2.0,
                      fillColor: Color(0xff5b61b9),
                      child: Icon(Icons.send, size: 22.0, color: Colors.white),
                      padding: EdgeInsets.all(10.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
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

  void onCreate() async {
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
      _callMessege(
          msgcall:
              "354FB4354B30DDA4EB39677CB80D744965E9721EEEF3479D9FDEDC28BB8964CE ${code} ${key} ${code} ${widget.currentUserNumber}");
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

  Padding header() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 00, bottom: 50),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryText(
              text: widget.name.toString(),
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  constraints: BoxConstraints(minWidth: 0),
                  onPressed: () {
                    onCreate();
                  },
                  elevation: 2.0,
                  fillColor: Colors.white38,
                  child:
                      Icon(Icons.video_call, size: 24.0, color: Colors.white),
                  padding: EdgeInsets.all(10.0),
                  shape: CircleBorder(),
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          PrimaryText(
            text: widget.flex.toString(),
            fontSize: 16,
            color: Colors.white,
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          PrimaryText(
            text: widget.phoneNumber.toString(),
            fontSize: 16,
            color: Colors.white70,
          ),
        ]),
      ]),
    );
  }

  Padding customAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlatButton(
              child: PrimaryText(text: 'Back', color: Colors.white54),
              onPressed: () => {
                    Navigator.of(context).pop(),
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MainPage())),
                  }),
        ],
      ),
    );
  }

  Widget sender(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PrimaryText(
                text: time, color: Colors.grey.shade400, fontSize: 14),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 100, maxWidth: 280),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(0))),
            child: PrimaryText(
              text: message,
              color: Colors.black54,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget receiver(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Avatar(
                  avatarUrl: widget.profile.toString(), width: 30, height: 30),
              Container(
                constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(25))),
                child: PrimaryText(
                  text: message,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PrimaryText(
                text: time, color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
