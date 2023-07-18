import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karting_application/RecordCard.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'package:karting_application/models/record_model.dart';
import 'dart:async';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _searchController = StreamController<String>();
  final _auth = FirebaseAuth.instance;
  late User user;
  String _sortingField = 'recordDate';
  String _sortingOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    User currentUser = _auth.currentUser!;
    setState(() {
      user = currentUser;
    });
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUser(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 120,
              title: SearchBar(
                hintText: 'Search...',
                onChanged: (value) {
                  _searchController.add(value);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return const FractionallySizedBox(
                          heightFactor: 0.8,
                          child: CreateRecordPage(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                          value: 'recordDate', child: Text('Date')),
                      DropdownMenuItem(
                          value: 'recordFastestLap',
                          child: Text('Fastest Lap')),
                      DropdownMenuItem(
                          value: 'recordAvgTime', child: Text('Avg Time')),
                      DropdownMenuItem(
                          value: 'recordTrackName', child: Text('Track Name')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortingField = value.toString();
                      });
                    },
                    value: _sortingField,
                  ),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                      DropdownMenuItem(
                          value: 'desc', child: Text('Descending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortingOrder = value.toString();
                      });
                    },
                    value: _sortingOrder,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('User')
                          .doc(user.uid)
                          .collection('Record')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No records found'));
                        } else {
                          List<Record> records = snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return Record.fromDocumentSnapshot(document);
                          }).toList();

                          records.sort((a, b) {
                            if (_sortingField == 'recordTrackName') {
                              return _sortingOrder == 'asc'
                                  ? a.trackName
                                      .toLowerCase()
                                      .compareTo(b.trackName.toLowerCase())
                                  : b.trackName
                                      .toLowerCase()
                                      .compareTo(a.trackName.toLowerCase());
                            }

                            double aValue = 0.0;
                            double bValue = 0.0;

                            switch (_sortingField) {
                              case 'recordFastestLap':
                                aValue = _convertTimeStringToSeconds(
                                    a.recordFastestLap);
                                bValue = _convertTimeStringToSeconds(
                                    b.recordFastestLap);
                                break;
                              case 'recordAvgTime':
                                aValue = _convertTimeStringToSeconds(
                                    a.recordAvgTime);
                                bValue = _convertTimeStringToSeconds(
                                    b.recordAvgTime);
                                break;
                              case 'recordDate':
                                aValue = a.recordDate.millisecondsSinceEpoch
                                    .toDouble();
                                bValue = b.recordDate.millisecondsSinceEpoch
                                    .toDouble();
                                break;
                            }

                            return _sortingOrder == 'asc'
                                ? aValue.compareTo(bValue)
                                : bValue.compareTo(aValue);
                          });

                          return ListView(
                            children: records.map((Record record) {
                              return RecordCard(record: record);
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  double _convertTimeStringToSeconds(String timeString) {
    var timeParts = timeString.split(':');
    if (timeParts.length > 1) {
      var minutePart = double.parse(timeParts[0]);
      var secondPart = double.parse(timeParts[1]);
      return minutePart * 60 + secondPart;
    } else {
      return double.parse(timeString);
    }
  }
}
