class Email {
  String sender;
  String subject;
  String content;
  DateTime time;
  List<String> attachments;
  bool isDraft;
  bool isStarred;
  bool isRead;
  bool isInTrash;
  List<String> labels;

  Email({
    required this.sender,
    required this.subject,
    required this.content,
    required this.time,
    this.attachments = const [],
    this.isDraft = false,
    this.isStarred = false,
    this.isRead = false,
    this.isInTrash = false,
    this.labels = const [],
  });
}

extension EmailCopyWith on Email {
  Email copyWith({
    String? sender,
    String? subject,
    String? content,
    DateTime? time,
    List<String>? attachments,
    bool? isDraft,
    bool? isStarred,
    bool? isRead,
    bool? isInTrash,
    List<String>? labels,
  }) {
    return Email(
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      time: time ?? this.time,
      attachments: attachments ?? this.attachments,
      isDraft: isDraft ?? this.isDraft,
      isStarred: isStarred ?? this.isStarred,
      isRead: isRead ?? this.isRead,
      isInTrash: isInTrash ?? this.isInTrash,
      labels: labels ?? this.labels,
    );
  }
}