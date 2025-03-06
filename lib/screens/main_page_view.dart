import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => MainPageViewState();
}

// Make the state class public by removing the underscore
class MainPageViewState extends State<MainPageView> {
  final PageController _pageController = PageController(initialPage: 0);

  // Public method to navigate to the home page
  void navigateToHome() {
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Public method to navigate to the calendar page
  void navigateToCalendar() {
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        HomeScreen(),
        CalendarScreen(
          onDaySelected: () {
            navigateToHome();
          },
        ),
      ],
    );
  }
}
