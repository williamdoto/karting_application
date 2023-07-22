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
  final String eventId; // new field
  final String userId; // new field

  Record({
    required this.id,
    required this.trackName,
    required this.recordDate,
    required this.recordLap,
    required this.recordAvgTime,
    required this.recordFastestLap,
    required this.recordPos,
    required this.recordPoleGap,
    required this.recordTotalRacers,
    required this.eventId, // new field
    required this.userId, // new field
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
      'eventId': eventId, // new field
      'userId': userId, // new field
    };
  }

  // Updated factory constructor
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
      eventId: data['eventId'] ?? '', // new field
      userId: data['userId'] ?? '', // new field
    );
  }
}
