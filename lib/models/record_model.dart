import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String trackName;
  final DateTime recordDate;
  final int recordLap;
  final String recordAvgTime;
  final String recordFastestLap;
  final int recordPos;

  Record({
    required this.trackName,
    required this.recordDate,
    required this.recordLap,
    required this.recordAvgTime,
    required this.recordFastestLap,
    required this.recordPos,
  });

  Map<String, dynamic> toMap() {
    return {
      'trackName': trackName,
      'recordDate': recordDate,
      'recordLap': recordLap,
      'recordAvgTime': recordAvgTime,
      'recordFastestLap': recordFastestLap,
      'recordPos': recordPos,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      trackName: map['trackName'] as String,
      recordDate: (map['recordDate'] as Timestamp).toDate(),
      recordLap: map['recordLap'] as int,
      recordAvgTime: map['recordAvgTime'] as String,
      recordFastestLap: map['recordFastestLap'] as String,
      recordPos: map['recordPos'] as int,
    );
  }

  // New factory constructor
  factory Record.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    return Record(
      trackName: data['trackName'] ?? '',
      recordDate: (data['recordDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recordLap: data['recordLap'] ?? 0,
      recordAvgTime: data['recordAvgTime'] ?? '',
      recordFastestLap: data['recordFastestLap'] ?? '',
      recordPos: data['recordPos'] ?? 0,
    );
  }
}
