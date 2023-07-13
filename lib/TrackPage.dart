import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:karting_application/main.dart';
import 'dart:convert';
import 'package:flutter_google_maps_webservices/places.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<Map<String, dynamic>> _kartPlaces = [];
  List<Map<String, dynamic>> _savedPlaces = [];
  late Position _currentPosition;
  String apiKey = 'AIzaSyDINb5jEJSNl4aLsbGCBXSiImHMTnajoGw'; // Replace with your Google Maps API key

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
          content: const Text(
              'Please grant location access to view tracks around you.'),
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
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MyApp(),
                ));
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
    String keyword = 'karting tracks';
    int radius = 5000;

    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=$radius&keyword=$keyword&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        List results = data['results'];
        setState(() {
          _kartPlaces = results.cast<Map<String, dynamic>>();
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracks Around You'),
      ),
      body: ListView.builder(
        itemCount: _kartPlaces.length,
        itemBuilder: (context, index) {
          String? photoReference = _kartPlaces[index]['photos'] != null &&
                  _kartPlaces[index]['photos'].length > 0
              ? _kartPlaces[index]['photos'][0]['photo_reference']
              : null;
          String photoUrl =
              "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey";
          return Card(
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photoReference != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        height: 150.0,
                        width: double.infinity,
                      )
                    : const SizedBox(
                        height: 150.0,
                        width: double.infinity,
                        child: Icon(
                          Icons.directions_car,
                          size: 64.0,
                          color: Colors.grey,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _kartPlaces[index]['name'],
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _kartPlaces[index]['vicinity'],
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      child: const Text('SAVE'),
                      onPressed: () {
                        setState(() {
                          _savedPlaces.add(_kartPlaces[index]);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
