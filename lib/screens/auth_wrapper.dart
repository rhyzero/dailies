import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If connection state is waiting and we don't have previous data,
        // show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If we have user data, show the main app
        if (snapshot.hasData) {
          print("Auth state changed: User is signed in");
          return const MainPageView();
        }

        // Otherwise, show the login screen
        print("Auth state changed: No user detected");
        return const LoginScreen();
      },
    );
  }
}
