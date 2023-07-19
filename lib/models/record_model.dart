import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String id;
  final String trackName;
  final DateTime recordDate;
  final int recordLap;
  final String recordAvgTime;
  final String recordFastestLap;
  final int recordPos;
  final int recordTotalRacers;
  final String recordPoleGap;

  Record({
    required this.id,
    required this.trackName,
    required this.recordDate,
    required this.recordLap,
    required this.recordAvgTime,
    required this.recordFastestLap,
    required this.recordPos,
    required this.recordPoleGap,
    required this.recordTotalRacers
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackName': trackName,
      'recordDate': recordDate,
      'recordLap': recordLap,
      'recordAvgTime': recordAvgTime,
      'recordFastestLap': recordFastestLap,
      'recordPos': recordPos,
      'recordPoleGap': recordPoleGap,
      'recordTotalRacers': recordTotalRacers,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as String,
      trackName: map['trackName'] as String,
      recordDate: (map['recordDate'] as Timestamp).toDate(),
      recordLap: map['recordLap'] as int,
      recordAvgTime: map['recordAvgTime'] as String,
      recordFastestLap: map['recordFastestLap'] as String,
      recordPos: map['recordPos'] as int,
      recordTotalRacers: map['recordTotalRacers'] as int,
      recordPoleGap: map['recordPoleGap'] as String,
    );
  }

  // New factory constructor
  factory Record.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    return Record(
      id: doc.id, 
      trackName: data['trackName'] ?? '',
      recordDate: (data['recordDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recordLap: data['recordLap'] ?? 0,
      recordAvgTime: data['recordAvgTime'] ?? '',
      recordFastestLap: data['recordFastestLap'] ?? '',
      recordPos: data['recordPos'] ?? 0,
      recordTotalRacers: data['recordTotalRacers'] ?? 0,
      recordPoleGap: data['recordPoleGap'] ?? '0.000',
    );
  }
}
