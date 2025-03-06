import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../screens/edit_task_screen.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final DateTime date;
  final Function(BuildContext, Task) showDeleteConfirmation;

  const TaskItem({
    Key? key,
    required this.task,
    required this.date,
    required this.showDeleteConfirmation,
  }) : super(key: key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _checkmarkOpacityAnimation;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompletedOn(widget.date);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green.shade100,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _checkmarkOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    if (_isCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isCompleted = widget.task.isCompletedOn(widget.date);
    if (_isCompleted) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.toggleTaskCompletion(widget.task.id);

    setState(() {
      _isCompleted = !_isCompleted;
    });

    if (_isCompleted) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showTaskOptions(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit Task'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Task'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTaskScreen(taskId: widget.task.id),
          ),
        );
      } else if (value == 'delete') {
        widget.showDeleteConfirmation(context, widget.task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    _colorAnimation = ColorTween(
      begin: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
      end: isDarkMode ? Color(0xFF1E3B2C) : Color(0xFFE0F2E9),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    return Slidable(
      key: ValueKey(widget.task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(taskId: widget.task.id),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              widget.showDeleteConfirmation(context, widget.task);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: _toggleCompletion,
            onLongPress: () => _showTaskOptions(context),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDarkMode
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.05),
                      blurRadius: isDarkMode ? 3 : 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color:
                        _isCompleted
                            ? isDarkMode
                                ? Color(0xFF2E7D32)
                                : Colors.green.shade300
                            : isDarkMode
                            ? Color(0xFF404040)
                            : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration:
                                    _isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    _isCompleted
                                        ? isDarkMode
                                            ? Color(0xFF9E9E9E)
                                            : Colors.grey
                                        : isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            if (widget.task.description.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.task.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        _isCompleted
                                            ? isDarkMode
                                                ? Color(0xFF9E9E9E)
                                                : Colors.grey
                                            : isDarkMode
                                            ? Color(0xFFE0E0E0)
                                            : Colors.black87,
                                    decoration:
                                        _isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: _checkmarkOpacityAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode ? Color(0xFF2E7D32) : Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
