import 'package:flutter/material.dart';
import 'package:karting_application/RecordPage.dart';
import 'package:karting_application/models/record_model.dart';


class RecordCard extends StatelessWidget {
  final Record record;

  RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.album),
        title: Text(record.trackName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${record.recordDate}'),
            Text('Lap: ${record.recordLap}'),
            Text('Avg Time: ${record.recordAvgTime}'),
            Text('Fastest Lap: ${record.recordFastestLap}'),
            Text('Position: ${record.recordPos}'),
          ],
        ),
      ),
    );
  }
}


