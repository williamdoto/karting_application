import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karting_application/firebase_options.dart';
import 'package:karting_application/models/user_model.dart';
import 'package:karting_application/HomePage.dart';
import 'package:karting_application/TrackPage.dart';
import 'package:karting_application/RecordPage.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'package:uuid/uuid.dart';

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
    final user = User(id: generateUserId()); // Generate the user ID dynamically
    return ChangeNotifierProvider<User>.value(
      value: user,
      child: MaterialApp(
        title: 'Speed Trap',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(),
          '/createRecord': (context) {
            final user = Provider.of<User>(context, listen: false);
            return CreateRecordPage(userId: user.id);
          },
        },
      ),
    );
  }

  String generateUserId() {
    final uuid = Uuid();
    return uuid.v4();
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
    Consumer<User>(
      builder: (context, user, child) => RecordPage(userId: user.id),
    ),
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
