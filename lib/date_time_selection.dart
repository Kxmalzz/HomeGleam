import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter/work_selection.dart';
import 'profile_page.dart'; // Navigate to Profile Page
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DateAndTime extends StatefulWidget {
  final List<WorkModel> selectedWorks;

  const DateAndTime({Key? key, required this.selectedWorks}) : super(key: key);

  @override
  _DateAndTimeState createState() => _DateAndTimeState();
}

class _DateAndTimeState extends State<DateAndTime> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedRepeat = 0;
  List<int> _selectedExtraCleaning = [];
  bool _isSubmitted = false;

  final List<String> _repeatOptions = [
    'No repeat',
    'Every day',
    'Every week',
    'Every month'
  ];

  final List<dynamic> _extraCleaning = [
    ['Washing', 'https://img.icons8.com/office/2x/washing-machine.png', '10'],
    ['Fridge', 'https://img.icons8.com/cotton/2x/fridge.png', '8'],
    [
      'Oven',
      'https://img.icons8.com/external-becris-lineal-color-becris/2x/external-oven-kitchen-cooking-becris-lineal-color-becris.png',
      '8'
    ],
    [
      'Windows',
      'https://img.icons8.com/external-kiranshastry-lineal-color-kiranshastry/2x/external-window-interiors-kiranshastry-lineal-color-kiranshastry-1.png',
      '20'
    ],
  ];

  @override
  void initState() {
    super.initState();
    setLastVisited('dateTime');
  }

  Future<void> setLastVisited(String _) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVisited', 'date_time');
  }

  Future<void> _pickDate(BuildContext context) async {
    if (_selectedRepeat == 1) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous page
          },
        ),
        title: Text("Date & Time"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,

      // AppBar and Design Remain Same...
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isSubmitted) return;

          if (_selectedRepeat != 1 &&
              (_selectedDate == null || _selectedTime == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select both date and time!")),
            );
            return;
          }

          setState(() {
            _isSubmitted = true;
          });

          try {
            final postData = {
              "user_id": "123",
              "date": _selectedDate != null
                  ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                  : DateTime.now().toIso8601String().split('T').first,
              "time": _selectedTime != null
                  ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                  : "${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}",
              "repeat": _repeatOptions[_selectedRepeat],
              "works": widget.selectedWorks
                  .map((w) => {
                        "name": w.name,
                        "count": w.count,
                        "iconUrl": w.iconUrl,
                        "color": w.color.value,
                      })
                  .toList(),
              "extra_services": _selectedExtraCleaning
                  .map((index) => _extraCleaning[index][0])
                  .toList()
            };

            final response = await http.post(
              Uri.parse(
                  'http://localhost/my_flutter/flutter_api/submit_dt.php'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(postData),
            );

            if (response.statusCode == 200) {
              final res = jsonDecode(response.body);
              if (res["success"] == true) {
                // Simplified navigation without expecting returned data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      selectedDate: _selectedDate ?? DateTime.now(),
                      selectedTime: _selectedTime ?? TimeOfDay.now(),
                      selectedWorks: widget.selectedWorks,
                      selectedExtraCleaning: _selectedExtraCleaning,
                      selectedRepeat: _selectedRepeat,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to submit booking.")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Network error occurred.")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("An error occurred: ${e.toString()}")),
            );
          } finally {
            setState(() {
              _isSubmitted = false;
            });
          }
        },
        child: Icon(Icons.arrow_forward_ios),
      ),

      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            FadeInUp(
              child: Text(
                'Select Date and Time',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // Date Selection (Hidden if "Every Day" is selected)
            if (_selectedRepeat != 1)
              FadeInUp(
                child: GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue.shade400),
                        SizedBox(width: 10),
                        Text(
                          _selectedDate == null
                              ? "Select Date"
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_drop_down,
                            color: Colors.grey.shade700),
                      ],
                    ),
                  ),
                ),
              ),

            SizedBox(height: 20),

            // Time Selection
            FadeInUp(
              child: GestureDetector(
                onTap: () => _pickTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange.shade400),
                      SizedBox(width: 10),
                      Text(
                        _selectedTime == null
                            ? "Select Time"
                            : _selectedTime!.format(context),
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Repeat Options
            FadeInUp(
              child: Text("Repeat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_repeatOptions.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRepeat = index;
                      if (index == 1) {
                        _selectedDate =
                            null; // Clear date if "Every Day" is selected
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedRepeat == index
                          ? Colors.blue.shade400
                          : Colors.grey.shade200,
                    ),
                    child: Text(
                      _repeatOptions[index],
                      style: TextStyle(
                          fontSize: 16,
                          color: _selectedRepeat == index
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 20),

            // Additional Services
            FadeInUp(
              child: Text("Additional Service",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _extraCleaning.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedExtraCleaning.contains(index)) {
                          _selectedExtraCleaning.remove(index);
                        } else {
                          _selectedExtraCleaning.add(index);
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(10),
                      width: 100,
                      decoration: BoxDecoration(
                        color: _selectedExtraCleaning.contains(index)
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedExtraCleaning.contains(index)
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(_extraCleaning[index][1], height: 40),
                          SizedBox(height: 10),
                          Text(
                            _extraCleaning[index][0],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '₹${_extraCleaning[index][2]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
