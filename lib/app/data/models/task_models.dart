class Task {
  final String id;
  String title;
  String description;
  DateTime dateTime;
  bool isCompleted;
  int color;
  String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.color = 0xFFE8C4D8,
    this.category = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'color': color,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      isCompleted: json['isCompleted'] ?? false,
      color: json['color'] ?? 0xFFE8C4D8,
      category: json['category'] ?? '',
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    int? color,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      category: category ?? this.category,
    );
  }
}
