import 'dart:async';
import 'dart:io';

import 'package:audio_sample/util/loader.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/player.dart';

const List<String> lectureKeys = [
  'lecture0',
  'lecture1',
  'lecture2',
  'lecture3'
];

class CommonPlayer extends StatefulWidget {
  @override
  CommonPlayerState createState() => CommonPlayerState();
}

class CommonPlayerState extends State<CommonPlayer> with Player {
  String localFilePath;

  bool isLoading = false;

  Future<File> get localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/audio1.mp3');
  }

  Future loadAudio({url, localPath}) async {
    setState(() {
      isLoading = true;
      print('loading started');
    });
    localFilePath = await loadFile(url: url, localPath: localPath);
    setState(() {
      print('loading ended');
      isLoading = false;
    });
  }

  List<bool> audioDownloadCheck = [
    false,
    false,
    false,
    false
  ]; // for now, it's 4

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    _getSharedPreferences();
  }

  _getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < lectureKeys.length; i++) {
        audioDownloadCheck[i] = (prefs.getBool(lectureKeys[i]) ?? false);
      }
    });
  }

  setAudioDownloadCheck(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(lectureKeys[i], true);
      for (int i = 0; i < lectureKeys.length; i++) {
        audioDownloadCheck[i] = (prefs.getBool(lectureKeys[i]) ?? false);
      }
    });
  }

  setAudioDownloadCheckOff(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(lectureKeys[i], false);
      for (int i = 0; i < lectureKeys.length; i++) {
        audioDownloadCheck[i] = (prefs.getBool(lectureKeys[i]) ?? false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
