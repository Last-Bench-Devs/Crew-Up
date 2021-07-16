//
// Generated file. Do not edit.
//

// ignore_for_file: lines_longer_than_80_chars

import 'package:assets_audio_player_web/web/assets_audio_player_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:geolocator_web/geolocator_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  AssetsAudioPlayerWebPlugin.registerWith(registrar);
  FirebaseFirestoreWeb.registerWith(registrar);
  FirebaseAuthWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FluttertoastWebPlugin.registerWith(registrar);
  GeolocatorPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
