import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final String? locationType;
  final double? fee;
  final DateTime? startDate;
  final DateTime? endDate;
  final String time;
  final List<String> teamMembers;
  final int? estimatedAttendees;
  final String? estimatedBudget; // Add this line for the budget
  final bool? budgetConfirmed;   // Add this for budget confirmation status
  final int? totalDays;
  final Timestamp? createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.locationType,
    this.fee,
    this.startDate,
    this.endDate,
    required this.time,
    required this.teamMembers,
    this.estimatedAttendees,
    this.estimatedBudget,   // Add this parameter
    this.budgetConfirmed,   // Add this parameter
    this.totalDays,
    this.createdAt,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      locationType: map['locationType'],
      fee: map['fee']?.toDouble(),
      startDate: map['startDate'] != null 
          ? (map['startDate'] as Timestamp).toDate() 
          : null,
      endDate: map['endDate'] != null 
          ? (map['endDate'] as Timestamp).toDate() 
          : null,
      time: map['time'] ?? '',
      teamMembers: List<String>.from(map['teamMembers'] ?? []),
      estimatedAttendees: map['estimatedAttendees'],
      estimatedBudget: map['estimatedBudget'],   // Add this field mapping
      budgetConfirmed: map['budgetConfirmed'],   // Add this field mapping
      totalDays: map['totalDays'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'locationType': locationType,
      'fee': fee,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'time': time,
      'teamMembers': teamMembers,
      'estimatedAttendees': estimatedAttendees,
      'estimatedBudget': estimatedBudget,   // Add this field mapping
      'budgetConfirmed': budgetConfirmed,   // Add this field mapping
      'totalDays': totalDays,
      'createdAt': createdAt,
    };
  }
}