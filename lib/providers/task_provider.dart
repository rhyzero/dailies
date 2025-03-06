import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // Get collection reference for current user
  CollectionReference get _tasksCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Set selected date and refresh tasks
  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  // Load tasks from Firestore
  Future<void> loadTasks() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _tasksCollection.get();
      _tasks =
          snapshot.docs
              .map(
                (doc) =>
                    Task.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<void> addTask(
    String title,
    String description,
    DateTime? startDate,
  ) async {
    try {
      final now = DateTime.now();
      // If no start date is provided, use today's date
      final taskStartDate = startDate ?? now;

      final newTask = Task(
        id: '', // Firestore will generate ID
        title: title,
        description: description,
        createdAt: now,
        startDate: taskStartDate,
        completionStatus: {},
      );

      final docRef = await _tasksCollection.add(newTask.toMap());
      final addedTask = Task(
        id: docRef.id,
        title: title,
        description: description,
        createdAt: now,
        startDate: taskStartDate,
        completionStatus: {},
      );

      _tasks.add(addedTask);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex < 0) return;

      final updatedTask = _tasks[taskIndex].toggleCompletion(_selectedDate);
      _tasks[taskIndex] = updatedTask;

      await _tasksCollection.doc(taskId).update({
        'completionStatus': updatedTask.completionStatus,
      });

      notifyListeners();
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Edit task details
  Future<void> editTask(
    String taskId,
    String title,
    String description,
    DateTime? startDate,
  ) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex < 0) return;

      final currentTask = _tasks[taskIndex];
      // If no new start date is provided, keep the existing one
      final taskStartDate = startDate ?? currentTask.startDate;

      final updatedTask = Task(
        id: taskId,
        title: title,
        description: description,
        createdAt: currentTask.createdAt,
        startDate: taskStartDate,
        completionStatus: currentTask.completionStatus,
      );

      await _tasksCollection.doc(taskId).update({
        'title': title,
        'description': description,
        'startDate': Timestamp.fromDate(taskStartDate),
      });

      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      print('Error editing task: $e');
      rethrow;
    }
  }
}
