import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProviderCRUDView extends StatefulWidget {
  @override
  _ProviderCRUDViewState createState() => _ProviderCRUDViewState();
}

class _ProviderCRUDViewState extends State<ProviderCRUDView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  double _rating = 0.0;

  List<Map<String, dynamic>> _providers = [];
  bool _isEditing = false;
  int? _editingId;

  final String apiUrl = 'http://localhost/my_flutter/flutter_api/crud.php';

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _providers = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> _addProvider() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'rating': _rating.toString(),
      }),
    );
    if (response.statusCode == 200) {
      _clearFields();
      _fetchProviders();
    }
  }

  Future<void> _updateProvider() async {
    await http.put(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'id': _editingId,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'rating': _rating.toString(),
      }),
    );
    _clearFields();
    setState(() {
      _isEditing = false;
      _editingId = null;
    });
    _fetchProviders();
  }

  Future<void> _deleteProvider(int id) async {
    await http.delete(
      Uri.parse(apiUrl),
      body: jsonEncode({'id': id}),
    );
    _fetchProviders();
  }

  void _startEdit(Map<String, dynamic> provider) {
    setState(() {
      _isEditing = true;
      _editingId = int.parse(provider['id'].toString());
      _nameController.text = provider['name'];
      _phoneController.text = provider['phone'];
      _emailController.text = provider['email'];
      _rating = double.tryParse(provider['rating'].toString()) ?? 0.0;
    });
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _rating = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Providers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone')),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 10),
            RatingBar(
              initialRating: _rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Icon(Icons.star, color: Colors.amber),
                half: Icon(Icons.star_half, color: Colors.amber),
                empty: Icon(Icons.star_border, color: Colors.grey),
              ),
              onRatingUpdate: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isEditing ? _updateProvider : _addProvider,
              child: Text(_isEditing ? 'Update Provider' : 'Add Provider'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _providers.length,
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  final rating =
                      double.tryParse(provider['rating'].toString()) ?? 0.0;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(provider['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${provider['phone']} | ${provider['email']}'),
                          SizedBox(height: 4),
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, _) =>
                                Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _startEdit(provider)),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteProvider(
                                  int.parse(provider['id'].toString()))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
