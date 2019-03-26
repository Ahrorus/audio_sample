import 'package:flutter/material.dart';

import '../audio_template.dart';
import 'common.dart';

class BottomSheetPlayer extends CommonPlayer {
  @override
  _BottomSheetPlayerState createState() => _BottomSheetPlayerState();
}

class _BottomSheetPlayerState extends CommonPlayerState {
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.all(15.0),
        child: Wrap(children: [
          new Row(mainAxisSize: MainAxisSize.max, children: [
            new IconButton(
                onPressed: () {
                  if (audioDownloadCheck[0] && !isLoading) {
                    isPlaying ? pause() : playLocal(localFilePath);
                  } else if (isLoading) {
                  } else {
                    loadAudio(url: audioList[0].address, localPath: localFile);
                    setState(() {
                      setAudioDownloadCheck(0);
                    });
                  }
                },
                iconSize: 50.0,
                icon: (audioDownloadCheck[0] && !isLoading)
                    ? (isPlaying
                        ? new Icon(Icons.pause)
                        : new Icon(Icons.play_arrow))
                    : (isLoading
                        ? Icon(Icons.cached)
                        : new Icon(Icons.file_download)),
                color: Colors.cyan),
            duration == null
                ? new Container()
                : new Slider(
                    value: position?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (double value) =>
                        audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble()),
          ]),
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
        ]));
  }
}
