import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/events_model.dart';
import 'CreateRecordPage.dart';

class EventDetailsPage extends StatefulWidget {
  final Events event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool showFinishButton = true;

  void openRecordPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecordPage(
          trackName: widget.event.trackName,
          eventId: widget.event.id,
        ),
      ),
    );

    if (result != null && result == true) {
      print('Event ID: ${widget.event.id}'); // Print the event ID
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({'isFinished': true})
          .then((_) => print('Event status updated in Firestore'))
          .catchError(
              (error) => print('Failed to update event status: $error'));

      setState(() {
        showFinishButton = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEventStatus();
  }

  void fetchEventStatus() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .get();

    if (doc.exists && doc['isFinished'] == true) {
      setState(() {
        showFinishButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.event.id != null && widget.event.id.isNotEmpty,
        'Event ID is null or empty');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text(
              widget.event.eventName,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${widget.event.eventDate}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Track: ${widget.event.trackName}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Creator ID: ${widget.event.creatorId}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Participants: ${widget.event.participants.join(', ')}',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            if (showFinishButton)
              ElevatedButton(
                onPressed: openRecordPage,
                child: Text('Finish'),
              ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(widget.event.id)
                  .collection('Records')
                  .orderBy('position')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Snapshot Error: ${snapshot.error}');
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                // Transforming documents to List
                List<DocumentSnapshot> records = snapshot.data!.docs;

                print('Number of Records: ${records.length}');

                // Loop through the records list and print each record
                for (var record in records) {
                  print('Record: ${record.data()}');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('User ID: ${records[index]['userId']}'),
                      subtitle:
                          Text('Fastest Lap: ${records[index]['fastestLap']}'),
                      leading: CircleAvatar(
                        child: Text('${records[index]['position']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
