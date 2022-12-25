class StudentModel {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? branch;
  String? currentYear;
  bool? isDse;
  String? rollNo;
  StudentModel({
    this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.branch,
    this.rollNo,
    this.currentYear,
    this.isDse,
  });

  factory StudentModel.fromMap(map) {
    return StudentModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      branch: map['brnach'],
      rollNo: map['rollNo'],
      currentYear: map['currentYear'],
      isDse: map['isDse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'branch': branch,
      'rollNo': rollNo,
      'currentYear': currentYear,
      'isDse': isDse,
    };
  }
}

class TeacherRole {
  static String get hod => "HOD";
  static String get subjectTeacher => "SUBJECTTEACHER";
  static String get classTeacher => "CLASSTEACHER";
}

class TeacherModel {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? branch;
  String? subject;
  bool? classCoord;

  TeacherModel({
    this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.branch,
    this.subject,
    this.classCoord,
  });

  factory TeacherModel.fromMap(map) {
    return TeacherModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      branch: map['brnach'],
      subject: map['subject'],
      classCoord: map['classCoord'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'branch': branch,
      'subject': subject,
      'classCoord': classCoord,
    };
  }
}

class Subject {
  int? id;
  Branch? branch;
  String name;

  Subject({this.id, this.branch, required this.name});
}

enum Branch {
  IT,
  COMPS,
}
