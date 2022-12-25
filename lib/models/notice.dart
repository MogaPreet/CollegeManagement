class NoticeModel {
  int? id;
  String? url;
  String? title;
  String? desc;
  String? toBranch;
  String? createdAt;
  String? notifiedBy;
  NoticeModel({
    this.id,
    this.url,
    this.title,
    this.desc,
    this.toBranch,
    this.createdAt,
    this.notifiedBy,
  });
  factory NoticeModel.fromMap(map) {
    return NoticeModel(
      id: map['id'],
      url: map['url'],
      title: map['title'],
      desc: map['desc'],
      toBranch: map['toBranch'],
      createdAt: map['createdAt'],
      notifiedBy: map['notifiedBy'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'desc': desc,
      'toBranch': toBranch,
      'createdAt': createdAt,
      'notifiedBy': notifiedBy,
    };
  }
}
