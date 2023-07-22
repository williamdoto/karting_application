import 'package:cloud_firestore/cloud_firestore.dart';

class Events {
  final String id;
  final String eventName;
  final DateTime eventDate;
  final String trackName;
  final String creatorId;
  final List<String> participants;
  final bool isFinished;

  Events({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.trackName,
    required this.creatorId,
    required this.participants,
    required this.isFinished,  // Add isFinished field
  });

  factory Events.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Events(
      id: id,
      eventName: map['eventName'] as String,
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      trackName: map['trackName'] as String,
      creatorId: map['creatorId'] as String,
      participants: List<String>.from(map['participants'] as List<dynamic>),
      isFinished: map['isFinished'] as bool ?? false,  // Add isFinished field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDate': eventDate,
      'trackName': trackName,
      'creatorId': creatorId,
      'participants': participants,
      'isFinished': isFinished,  // Add isFinished field
    };
  }
}
