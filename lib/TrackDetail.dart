import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;

class TrackDetail extends StatefulWidget {
  final Map<String, dynamic> kartPlace;

  // TrackDetail constructor
  const TrackDetail({Key? key, required this.kartPlace}) : super(key: key);

  @override
  _TrackDetailState createState() => _TrackDetailState();
}

class _TrackDetailState extends State<TrackDetail> {
  final User user = FirebaseAuth.instance.currentUser!;
  bool isTrackAlreadySaved = false;
  Map<String, dynamic>? placeDetails;

  @override
  void initState() {
    super.initState();
    checkIfTrackAlreadySaved();
    fetchPlaceDetails(widget.kartPlace['place_id']);
  }

  Future<void> checkIfTrackAlreadySaved() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(user.uid)
        .collection('SavedTracks')
        .where('trackData.name', isEqualTo: widget.kartPlace['name'])
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isTrackAlreadySaved = true;
        });
      }
    });
  }

  Future<void> _launchURL() async {
    MapsLauncher.launchQuery(widget.kartPlace['name']);
  }

  Future<void> _launchCall(String? phoneNumber) async {
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone Number isn't available")));
    } else {
      String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      Uri url = Uri.parse('tel:$sanitizedNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    String apiKey =
        'AIzaSyDINb5jEJSNl4aLsbGCBXSiImHMTnajoGw'; // Enter your Google API Key

    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number,website,rating,opening_hours,reviews&reviews_sort=most_relevant&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      print(
          'API Response: ${response.body}'); // Add this line to print the entire API response

      setState(() {
        placeDetails = jsonDecode(response.body)['result'];
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void saveTrack() {
    if (!isTrackAlreadySaved) {
      // Save track to Firestore
      FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .collection('SavedTracks')
          .add({
        'trackData': widget.kartPlace,
      }).then((value) {
        setState(() {
          isTrackAlreadySaved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved Successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track already saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    late String? phoneNumber =
        placeDetails != null ? placeDetails!['formatted_phone_number'] : 'N/A';
    late String? website =
        placeDetails != null ? placeDetails!['website'] : 'N/A';
    //     String? openingHours = placeDetails != null
    //     ? (placeDetails!['opening_hours']['open_now'] ? 'Open Now' : 'Closed')
    //     : 'N/A';
    // double? rating = placeDetails != null ? placeDetails!['rating'] : 'N/A';
    // String? priceLevel = placeDetails != null ? placeDetails!['price_level'].toString() : 'N/A';
    late double? rating = placeDetails != null ? placeDetails!['rating'] : 0.0;
    // Fetch opening hours
    List<dynamic>? openingHours = placeDetails != null
        ? (placeDetails!['opening_hours']?['weekday_text'] as List<dynamic>?)
        : [];
    List<dynamic>? reviews = placeDetails != null
        ? placeDetails!['reviews'] as List<dynamic>?
        : null;

    String apiKey =
        'AIzaSyDINb5jEJSNl4aLsbGCBXSiImHMTnajoGw'; // Enter your Google API Key
    List<String> photos = widget.kartPlace['photos']
        .map<String>((photo) =>
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photo['photo_reference']}&key=$apiKey")
        .toList();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.kartPlace['name']),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite,
                  color: isTrackAlreadySaved ? Colors.red : Colors.grey),
              onPressed: saveTrack,
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Image Carousel
              CarouselSlider(
                options: CarouselOptions(height: 200.0),
                items: photos.map((photoUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text('Directions'),
                      onPressed: () => _launchURL(),
                    ),
                    ElevatedButton(
                      child: const Text('Record'),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      onPressed: () => _launchCall(phoneNumber),
                      child: const Text('Call'),
                    ),
                  ],
                ),
              ),
              // Track Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Track Detail',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: ${widget.kartPlace['name']}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Address: ${widget.kartPlace['vicinity']}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Phone: $phoneNumber',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Website: $website',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Rating: $rating',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    if (openingHours != null) ...[
                      Text(
                        'Opening Hours:',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      for (var hours in openingHours)
                        Text(
                          hours,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                    ],
                    if (reviews != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Reviews:',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            var review = reviews[index];
                            var reviewText = review['text'];
                            var truncatedReviewText = reviewText.length > 100
                                ? reviewText.substring(0, 100) + '...'
                                : reviewText;

                            return InkWell(
                              onTap: reviewText.length > 100
                                  ? () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(reviewText),
                                          );
                                        },
                                      );
                                    }
                                  : null,
                              child: SizedBox(
                                width: 300, // set the width of the review card
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reviewer: ${review['author_name']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          'Rating: ${review['rating']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'Review: $truncatedReviewText',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]

                    // ...you can add more details here

                    // ...you can add more details here
                  ],
                ),
              ),

              const SizedBox(height: 20)
            ],
          ),
        )));
  }
}
