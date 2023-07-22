import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateRecordPage extends StatefulWidget {
  final String? trackName;

  const CreateRecordPage({Key? key, this.trackName}) : super(key: key);
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
  String _recordLap = '0';
  String _recordAvgTime = '';
  String _recordFastestLap = '';
  String _recordPos = '0';
  String _recordPoleGap = '0.000';
  String _recordTotalRacers = '0';

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _fetchUser();
    _trackName = widget.trackName ?? '';
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
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Add Record')),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Track Name
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Track Name',
                    ),
                    initialValue: _trackName,
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
                      labelText: 'Lap Number',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recordLap = value;
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
                      labelText: 'Position',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recordPos = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a position';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Total No. Racers',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recordTotalRacers = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a position';
                      }
                      return null;
                    },
                  ),
                  if (_recordPos != '1')
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Pole Gap (s.sss or ss.sss)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _recordPoleGap = value;
                        });
                      },
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^\d{1,2}\.\d{3}$').hasMatch(value)) {
                          return 'Please enter a valid time (s.sss or ss.sss)';
                        }
                        return null;
                      },
                    ),

                  // Save Button
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text(
                      'Save Record',
                      style: const TextStyle(
                        color:const Color(0xffE8EBFF), // Change text color
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color(0xff5E2CED), // Change button color
                      ),
                    ),
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
                          'recordLap': int.parse(_recordLap),
                          'recordAvgTime': _recordAvgTime,
                          'recordFastestLap': _recordFastestLap,
                          'recordPos': int.parse(_recordPos),
                          'recordPoleGap': _recordPoleGap,
                          'recordTotalRacers': int.parse(_recordTotalRacers),
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
