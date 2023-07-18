import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karting_application/RecordPage.dart';
import 'package:karting_application/models/record_model.dart';

class RecordCard extends StatefulWidget {
  final Record record;

  RecordCard({required this.record});

  @override
  _RecordCardState createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.sports_score),
        title: Text(
          widget.record.trackName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        subtitle: Text(
          'Date: ${DateFormat('yyyy-MM-dd').format(widget.record.recordDate)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        children: <Widget>[
          ListTile(
            title: Text('Lap: ${widget.record.recordLap}'),
          ),
          ListTile(
            title: Text('Avg Time: ${widget.record.recordAvgTime}'),
          ),
          ListTile(
            title: Text('Fastest Lap: ${widget.record.recordFastestLap}'),
          ),
                    ListTile(
            title: Text('Gap to Pole: ${widget.record.recordPoleGap}'),
          ),
          ListTile(
            title: Text('Position: ${widget.record.recordPos}'),
          ),
                              ListTile(
            title: Text('Total Racers: ${widget.record.recordTotalRacers}'),
          ),
        ],
      ),
    );
  }
}
