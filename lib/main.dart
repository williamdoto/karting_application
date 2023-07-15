import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karting_application/firebase_options.dart';
import 'package:karting_application/HomePage.dart';
import 'package:karting_application/TrackPage.dart';
import 'package:karting_application/RecordPage.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'LoginPage.dart';
import 'SignUpPage.dart';
import 'ForgotPasswordPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Trap',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/', // Set the LoginPage as the initial route
      routes: {
        '/': (context) => LoginPage(), // The LoginPage is now the first page seen by the user
        '/home': (context) => MyHomePage(), // HomePage can be accessed using Navigator.pushNamed(context, '/home')
        '/signup': (context) => SignUpPage(),
        '/forgetpassword': (context) => ForgotPasswordPage(),
        '/createRecord': (context) => CreateRecordPage(), // CreateRecordPage can be accessed using Navigator.pushNamed(context, '/createRecord')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    TrackPage(),
    RecordPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speed Trap'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_flags),
            label: 'Record',
          ),
        ],
      ),
    );
  }
}
