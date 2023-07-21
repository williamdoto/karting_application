import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/events_model.dart';
import 'CreateEventPage.dart';
import 'EventCard.dart';
import 'dart:async';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _searchController = StreamController<String>();
  final _searchTextStreamController = StreamController<String>();
  String _sortingField = 'eventName';
  String _sortingOrder = 'asc';

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: SearchBar(
          hintText: 'Search Events...',
          onChanged: (value) {
            _searchTextStreamController.add(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: 'eventName', child: Text('Event Name')),
                // Add more fields if necessary
              ],
              onChanged: (value) {
                setState(() {
                  _sortingField = value.toString();
                });
              },
              value: _sortingField,
            ),
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                DropdownMenuItem(value: 'desc', child: Text('Descending')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortingOrder = value.toString();
                });
              },
              value: _sortingOrder,
            ),
            Expanded(
                child: StreamBuilder<String>(
              stream: _searchTextStreamController.stream,
              initialData: '',
              builder: (context, searchSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No events found'));
                    } else {
                      List<Events> events =
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        return Events.fromMap(
                            document.data() as Map<String, dynamic>);
                      }).toList();

                      // Filter the events based on the search text
                      String searchText = searchSnapshot.data!;
                      if (searchText.isNotEmpty) {
                        events = events
                            .where((event) => event.eventName
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                            .toList();
                      }

                      events.sort((a, b) {
                        if (_sortingField == 'eventName') {
                          return _sortingOrder == 'asc'
                              ? a.eventName
                                  .toLowerCase()
                                  .compareTo(b.eventName.toLowerCase())
                              : b.eventName
                                  .toLowerCase()
                                  .compareTo(a.eventName.toLowerCase());
                        }
                        // Add more sorting logic if necessary
                        return 0;
                      });

                      return ListView(
                        children: events.map((Events event) {
                          return EventCard(event: event);
                        }).toList(),
                      );
                    }
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
