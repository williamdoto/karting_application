import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karting_application/firebase_options.dart';
import 'package:karting_application/HomePage.dart';
import 'package:karting_application/TrackPage.dart';
import 'package:karting_application/RecordPage.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'LoginPage.dart';
import 'SignUpPage.dart';
import 'Eventspage.dart';
import 'ForgotPasswordPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Trap',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
            home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data?.uid == null) {
              // If the user is not logged in, return the LoginPage widget
              return LoginPage();
            } else {
              // If the user is logged in, return the MyHomePage widget
              return MyHomePage();
            }
          }
          // While the connection to Firebase is established, show a loading spinner
          return const CircularProgressIndicator();
        },
      ),
      initialRoute: '/', // Set the LoginPage as the initial route
      routes: {
        '/signup': (context) => SignUpPage(),
        '/forgetpassword': (context) => ForgotPasswordPage(),
        '/createRecord': (context) => const CreateRecordPage(),
        '/events':(context) => EventsPage() // CreateRecordPage can be accessed using Navigator.pushNamed(context, '/createRecord')
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
    const HomePage(),
    const TrackPage(),
    RecordPage(),
    EventsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
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
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Events',
          )
        ],
        unselectedItemColor: Colors.grey, // Add this
        selectedItemColor: Colors.deepPurple, // Add this
        showUnselectedLabels: true, // Add this line
      ),
    );
  }
}
