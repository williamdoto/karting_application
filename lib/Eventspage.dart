import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Page'),
      ),
      body: Center(
        child: Text(
          'This is the Events Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
