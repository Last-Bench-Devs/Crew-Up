import 'package:agora_rtm/agora_rtm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us/call-notification/callNoti.dart';

class BottomBar extends StatefulWidget {
  Function onPressed;
  bool bottomIcons;
  String text;
  IconData icons;
  BottomBar(
      {required this.onPressed,
      required this.bottomIcons,
      required this.icons,
      required this.text});
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List contactsall = [];
  late Map lastMsgs = {};
  late FirebaseAuth _auth;
  AgoraRtmClient? _client;
  late User _user;
  var usernumber = "";
  var box;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onPressed(),
        child: widget.bottomIcons == true
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.icons,
                      color: Color(0xFF122543),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.text,
                      style: TextStyle(
                          color: Color(0xFF122543),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                ),
              )
            : Icon(widget.icons));
  }
}
