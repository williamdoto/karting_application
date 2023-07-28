import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karting_application/RecordCard.dart';
import 'package:karting_application/CreateRecordPage.dart';
import 'package:karting_application/models/record_model.dart';
import 'dart:async';

class AppColors {
  static const Color backgroundColor = Color(0xffE8EBFF);
  // You can define more colors here
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  // final _searchController = StreamController<String>();
  final _searchController = StreamController<String>.broadcast();

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
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    // You can return different colors based on the states.
                    // For example, if the widget is pressed, hovered, focused, selected etc.
                    // But if you want the same color for all states, ignore the states.
                    return AppColors.backgroundColor;
                  },
                ),
                onChanged: (value) {
                  _searchController.add(value);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  color: Color(0xff5E2CED),
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
                    // set the color of the dropdown
                    style: TextStyle(
                        color: Color(0xff5E2CED)), // set the color of the text
                    items: const [
                      DropdownMenuItem(
                          value: 'recordDate', child: Text('Date')),
                      DropdownMenuItem(
                          value: 'recordFastestLap',
                          child: Text('Fastest Lap')),
                      DropdownMenuItem(
                          value: 'recordAvgTime', child: Text('Avg Time')),
                      DropdownMenuItem(
                          value: 'trackName', child: Text('Track Name')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortingField = value.toString();
                      });
                    },
                    value: _sortingField,
                  ),
                  DropdownButtonFormField(
                    style: TextStyle(
                        color: Color(0xff5E2CED)), // set the color of the text
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
                    child: StreamBuilder<String>(
                      stream: _searchController.stream,
                      initialData: '',
                      builder: (BuildContext context,
                          AsyncSnapshot<String> searchSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('User')
                              .doc(user.uid)
                              .collection('Record')
                              .orderBy(_sortingField, descending: _sortingOrder == 'desc')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No records found'));
                            } else {
                              List<Record> records = snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return Record.fromDocumentSnapshot(document);
                              }).toList();

                              // Filter the records based on the search term.
                              String searchTerm = searchSnapshot.data!;
                              List<Record> filteredRecords =
                                  records.where((record) {
                                return record.trackName
                                    .toLowerCase()
                                    .contains(searchTerm.toLowerCase());
                              }).toList();

                              // Use `filteredRecords` instead of `records`
                              return ListView(
                                children: filteredRecords.map((Record record) {
                                  return Dismissible(
                                    key: Key(record.id),
                                    onDismissed: (direction) {
                                      // ...
                                    },
                                    background: Container(color: Colors.red),
                                    child: RecordCard(record: record),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        );
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
