import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';

class Attendance {
  String? branch;
  String? year;
  String? subject;
  List<String?>? presentStudents;
  Timestamp? date;

  Attendance({this.branch, this.year, this.subject, this.presentStudents});

  Attendance.fromJson(Map<String, dynamic> json) {
    branch = json['branch'];
    year = json['year'];
    subject = json['subject'];
    presentStudents = toListX(json['presentStudents']);
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['branch'] = branch;
    data['year'] = year;
    data['subject'] = subject;
    data['presentStudents'] = presentStudents;
    data['date'] = date;
    return data;
  }
}
