import 'dart:async';
import 'dart:io';

import 'package:audio_sample/util/loader.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum PlayerStatus { stopped, playing, paused }

String currentAudio;

class Player extends StatefulWidget {
  @override
  PlayerState createState() {
    return PlayerState();
  }
}

class PlayerState extends State<Player> {
  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription audioPlayerStateSubscription;
  Duration duration;
  Duration position;
  bool isLoading = false;

  PlayerStatus playerState = PlayerStatus.stopped;

  get isPlaying => playerState == PlayerStatus.playing;
  get isPaused => playerState == PlayerStatus.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  Future<String> getLocalPath(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    String fileName = url.replaceAll('/', '_').replaceAll(':', '_');
    return '${dir.path}/$fileName';
  }

  Future loadAudio({String url, String path}) async {
    try {
      setState(() {
        isLoading = true;
        print('loading started');
      });
      await loadFile(url: url, path: path);
      setState(() {
        print('loading ended');
        isLoading = false;
      });
    } on Exception {
      print('failed to download audio');
    }
  }

  Future play({String url}) async {
    currentAudio = url;
    String path = await getLocalPath(url);
    if ((await File(path).exists())) {
      _playLocal(path);
    } else {
      _playNetwork(url);
      if (!isLoading) {
        loadAudio(url: url, path: path);
      }
    }
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerStatus.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerStatus.stopped;
      position = new Duration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        _onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerStatus.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future _playNetwork(String url) async {
    await audioPlayer.play(url);
    setState(() {
      playerState = PlayerStatus.playing;
    });
  }

  Future _playLocal(String path) async {
    await audioPlayer.play(path, isLocal: true);
    setState(() => playerState = PlayerStatus.playing);
  }

  _onComplete() {
    setState(() => playerState = PlayerStatus.stopped);
  }
}
