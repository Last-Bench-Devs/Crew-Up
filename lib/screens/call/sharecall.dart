import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:us/screens/call/call.dart';
import 'package:us/screens/chat-ui/style.dart';

class ShareCall extends StatefulWidget {
  final String? channelName;
  final String? tokenid;
  final String? code;
  final ClientRole? role;

  /// non-modifiable client role of the page

  /// Creates a call page with given channel name.
  const ShareCall(
      {Key? key, this.channelName, this.tokenid, this.role, this.code})
      : super(key: key);

  @override
  _ShareCallState createState() => _ShareCallState();
}

class _ShareCallState extends State<ShareCall> {
  void share() async {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        shared = true;
      });
    });

    await FlutterShare.share(
        title: 'CREW UP',
        text: 'Your Crew Up Conference Code:',
        linkUrl: widget.channelName,
        chooserTitle: 'CREW-UP');
  }

  bool shared = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Center(
            child: PrimaryText(
              text: "Share Conference Code With Your Friends",
              fontSize: 17,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.asset('lib/assets/share.png')),
          Spacer(),
          RaisedButton(
              onPressed: () {
                if (shared == true) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallPage(
                          channelName: widget.code,
                          tokenid: widget.tokenid,
                          role: widget.role,
                          code: widget.code),
                    ),
                  );
                } else {
                  share();
                }
              },
              color: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 50),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: shared
                  ? Text(
                      "JOIN",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    )
                  : Text(
                      "SHARE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    )),
          Spacer()
        ],
      ),
    );
  }
}
