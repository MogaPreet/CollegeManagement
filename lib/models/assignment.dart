class AssignMentModel {
  int? id;
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
  AssignMentModel({
    this.id,
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
  });
  factory AssignMentModel.fromMap(map) {
    return AssignMentModel(
      id: map['id'],
      url: map['url'],
      title: map['title'],
      year: map['year'],
      desc: map['desc'],
      toBranch: map['toBranch'],
      assignedDate: map['assignedDate'],
      assignedBy: map['assignedBy'],
      assignedTo: map['assignedTo'],
      lastDate: map['lastDate'],
      subject: map['subject'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
