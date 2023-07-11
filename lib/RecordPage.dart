import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Record Page',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
