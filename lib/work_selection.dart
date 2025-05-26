import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'date_time_selection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkModel {
  final String name;
  final int count;
  final String iconUrl;
  final Color color;

  WorkModel({
    required this.name,
    required this.count,
    required this.iconUrl,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
        'iconUrl': iconUrl,
        'color': '#${color.value.toRadixString(16).substring(2)}',
      };
}

class WorkSelectionPage extends StatefulWidget {
  const WorkSelectionPage({super.key});

  @override
  _WorkSelectionPageState createState() => _WorkSelectionPageState();
}

class _WorkSelectionPageState extends State<WorkSelectionPage> {
  final List<dynamic> _workOptions = [
    [
      'Living Room',
      'https://img.icons8.com/officel/2x/living-room.png',
      Colors.red,
      0
    ],
    [
      'Bedroom',
      'https://img.icons8.com/fluency/2x/bedroom.png',
      Colors.orange,
      1
    ],
    ['Bathroom', 'https://img.icons8.com/color/2x/bath.png', Colors.blue, 1],
    ['Kitchen', 'https://img.icons8.com/dusk/2x/kitchen.png', Colors.purple, 0],
    ['Office', 'https://img.icons8.com/color/2x/office.png', Colors.green, 0],
    [
      'Vessel Washing',
      'https://img.icons8.com/fluency/2x/dishwasher.png',
      Colors.teal,
      0
    ],
    ['Babysitting', 'https://img.icons8.com/color/2x/baby.png', Colors.pink, 0],
  ];

  final List<int> _selectedIndexes = [];

  final String apiUrl =
      "http://localhost/my_flutter/flutter_api/submit_works.php";

  Future<void> submitWorkSelection(int userId, List<WorkModel> works) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId.toString(),
        "works": works.map((w) => w.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result["message"]);
    } else {
      print("Failed to submit work.");
    }
  }

  @override
  void initState() {
    super.initState();
    setLastVisited('workselection');
  }

  Future<void> setLastVisited(String s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVisited', 'work_selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text("Select Work"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: _selectedIndexes.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                List<WorkModel> selectedWorks = _selectedIndexes.map((index) {
                  String name = _workOptions[index][0];
                  String iconUrl = _workOptions[index][1];
                  Color color = _workOptions[index][2];
                  int count =
                      _workOptions[index][3] >= 1 ? _workOptions[index][3] : 1;

                  return WorkModel(
                    name: name,
                    count: count,
                    iconUrl: iconUrl,
                    color: color,
                  );
                }).toList();

                await submitWorkSelection(1, selectedWorks);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DateAndTime(
                      selectedWorks: selectedWorks,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_selectedIndexes.length}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 18),
                ],
              ),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: FadeInUp(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
                  child: Text(
                    'What work do you need?',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: _workOptions.length,
            itemBuilder: (BuildContext context, int index) {
              return FadeInUp(
                delay: Duration(milliseconds: 500 * index),
                duration: Duration(milliseconds: 500),
                child: workOption(_workOptions[index], index),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget workOption(List work, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndexes.contains(index)
              ? _selectedIndexes.remove(index)
              : _selectedIndexes.add(index);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: _selectedIndexes.contains(index)
              ? work[2].shade50.withOpacity(0.5)
              : Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Image.network(work[1], width: 35, height: 35),
                    SizedBox(width: 10.0),
                    Text(work[0],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                Spacer(),
                _selectedIndexes.contains(index)
                    ? Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(Icons.check, color: Colors.green, size: 20),
                      )
                    : SizedBox(),
              ],
            ),
            (_selectedIndexes.contains(index) && work[3] >= 1)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Text("How many ${work[0]}s?",
                          style: TextStyle(fontSize: 15)),
                      SizedBox(height: 10.0),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int i) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  work[3] = i + 1;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10.0),
                                padding: EdgeInsets.all(10.0),
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: work[3] == i + 1
                                      ? work[2].withOpacity(0.5)
                                      : work[2].shade200.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: Text((i + 1).toString(),
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
