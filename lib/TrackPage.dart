import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:karting_application/main.dart';
import 'package:karting_application/TrackDetail.dart';
import 'dart:convert';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_launcher/maps_launcher.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<Map<String, dynamic>> _kartPlaces = [];
  List<Map<String, dynamic>> _savedPlaces = [];
  late Position _currentPosition;
  String apiKey = 'AIzaSyDINb5jEJSNl4aLsbGCBXSiImHMTnajoGw';
  final TextEditingController _searchController = TextEditingController();
  int _radius = 5000; // default radius
  final _auth = FirebaseAuth.instance;
  late User user;
  late Future<void> _fetchUserFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _fetchUser();
    _requestLocationPermission();
  }

  Future<void> _fetchUser() async {
    User currentUser = _auth.currentUser!;
    setState(() {
      user = currentUser;
    });
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
    String baseSearch = 'karting tracks';
    String keyword = _searchController.text.isEmpty
        ? baseSearch
        : '${_searchController.text} $baseSearch';

    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=$_radius&keyword=$keyword&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        List results = data['results'];
        setState(() {
          _kartPlaces = results.cast<Map<String, dynamic>>();
        });
      } else {
        // Clear the list if there are no results or an error occurs
        setState(() {
          _kartPlaces.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No results found')),
          );
        });
      }
    } else {
      // Clear the list if there's an error
      setState(() {
        _kartPlaces.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred. Please try again.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: SearchBar(
          controller: _searchController,
          hintText: "Search",
          leading: const Icon(Icons.search),
          trailing: <Widget>[
            DropdownButton<int>(
              value: _radius,
              hint: const Text('Distance'),
              items: const [
                DropdownMenuItem(
                  value: 5000,
                  child: Text('5 km'),
                ),
                DropdownMenuItem(
                  value: 10000,
                  child: Text('10 km'),
                ),
                DropdownMenuItem(
                  value: 20000,
                  child: Text('20 km'),
                ),
                DropdownMenuItem(
                  value: 30000,
                  child: Text('30 km'),
                ),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _radius = newValue!;
                  _fetchKartPlaces(); // Fetch kart places whenever the user changes the radius
                });
              },
            ),
          ],
          onChanged: (_) {
            _fetchKartPlaces(); // Fetch kart places whenever the user submits a search
          },
        ),
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
          return GestureDetector(
              // Wrap the Card widget with a GestureDetector
              onTap: () {
                // Navigate to the TrackDetail screen with the selected kart place
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TrackDetail(kartPlace: _kartPlaces[index]),
                  ),
                );
              },
              child: Card(
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
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(user.uid)
                                .collection('SavedTracks')
                                .where('trackData.name',
                                    isEqualTo: _kartPlaces[index]['name'])
                                .get()
                                .then((querySnapshot) {
                              if (querySnapshot.docs.isEmpty) {
                                // Save track to Firestore
                                FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(user.uid)
                                    .collection('SavedTracks')
                                    .add({
                                  'trackData': _kartPlaces[index],
                                }).then((value) {
                                  setState(() {
                                    _savedPlaces.add(_kartPlaces[index]);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Saved Successfully!')),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to save. Please try again.')),
                                  );
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Track already saved.')),
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
