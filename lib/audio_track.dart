import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

const kUrl = "http://www.rxlabz.com/labz/audio2.mp3";
const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";
enum PlayerState { stopped, playing, paused }

class AudioTrack {

  Duration duration;
  Duration position;
  State state;

  static AudioPlayer audioPlayer;

  String localFilePath;

  AudioTrack(State state) {
    this.state = state;
  }

  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    localFilePath = '${dir.path}/audio.mp3';
    return File(localFilePath);
  }

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
    duration != null ? duration.toString().split('.').first : '';
  get positionText =>
    position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription positionSubscription;
  StreamSubscription audioPlayerStateSubscription;

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged
      .listen((p) => state.setState(() => position = p));
    audioPlayerStateSubscription =
      audioPlayer.onPlayerStateChanged.listen((s) {
        if (s == AudioPlayerState.PLAYING) {
          state.setState(() => duration = audioPlayer.duration);
        } else if (s == AudioPlayerState.STOPPED) {
          onComplete();
          state.setState(() {
            position = duration;
          });
        }
      }, onError: (msg) {
        state.setState(() {
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
        });
      });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    state.setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future playLocal() async {
    await _localFile;
    await audioPlayer.play(localFilePath, isLocal: true);
    state.setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    state.setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    state.setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    state.setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    state.setState(() => playerState = PlayerState.stopped);
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future loadFile() async {
    final bytes = await _loadFileBytes(kUrl,
      onError: (Exception exception) =>
        print('_loadFile => exception $exception'));

    final file = await _localFile;

    await file.writeAsBytes(bytes);
    if (await file.exists())
      state.setState(() {
        localFilePath = file.path;
      });
  }


}