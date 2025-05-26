import 'package:flutter/material.dart';
import 'package:my_flutter/work_selection.dart';
import 'package:my_flutter/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserHomePage extends StatefulWidget {
  final String userId;

  const UserHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String userName = "User"; // Default name
  String userEmail = "user@example.com"; // Default email

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.167.129/my_flutter/flutter_api/viewprofile.php'),
        body: {'user_id': widget.userId},
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          userName = data['name'];
          userEmail = data['email'];
        });
      } else {
        showErrorDialog(data['message']);
      }
    } catch (e) {
      showErrorDialog('Error fetching user data: $e');
    }
  }

  void showErrorDialog(String message) {}

  void _logout() {
    Navigator.pushReplacement(context, LoginPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Welcome, $userName",
            style: const TextStyle(color: Colors.black)),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == "Profile") {
                showProfileDialog();
              } else if (value == "Logout") {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "Profile", child: Text("View Profile")),
              PopupMenuItem(value: "Logout", child: Text("Logout")),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "HOMEGLEAM",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 26, 5, 119),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Bringing cleanliness & comfort to your home.",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    color:
                        const Color.fromARGB(255, 23, 19, 87).withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 200),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WorkSelectionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 25),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text("Get Started!",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Name: $userName"),
            Text("Email: $userEmail"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
