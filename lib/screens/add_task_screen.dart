import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now(); // Default to today
  bool _useStartDate = false; // Toggle for using a custom start date
  bool _isLoading = false;

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
      firstDate: DateTime.now(), // Can't select dates in the past
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
      await Provider.of<TaskProvider>(context, listen: false).addTask(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _useStartDate
            ? _startDate
            : null, // Only use custom start date if toggle is on
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added successfully')));

        // Force a refresh of the tasks
        await Provider.of<TaskProvider>(context, listen: false).loadTasks();

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
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
      appBar: AppBar(title: Text('Add Daily Task')),
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
                title: Text('Set a start date'),
                subtitle: Text('Task will only appear from this date forward'),
                value: _useStartDate,
                onChanged: (value) {
                  setState(() {
                    _useStartDate = value;
                  });
                },
              ),
              if (_useStartDate) ...[
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Save Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
        ),
      ),
    );
  }
}
