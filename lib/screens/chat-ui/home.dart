import './chat.dart';
import './constant.dart';
import './style.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) => chatElement(
                  userList[index]['avatar'].toString(),
                  context,
                  userList[index]['name'].toString(),
                  userList[index]['message'].toString(),
                  userList[index]['time'].toString()),
            ),
          )
        ],
      ),
    );
  }

  Widget chatElement(String avatarUrl, BuildContext context, String name,
      String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: ListTile(
        onTap: () => {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatScreen()))
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
