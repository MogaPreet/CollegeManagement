import 'package:cms/models/user.dart';

class Subject {
  String? year;
  List<String>? aids;
  List<String>? civilEngg;
  List<String>? compsEngg;
  List<String>? electricalEngg;
  List<String>? electronicEngg;
  List<String>? infoTech;
  List<String>? mechEngg;
  List<String>? allSub;

  Subject({
    this.year,
    this.aids,
    this.civilEngg,
    this.compsEngg,
    this.electricalEngg,
    this.electronicEngg,
    this.infoTech,
    this.mechEngg,
    this.allSub,
  });

  factory Subject.fromMap(
    map,
  ) {
    return Subject(
      year: map['year'],
      aids: toListX(map['Artificial Intelligence & Data Science']),
      civilEngg: toListX(map['Civil Engineering']),
      compsEngg: toListX(map['Computer Engineering']),
      electricalEngg: toListX(map['Electrical Engineering']),
      electronicEngg: toListX(map['Electronics Engineering']),
      infoTech: toListX(map['Information Technology']),
      mechEngg: toListX(map['Mechanical Engineering']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'Artificial Intelligence & Data Science': aids,
      'Civil Engineering': civilEngg,
      'Computer Engineering': compsEngg,
      'Electrical Engineering': electricalEngg,
      'Electronics Engineering': electronicEngg,
      'Information Technology': infoTech,
      'Mechanical Engineering': mechEngg,
    };
  }
}

class TeacherSubjects {
  String? year;
  List<String>? subjects;

  TeacherSubjects({this.year, this.subjects});

  TeacherSubjects.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    subjects = toListX(json['subjects']);
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'subjects': subjects,
    };
  }
}
