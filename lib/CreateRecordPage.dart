import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateRecordPage extends StatefulWidget {
  @override
  _CreateRecordPageState createState() => _CreateRecordPageState();
}

class _CreateRecordPageState extends State<CreateRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late User user;
  late Future<void> _fetchUserFuture;
  String _trackName = '';
  DateTime _recordDate = DateTime.now();
  int _recordLap = 0;
  String _recordAvgTime = '';
  String _recordFastestLap = '';
  int _recordPos = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _fetchUser();
  }

  Future<void> _fetchUser() async {
    User currentUser = _auth.currentUser!;
    setState(() {
      user = currentUser;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Add Record')),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Track Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Track Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _trackName = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a track name';
                      }
                      return null;
                    },
                  ),

                  // Record Date
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Record Date',
                    ),
                    initialValue: DateFormat('yyyy-MM-dd').format(_recordDate),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _recordDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _recordDate = date;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a record date';
                      }
                      return null;
                    },
                  ),

                  // Record Lap
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lap Number',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recordLap = int.parse(value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a lap number';
                      }
                      return null;
                    },
                  ),

                  // Avg Time
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Average Time (m:ss.sss or ss.sss)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _recordAvgTime = value;
                      });
                    },
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^(\d+:\d{2}\.\d{3}|\d{2}\.\d{3})$')
                              .hasMatch(value)) {
                        return 'Please enter a valid time (m:ss.sss or ss.sss)';
                      }
                      return null;
                    },
                  ),

                  // Fastest Lap
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Fastest Lap Time (m:ss.sss or ss.sss)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _recordFastestLap = value;
                      });
                    },
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^(\d+:\d{2}\.\d{3}|\d{2}\.\d{3})$')
                              .hasMatch(value)) {
                        return 'Please enter a valid time (m:ss.sss or ss.sss)';
                      }
                      return null;
                    },
                  ),

                  // Record Position
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Position',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recordPos = int.parse(value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a position';
                      }
                      return null;
                    },
                  ),

                  // Save Button
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Save Record'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Save record to Firestore
                        await FirebaseFirestore.instance
                            .collection('User')
                            .doc(user.uid)
                            .collection('Record')
                            .add({
                          'trackName': _trackName,
                          'recordDate': _recordDate,
                          'recordLap': _recordLap,
                          'recordAvgTime': _recordAvgTime,
                          'recordFastestLap': _recordFastestLap,
                          'recordPos': _recordPos,
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

