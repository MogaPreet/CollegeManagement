import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final List<String> teamMembers;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.teamMembers,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      teamMembers: toListX(data['teamMembers']),
    );
  }
}
