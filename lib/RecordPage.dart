import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karting_application/RecordCard.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'package:karting_application/models/record_model.dart';
import 'dart:async';

class RecordPage extends StatefulWidget {
  final String userId;

  RecordPage({required this.userId});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _searchController = StreamController<String>();

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(hintText: 'Search...'),
          onChanged: (value) {
            _searchController.add(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateRecordPage(userId: widget.userId)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<String>(
        stream: _searchController.stream,
        builder: (context, snapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User')
                .doc(widget.userId)
                .collection('Record')
                .orderBy('trackName')
                .startAt([snapshot.data ?? ''])
                .endAt([snapshot.data != null ? '${snapshot.data}~' : '\uf8ff'])
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No records found'));
              } else {
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Record record = Record.fromDocumentSnapshot(document);
                    return RecordCard(record: record);
                  }).toList(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
