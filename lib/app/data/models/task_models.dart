class Task {
  String id;
  String title;
  String description;
  DateTime dateTime;
  int color;
  String category;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.color,
    this.category = '',
    this.isCompleted = false,
  });

  // From JSON (untuk GetStorage - backward compatibility)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      color: json['color'] as int,
      category: json['category'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  // From Supabase (field names berbeda)
  factory Task.fromSupabase(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(), // bigint jadi string
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dateTime: DateTime.parse(json['due_date'] as String),
      // Tambahkan alpha channel (0xFF) ke nilai warna yang disimpan
      color: (json['color'] as int? ?? 0xE8C4D8) | 0xFF000000,
      category: '', // Tidak ada di tabel Supabase
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  // To JSON (untuk GetStorage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'color': color,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  // To Supabase format
  Map<String, dynamic> toSupabase(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dateTime.toIso8601String(),
      'color': color,
    };
  }

  // Copy with method
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    int? color,
    String? category,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      color: color ?? this.color,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}