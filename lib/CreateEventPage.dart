import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/events_model.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  DateTime _eventDate = DateTime.now();
  final _trackNameController = TextEditingController();
  List<TextEditingController> _participantControllers = [];
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _eventNameController.dispose();
    _trackNameController.dispose();
    _participantControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              ListTile(
                title: Text("Event Date: ${_eventDate.toIso8601String().substring(0,10)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _trackNameController,
                decoration: InputDecoration(labelText: 'Track Name'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _participantControllers.length,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: _participantControllers[index],
                    decoration: InputDecoration(labelText: 'Participant ID'),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _participantControllers.add(TextEditingController());
                  });
                },
                child: Text('Add Participant'),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date != null) {
      setState(() {
        _eventDate = date;
      });
    }
  }

void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final eventName = _eventNameController.text;
      final trackName = _trackNameController.text;
      final creatorId = _auth.currentUser!.uid;
      final participants = _participantControllers.map((controller) => controller.text).toList();
      DocumentReference docRef = FirebaseFirestore.instance.collection('events').doc();
      final newEvent = Events(
        id: docRef.id, 
        eventName: eventName,
        eventDate: _eventDate,
        creatorId: creatorId,
        trackName: trackName,
        participants: participants, isFinished: false,
      );

      docRef.set(newEvent.toMap());
      Navigator.pop(context, true);
    }
  }

}
