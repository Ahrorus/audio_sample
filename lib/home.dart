import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void OnError(Exception exception);

const kUrl = "http://www.rxlabz.com/labz/audio2.mp3";
const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";
const List<String> lectureKeys = ['lecture0', 'lecture1', 'lecture2', 'lecture3'];
enum PlayerState { stopped, playing, paused }


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

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

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  List<bool> audioDownloadCheck = [false, false, false, false]; // for now, it's 4

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

  _setAudioDownloadCheck(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(lectureKeys[i], true);
      for (int i = 0; i < lectureKeys.length; i++) {
        audioDownloadCheck[i] = (prefs.getBool(lectureKeys[i]) ?? false);
      }
    });
  }
  _setAudioDownloadCheckOff(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(lectureKeys[i], false);
      for (int i = 0; i < lectureKeys.length; i++) {
        audioDownloadCheck[i] = (prefs.getBool(lectureKeys[i]) ?? false);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
      .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
      audioPlayer.onPlayerStateChanged.listen((s) {
        if (s == AudioPlayerState.PLAYING) {
          setState(() => duration = audioPlayer.duration);
        } else if (s == AudioPlayerState.STOPPED) {
          onComplete();
          setState(() {
            position = duration;
          });
        }
      }, onError: (msg) {
        setState(() {
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
        });
      });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future _playLocal() async {
    await _localFile;
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
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

  Future _loadFile() async {
    final bytes = await _loadFileBytes(kUrl,
      onError: (Exception exception) =>
        print('_loadFile => exception $exception'));

    final file = await _localFile;

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
        _setAudioDownloadCheck(0);
      });
  }

  @override
  Widget build(BuildContext context){
/*
    for (int i = 0; i < lectureKeys.length; i++) {
      audioDownloadCheck[i] = getAudioDownloadCheck(i);
    }
*/
    print('AUDIO DOWNLOAD CHECK: ');
    for (int i = 0; i < lectureKeys.length; i++) {
      print('$i - ${audioDownloadCheck[i]}');
    }

    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Material(child: _buildPlayer()),
        ]
      ),
    );
  }


  Widget _buildPlayer(){
    return new Container(
      padding: new EdgeInsets.all(15.0),
      child: new Column(children: [
        new Row(mainAxisSize: MainAxisSize.max, children: [
          new IconButton(
            onPressed: () {
              if (audioDownloadCheck[0]) {
                isPlaying ? pause() : _playLocal();
              } else {
                _loadFile();
              }
            },
            iconSize: 50.0,
            icon: (audioDownloadCheck[0]) ? (isPlaying ? new Icon(Icons.pause) :
            new Icon(Icons.play_arrow)) : new Icon(Icons.file_download),
            color: Colors.cyan
          ),
          /* ----------- Pause and Play buttons
          new IconButton(
            onPressed: isPlaying ? () => pause() : null,
            iconSize: 64.0,
            icon: new Icon(Icons.pause),
            color: Colors.cyan),
          new IconButton(
            onPressed: isPlaying || isPaused ? () => stop() : null,
            iconSize: 64.0,
            icon: new Icon(Icons.stop),
            color: Colors.cyan),
          */
          duration == null
            ? new Container()
            : new Slider(
            value: position?.inMilliseconds?.toDouble() ?? 0.0,
            onChanged: (double value) =>
              audioPlayer.seek((value / 1000).roundToDouble()),
            min: 0.0,
            max: duration.inMilliseconds.toDouble()
          ),
        ]),
        // ---------- Here was the slider
        /* ---------- Mute/Unmute Buttons
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new IconButton(
            onPressed: () => mute(true),
            icon: new Icon(Icons.headset_off),
            color: Colors.cyan),
          new IconButton(
            onPressed: () => mute(false),
            icon: new Icon(Icons.headset),
            color: Colors.cyan),
        ],
      ),
      */
        new Row(mainAxisSize: MainAxisSize.min, children: [
          new Padding(
            padding: new EdgeInsets.all(12.0),
            child: new Stack(children: [
              new CircularProgressIndicator(
                value: 1.0,
                valueColor: new AlwaysStoppedAnimation(Colors.grey[300])),
              new CircularProgressIndicator(
                value: position != null && position.inMilliseconds > 0
                  ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                  (duration?.inMilliseconds?.toDouble() ?? 0.0)
                  : 0.0,
                valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                backgroundColor: Colors.yellow,
              ),
            ])),
          new Text(
            position != null
              ? "${positionText ?? ''} / ${durationText ?? ''}"
              : duration != null ? durationText : '',
            style: new TextStyle(fontSize: 24.0))
        ])
      ])
    );
  }

}



