import 'package:flutter/material.dart';

import '../util/player.dart';

_BottomSheetPlayerState _playerState;

class BottomPlayer extends Player {
  play(String url) {
    if (url != currentAudio) {
      _playerState.stop();
    }
    _playerState.play(url: url);
  }

  hide() {
    _playerState.hide();
  }

  show() {
    _playerState.show();
  }

  @override
  _BottomSheetPlayerState createState() {
    _playerState = _BottomSheetPlayerState();
    return _playerState;
  }
}

class _BottomSheetPlayerState extends PlayerState {
  bool isHidden = true;

  hide() {
    setState(() {
      isHidden = true;
    });
  }

  show() {
    setState(() {
      isHidden = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isHidden,
      maintainState: true,
      child: Container(
          padding: EdgeInsets.all(15.0),
          child: Wrap(children: [
            Row(mainAxisSize: MainAxisSize.max, children: [
              IconButton(
                  onPressed: () {
                    isPlaying ? pause() : play(url: currentAudio);
                  },
                  iconSize: 50.0,
                  icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                  color: Colors.cyan),
              (duration == null)
                  ? Container()
                  : Slider(
                      value: position?.inMilliseconds?.toDouble() ?? 0.0,
                      onChanged: (double value) =>
                          audioPlayer.seek((value / 1000).roundToDouble()),
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble()),
            ]),
            (duration == null)
                ? Container()
                : Text(
                    position != null
                        ? "${positionText ?? ''} / ${durationText ?? ''}"
                        : duration != null ? durationText : '',
                    style: TextStyle(fontSize: 24.0))
          ])),
    );
  }
}
