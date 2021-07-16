import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:us/screens/call/call.dart';


class CallNoti extends StatefulWidget {
  final String? fullstring;

  const CallNoti({Key? key, this.fullstring}) : super(key: key);

  @override
  _CallNotiState createState() => _CallNotiState();
}

class _CallNotiState extends State<CallNoti> {


  final assetsAudioPlayer = AssetsAudioPlayer();



  ClientRole? _role = ClientRole.Broadcaster;
  var mobilenumber = "";
  var code = "";
  var key = "";
  bool pickedup = false;
  @override
  void initState() {
    print(widget.fullstring);
    List alldata = widget.fullstring.toString().split(" ");
    setState(() {
      code = alldata[1];
      key = alldata[2];
      mobilenumber = alldata[4];
    });
    
    Future.delayed(Duration(seconds: 26), () {
      if(pickedup==false){
        Navigator.of(context).pop();
        print("poped");
      }
    });

    super.initState();
    playsound();
  }

  void playsound()async{
    print("runned once");
    try {
      print("playing audio");
      await assetsAudioPlayer.open(
        Audio("/assets/audios/ringtone.mp3"),showNotification: false,autoStart: true).then((value) => assetsAudioPlayer.play());
    } catch (e) {
      print('Audio playing error $e');
    // ignore: empty_statements
    };
  }

  

  Future<void> onJoin() async {
    // update input validation
    if (code.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
              channelName: code, tokenid: key, role: _role, code: code),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF122543),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              SizedBox(
                height: 35,
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
                              color: Theme.of(context).scaffoldBackgroundColor),
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
                                "https://robohash.org/$mobilenumber?set=set1&bgset=bg2&size=200x200",
                              ))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  mobilenumber,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[200]),
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
                    child: Text(mobilenumber,
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.grey)),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        assetsAudioPlayer.pause();
                        onJoin();
                        setState(() {
                          pickedup = true;
                        });
                      },
                      icon: Icon(Icons.call),
                      iconSize: 50,
                      color: Colors.green,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        assetsAudioPlayer.pause();
                      },
                      icon: Icon(Icons.call_end),
                      iconSize: 50,
                      color: Colors.red,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
