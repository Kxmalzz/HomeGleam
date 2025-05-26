import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_page.dart';
import 'work_selection.dart';

class ConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> provider;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final List<WorkModel> selectedWorks;
  final List<int> selectedExtraCleaning;
  final int selectedRepeat;

  const ConfirmationPage({
    Key? key,
    required this.provider,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedWorks,
    required this.selectedExtraCleaning,
    required this.selectedRepeat,
  }) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool isLoading = false;

  String getValue(String key) =>
      widget.provider[key]?.toString() ?? 'Not found';

  Future<bool> confirmBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
      }
      return false;
    }

    final response = await http.post(
      Uri.parse('http://localhost/my_flutter/flutter_api/confrim_booking.php'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'user_id': userId,
        'provider_id': widget.provider['id'].toString(),
        'selected_works':
            jsonEncode(widget.selectedWorks.map((w) => w.toJson()).toList()),
        'extra_services': jsonEncode(widget.selectedExtraCleaning),
        'booking_date': DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        'booking_time': widget.selectedTime.format(context),
      },
    );

    final res = jsonDecode(response.body);

    if (mounted) {
      if (res['success']) {
        print("Booking confirmed in DB");
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${res['message']}")),
        );
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(widget.selectedDate);
    String formattedTime = widget.selectedTime.format(context);

    final List<String> extraCleaningOptions = [
      'Washing',
      'Fridge',
      'Oven',
      'Window Cleaning'
    ];

    String selectedWorks = widget.selectedWorks.map((w) => w.name).join(", ");
    String selectedExtras = widget.selectedExtraCleaning
        .map((index) => extraCleaningOptions[index])
        .join(", ");

    List<String> repeatTypes = ['no_repeat', 'daily', 'weekly', 'monthly'];
    String repeatType = (widget.selectedRepeat >= 0 &&
            widget.selectedRepeat < repeatTypes.length)
        ? repeatTypes[widget.selectedRepeat]
        : 'no_repeat';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Booking Confirmation",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[400],
                    child:
                        const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  title: Text(
                    getValue('name'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getValue('email')),
                      Text(getValue('phone')),
                    ],
                  ),
                ),
                const Divider(height: 30),
                infoRow("Date", formattedDate),
                infoRow("Time", formattedTime),
                infoRow("Selected Works", selectedWorks),
                infoRow("Extra Services",
                    selectedExtras.isNotEmpty ? selectedExtras : "None"),
                infoRow("Frequency", repeatType),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          provider: widget.provider,
                          date: widget.selectedDate,
                          time: widget.selectedTime,
                          selectedWorks: widget.selectedWorks,
                          selectedExtraCleaning: widget.selectedExtraCleaning,
                          selectedRepeat: widget.selectedRepeat,
                        ),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.payment, color: Colors.white, size: 20),
                  label: const Text(
                    "Proceed to Payment",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(45),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
