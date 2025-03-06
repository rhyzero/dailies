import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _startDate;
  bool _useCustomStartDate = false;
  DateTime? _originalStartDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Populate form with existing task data
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.tasks.firstWhere(
      (task) => task.id == widget.taskId,
      orElse:
          () => Task(
            id: '',
            title: '',
            description: '',
            createdAt: DateTime.now(),
            startDate: DateTime.now(),
            completionStatus: {},
          ),
    );

    if (task.id.isNotEmpty) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _startDate = task.startDate;
      _originalStartDate = task.startDate;

      // Check if task has a custom start date (not the same as created date)
      final sameDay =
          task.startDate.year == task.createdAt.year &&
          task.startDate.month == task.createdAt.month &&
          task.startDate.day == task.createdAt.day;
      _useCustomStartDate = !sameDay;
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate:
          _originalStartDate ??
          DateTime.now(), // Can't select dates before original start
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TaskProvider>(context, listen: false).editTask(
        widget.taskId,
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _useCustomStartDate ? _startDate : _originalStartDate,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Change start date'),
                subtitle: Text(
                  _originalStartDate != null
                      ? 'Current: ${DateFormat.yMMMMd().format(_originalStartDate!)}'
                      : 'Task will only appear from the start date forward',
                ),
                value: _useCustomStartDate,
                onChanged: (value) {
                  setState(() {
                    _useCustomStartDate = value;
                  });
                },
              ),
              if (_useCustomStartDate) ...[
                SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectStartDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat.yMMMMd().format(_startDate)),
                  ),
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child:
                    _isLoading
                        ? CircularProgressIndicator()
                        : Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
