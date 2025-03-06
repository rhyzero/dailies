import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../models/task_model.dart';
import 'calendar_screen.dart';
import 'main_page_view.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).loadTasks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedDate = taskProvider.selectedDate;
    final formattedDate = DateFormat.yMMMMd().format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Tasks'),
        actions: [
          // Dark mode toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip:
                themeProvider.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
          ),
          // Account settings button
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // For both regular and anonymous users, navigate to the appropriate account screen
              final user = authProvider.currentUser;
              if (user != null && user.isAnonymous) {
                Navigator.pushNamed(context, '/convert_account');
              } else {
                Navigator.pushNamed(context, '/account_settings');
              }
            },
            tooltip: 'Account Settings',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await authProvider.signOut();
                // The AuthWrapper will automatically redirect to login screen
                // But we can also force navigation for immediate feedback
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Anonymous user banner
          if (authProvider.currentUser != null &&
              authProvider.currentUser!.isAnonymous)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color:
                  themeProvider.isDarkMode
                      ? Color(0xFF332D00)
                      : Colors.amber.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.amber[300]
                            : Colors.amber.shade800,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You're using this app as a guest. Your data won't be saved if you log out.",
                      style: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.amber[300]
                                : Colors.amber.shade800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/convert_account');
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color:
                            themeProvider.isDarkMode ? Colors.amber[400] : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Date header
          Container(
            padding: EdgeInsets.all(16),
            color:
                themeProvider.isDarkMode
                    ? Color(0xFF1E1E1E)
                    : Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.swipe_right,
                        size: 18,
                        color:
                            themeProvider.isDarkMode
                                ? Colors.blue[300]
                                : Colors.blue,
                      ),
                      label: Text(
                        'Swipe right for calendar',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        // Find the MainPageView and navigate to calendar
                        final pageViewState =
                            context
                                .findAncestorStateOfType<MainPageViewState>();
                        if (pageViewState != null) {
                          pageViewState.navigateToCalendar();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalendarScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Task list
          Expanded(
            child:
                taskProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : taskProvider.tasks.isEmpty
                    ? Center(
                      child: Text('No daily tasks yet. Add your first one!'),
                    )
                    : ListView.builder(
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        // Only show tasks that are visible on the selected date
                        if (!task.isVisibleOn(selectedDate)) {
                          return SizedBox.shrink(); // Don't show this task
                        }
                        return TaskItem(
                          task: task,
                          date: selectedDate,
                          showDeleteConfirmation: _showDeleteConfirmation,
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/add_task');
        },
        child: Container(
          height: 60,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color:
                themeProvider.isDarkMode
                    ? Colors.blue[700]
                    : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color:
                    themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Add New Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).deleteTask(task.id);
                  Navigator.pop(context);
                },
                child: Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
