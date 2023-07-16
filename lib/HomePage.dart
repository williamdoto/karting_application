import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Speed Trap'),
      ),
      body: Center(
        child: 
          Text(
            'Home Page',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
      ),
    );
  }
}
