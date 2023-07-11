import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;

    if (permission != PermissionStatus.granted) {
      PermissionStatus newPermission =
          await Permission.locationWhenInUse.request();
      if (newPermission != PermissionStatus.granted) {
        _showPermissionDialog();
      } else {
        _getCurrentLocation();
      }
    } else {
      _getCurrentLocation();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content:
              const Text('Please grant location access to view tracks around you.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission(); // retry requesting permission
              },
            ),
            TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // close the dialog
              // handle situation when user refuses to grant permission
            },
          ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _fetchKartPlaces();
    }).catchError((e) {
      print(e);
    });
  }

  void _fetchKartPlaces() async {
    // fetch data from Google Places API
  }

  @override
  Widget build(BuildContext context) {
    // your build method
  }
}
