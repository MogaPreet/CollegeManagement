import 'package:cloud_firestore/cloud_firestore.dart';

class AssignMentModel {
  String? id;
  String? assignmentId;
  String? url;
  String? title;
  String? desc;
  String? year;
  String? toBranch;
  DateTime? assignedDate;
  List<String>? assignedTo;
  DateTime? lastDate;
  String? assignedBy;
  String? subject;
  Timestamp? getAssignDate;
  Timestamp? getLastDate;
  AssignMentModel({
    this.id,
    this.assignmentId,
    this.url,
    this.title,
    this.year,
    this.desc,
    this.toBranch,
    this.assignedDate,
    this.assignedBy,
    this.assignedTo,
    this.lastDate,
    this.subject,
    this.getAssignDate,
    this.getLastDate,
  });
  factory AssignMentModel.fromMap(map) {
    return AssignMentModel(
      id: map['id'],
      assignmentId: map['assignmentId'],
      url: map['url'],
      title: map['title'],
      year: map['year'],
      desc: map['desc'],
      toBranch: map['toBranch'],
      getAssignDate: map['assignedDate'],
      assignedBy: map['assignedBy'],
      assignedTo: map['assignedTo'],
      getLastDate: map['lastDate'],
      subject: map['subject'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'url': url,
      'title': title,
      'year': year,
      'desc': desc,
      'toBranch': toBranch,
      'assignedDate': assignedDate,
      'assignedBy': assignedBy,
      'assignedTo': assignedTo,
      'lastDate': lastDate,
      'subject': subject,
    };
  }
}
