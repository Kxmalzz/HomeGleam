import 'package:flutter/material.dart';
import 'package:my_flutter/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page.dart';
import 'user_home.dart';
import 'work_selection.dart';
import 'date_time_selection.dart';
import 'admin_page.dart';
import 'providerCRUDview.dart'; // Make sure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final lastVisited = prefs.getString('lastVisited') ?? 'home';
    final userRole = prefs.getString('user_role') ?? 'user';

    if (!isLoggedIn) {
      return const SignUpPage();
    }

    switch (lastVisited) {
      case 'dateTime':
        return const DateAndTime(selectedWorks: []);
      case 'workSelection':
        return const WorkSelectionPage();
      case 'admin':
        return AdminPage();
      default:
        final userId = prefs.getString('user_id') ?? 'unknown';
        return userRole == 'admin' ? AdminPage() : UserHomePage(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          title: 'HomeGleam',
          theme: ThemeData(primarySwatch: Colors.blue),
          debugShowCheckedModeBanner: false,
          home: snapshot.data!,
          routes: {
            '/admin': (context) => AdminPage(),
            '/secondLevelItem1': (context) => ProviderCRUDView(), // CRUD route

            '/signin': (context) =>
                LoginPage(), // Replace SignInPage with your widget
            // Other routes...
          },
        );
      },
    );
  }
}
