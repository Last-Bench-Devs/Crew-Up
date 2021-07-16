import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

class CamPre extends StatelessWidget {
  const CamPre({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;

  void loadCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadCameras();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // MediaQueryData queryData;
    // queryData = MediaQuery.of(context);
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF122543),
          ),
        ),
      );
    }
    return Container(
      child: Transform.scale(
        scale: 1,
        child: new CameraPreview(controller!),
      ),
    );
    // return FittedBox(
    //   fit: BoxFit.fitWidth,
    //   child: Container(
    //     width: width,
    //     height: width / (controller!.value.aspectRatio),
    //     child: AspectRatio(
    //       aspectRatio: controller!.value.aspectRatio,
    //       child: CameraPreview(controller!),
    //     ),
    //   ),
    // );
  }
}
