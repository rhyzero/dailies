import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_page_view.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/convert_account_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Daily Tracker',
            theme: themeProvider.themeData,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/reset_password': (context) => const ResetPasswordScreen(),
              '/convert_account': (context) => const ConvertAccountScreen(),
              '/account_settings': (context) => const AccountSettingsScreen(),
              '/add_task': (context) => const AddTaskScreen(),
              '/home': (context) => const MainPageView(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
