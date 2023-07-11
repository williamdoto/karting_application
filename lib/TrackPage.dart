import 'package:flutter/material.dart';

class TrackPage extends StatelessWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Track Page',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
