import 'package:flutter/material.dart';

import 'ui/bottom_sheet_player.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('audio_sample')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Lection 1'),
          ),
        ],
      ),
      bottomSheet: BottomSheetPlayer(),
    );
  }
}
