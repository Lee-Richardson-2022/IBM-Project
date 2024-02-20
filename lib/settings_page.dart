import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Add your settings widgets here
            ListTile(
              title: Text('Flash'),
            ),
            ListTile(
              title: Text('Flip Camera'),
            ),
          ],
        ),
      ),
    );
  }
}