/*import 'audio_track.dart';
import 'package:flutter/material.dart';

const kUrl = "http://www.rxlabz.com/labz/audio2.mp3";
const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  AudioTrack audioTrack = new AudioTrack(_HomeState());

  @override
  void initState(){
    super.initState();
    audioTrack.initAudioPlayer();
  }

  @override
  void dispose() {
    audioTrack.positionSubscription.cancel();
    audioTrack.audioPlayerStateSubscription.cancel();
    AudioTrack.audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: Text('Audio Sample'),
        backgroundColor: Colors.blue,
      ),
      body: new ListView(
        children: <Widget>[
          new Material(child: _buildPlayer()),
          (audioTrack.localFilePath != null) ? new Text(audioTrack.localFilePath) : new Container(),
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new RaisedButton(
                  onPressed: () => audioTrack.loadFile(),
                  child: new Text('Download'),
                ),
                new RaisedButton(
                  onPressed: () => audioTrack.playLocal(),
                  child: new Text('play local'),
                ),
              ],
            )
          )
        ]
      ),
    );
  }


  Widget _buildPlayer() => new Container(
    padding: new EdgeInsets.all(16.0),
    child: new Column(mainAxisSize: MainAxisSize.min, children: [
      new Row(mainAxisSize: MainAxisSize.min, children: [
        new IconButton(
          onPressed: audioTrack.isPlaying ? null : () => audioTrack.play(),
          iconSize: 64.0,
          icon: new Icon(Icons.play_arrow),
          color: Colors.cyan),
        new IconButton(
          onPressed: audioTrack.isPlaying ? () => audioTrack.pause() : null,
          iconSize: 64.0,
          icon: new Icon(Icons.pause),
          color: Colors.cyan),
        new IconButton(
          onPressed: audioTrack.isPlaying || audioTrack.isPaused ? () => audioTrack.stop() : null,
          iconSize: 64.0,
          icon: new Icon(Icons.stop),
          color: Colors.cyan),
      ]),
      audioTrack.duration == null
        ? new Container()
        : new Slider(
        value: audioTrack.position?.inMilliseconds?.toDouble() ?? 0.0,
        onChanged: (double value) =>
          AudioTrack.audioPlayer.seek((value / 1000).roundToDouble()),
        min: 0.0,
        max: audioTrack.duration.inMilliseconds.toDouble()),
      /* ---------- Mute/Unmute Buttons
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new IconButton(
            onPressed: () => mute(true),
            icon: new Icon(Icons.headset_off),
            color: Colors.cyan),
          new IconButton(
            onPressed: () => mute(false),
            icon: new Icon(Icons.headset),
            color: Colors.cyan),
        ],
      ),
      */
      new Row(mainAxisSize: MainAxisSize.min, children: [
        new Padding(
          padding: new EdgeInsets.all(12.0),
          child: new Stack(children: [
            new CircularProgressIndicator(
              value: 1.0,
              valueColor: new AlwaysStoppedAnimation(Colors.grey[300])),
            new CircularProgressIndicator(
              value: audioTrack.position != null && audioTrack.position.inMilliseconds > 0
                ? (audioTrack.position?.inMilliseconds?.toDouble() ?? 0.0) /
                (audioTrack.duration?.inMilliseconds?.toDouble() ?? 0.0)
                : 0.0,
              valueColor: new AlwaysStoppedAnimation(Colors.cyan),
              backgroundColor: Colors.yellow,
            ),
          ])),
        new Text(
          audioTrack.position != null
            ? "${audioTrack.positionText ?? ''} / ${audioTrack.durationText ?? ''}"
            : audioTrack.duration != null ? audioTrack.durationText : '',
          style: new TextStyle(fontSize: 24.0))
      ])
    ])
  );

}
*/