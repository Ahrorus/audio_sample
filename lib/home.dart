import 'package:flutter/material.dart';

import 'audio_template.dart';
import 'ui/bottom_player.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BottomPlayer bottomPlayer;

  @override
  void initState() {
    super.initState();
    bottomPlayer = BottomPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('audio_sample')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Lection 0'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[0].address);
            },
          ),
          ListTile(
            title: Text('Lection 1'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[1].address);
            },
          ),
          ListTile(
            title: Text('Lection 2'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[2].address);
            },
          ),
          ListTile(
            title: Text('Lection 3'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[3].address);
            },
          ),
          ListTile(
            title: Text('Lection 4'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[4].address);
            },
          ),
          ListTile(
            title: Text('Lection 5'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[5].address);
            },
          ),
          ListTile(
            title: Text('Lection 6'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[6].address);
            },
          ),
          ListTile(
            title: Text('Lection 0'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[0].address);
            },
          ),
          ListTile(
            title: Text('Lection 1'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[1].address);
            },
          ),
          ListTile(
            title: Text('Lection 2'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[2].address);
            },
          ),
          ListTile(
            title: Text('Lection 3'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[3].address);
            },
          ),
          ListTile(
            title: Text('Lection 4'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[4].address);
            },
          ),
          ListTile(
            title: Text('Lection 5'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[5].address);
            },
          ),
          ListTile(
            title: Text('Lection 6'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[6].address);
            },
          ),
          ListTile(
            title: Text('Lection 0'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[0].address);
            },
          ),
          ListTile(
            title: Text('Lection 1'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[1].address);
            },
          ),
          ListTile(
            title: Text('Lection 2'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[2].address);
            },
          ),
          ListTile(
            title: Text('Lection 3'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[3].address);
            },
          ),
          ListTile(
            title: Text('Lection 4'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[4].address);
            },
          ),
          ListTile(
            title: Text('Lection 5'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[5].address);
            },
          ),
          ListTile(
            title: Text('Lection 6'),
            onTap: () {
              bottomPlayer.show();
              bottomPlayer.play(audioList[6].address);
            },
          ),
        ],
      ),
      bottomNavigationBar: bottomPlayer,
    );
  }
}
