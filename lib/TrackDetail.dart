import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class TrackDetail extends StatelessWidget {
  final Map<String, dynamic> kartPlace;

  // TrackDetail constructor
  const TrackDetail({Key? key, required this.kartPlace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String apiKey = 'AIzaSyDINb5jEJSNl4aLsbGCBXSiImHMTnajoGw'; // Enter your Google API Key
    List<String> photos = kartPlace['photos']
        .map<String>((photo) =>
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photo['photo_reference']}&key=$apiKey")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(kartPlace['name']),
      ),
      body: Column(
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
          SizedBox(height: 20),
          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: Text('Directions'),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: Text('Record'),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: Text('Button 3'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Track Details
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Track Detail',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 20),
                Text(
                  'Name: ${kartPlace['name']}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  'Address: ${kartPlace['vicinity']}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                // ...you can add more details here
              ],
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
