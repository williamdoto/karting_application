import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import your Event and CreateEventPage model here
import 'models/events_model.dart';
import 'CreateEventPage.dart';
import 'EventCard.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Events> eventsList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            getEvents(), // Implement this function to fetch data from Firestore
        builder: (BuildContext context, AsyncSnapshot<List<Events>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              eventsList = snapshot.data!;
              return ListView.builder(
                itemCount: eventsList.length,
                itemBuilder: (context, index) {
                  return EventCard(event: eventsList[index]);
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<List<Events>> getEvents() async {
    var snapshot = await FirebaseFirestore.instance.collection('events').get();
    return snapshot.docs
        .map<Events>((doc) => Events.fromMap(doc.data()))
        .toList();
  }
}
