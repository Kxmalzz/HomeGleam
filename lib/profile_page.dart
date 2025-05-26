import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'confirmation_page.dart';
import 'work_selection.dart';

class ProfilePage extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final List<WorkModel> selectedWorks; // <-- Add this
  final List<int> selectedExtraCleaning;
  final int selectedRepeat;

  const ProfilePage(
      {Key? key,
      required this.selectedDate,
      required this.selectedTime,
      required this.selectedWorks, // <-- And here
      required this.selectedExtraCleaning,
      required this.selectedRepeat})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> serviceProviders = [];

  List<Map<String, dynamic>> filteredProviders = [];

  final String apiUrl =
      'http://localhost/my_flutter/flutter_api/crud.php'; // replace with your IP if testing on device

  @override
  void initState() {
    super.initState();

    fetchProviders();

    setLastVisited('profile');
  }

  Future<void> fetchProviders() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          serviceProviders = List<Map<String, dynamic>>.from(data);

          filteredProviders = serviceProviders;
        });
      } else {
        throw Exception('Failed to load providers');
      }
    } catch (e) {
      print("Error fetching providers: $e");
    }
  }

  void _filterProviders(String query) {
    setState(() {
      filteredProviders = serviceProviders
          .where((provider) => provider["name"]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> setLastVisited(String page) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastVisited', page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Providers"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Bar

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProviders,
              decoration: InputDecoration(
                hintText: "Search Service Providers",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // Provider List

          Expanded(
            child: filteredProviders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];

                      return FadeInUp(
                        delay: Duration(milliseconds: 200 * index),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.green.shade100,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[400],
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                            title: Text(
                              provider["name"] ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(provider["phone"] ?? '',
                                    style: const TextStyle(fontSize: 14)),
                                Text(provider["email"] ?? '',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600)),
                                const SizedBox(height: 5),
                                RatingBarIndicator(
                                  rating: double.tryParse(
                                          provider['rating']?.toString() ??
                                              '0') ??
                                      0.0,
                                  itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.orange),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                ),
                              ],
                            ),
                            trailing: BounceInUp(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConfirmationPage(
                                        provider: provider,
                                        selectedDate: widget.selectedDate,
                                        selectedTime: widget.selectedTime,
                                        selectedWorks:
                                            widget.selectedWorks, // Pass works
                                        selectedExtraCleaning:
                                            widget.selectedExtraCleaning,
                                        selectedRepeat: widget.selectedRepeat,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text("Book Now"),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
