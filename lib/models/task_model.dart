import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime startDate;
  final Map<String, bool> completionStatus;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.startDate,
    required this.completionStatus,
  });

  // Check if task is completed for a specific date
  bool isCompletedOn(DateTime date) {
    String dateKey = _dateToKey(date);
    return completionStatus[dateKey] ?? false;
  }

  // Check if task should be visible for a specific date
  bool isVisibleOn(DateTime date) {
    // Only show the task if the provided date is on or after the start date
    return !date.isBefore(
      DateTime(startDate.year, startDate.month, startDate.day),
    );
  }

  // Toggle completion status for a specific date
  Task toggleCompletion(DateTime date) {
    // Only allow toggling for dates on or after the start date
    if (!isVisibleOn(date)) return this;

    String dateKey = _dateToKey(date);
    Map<String, bool> updatedStatus = Map.from(completionStatus);
    updatedStatus[dateKey] = !(completionStatus[dateKey] ?? false);

    return Task(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      startDate: startDate, // Include start date
      completionStatus: updatedStatus,
    );
  }

  // Convert date to string key format (yyyy-mm-dd)
  static String _dateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Create Task from Firestore document
  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      startDate:
          map['startDate'] != null
              ? (map['startDate'] as Timestamp).toDate()
              : (map['createdAt'] as Timestamp)
                  .toDate(), // Default to createdAt
      completionStatus: Map<String, bool>.from(map['completionStatus'] ?? {}),
    );
  }

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': Timestamp.fromDate(startDate),
      'completionStatus': completionStatus,
    };
  }
}
