class Task {
  String id;
  String title;
  String priorityLevel;  // Can be 'Low', 'Medium', or 'High'
  String? date;          // Optional field for date
  String? time;          // Optional field for time
  String description;
  bool status;

  Task({
    required this.id,
    required this.title,
    required this.priorityLevel,
    this.date,
    this.time,
    required this.description,
    required this.status
  });

  // Convert Task into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priorityLevel': priorityLevel,
      'date': date,
      'time': time,
      'description': description,
      'status' : status
    };
  }

  // Convert Firestore data into a Task object
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'],
      priorityLevel: map['priorityLevel'],
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'],
      status: map['status']
    );
  }
}
