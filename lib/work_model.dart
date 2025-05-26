import 'package:flutter/material.dart';

class WorkModel {
  final String name;
  final String iconUrl;
  final Color color; // Use Flutter's Color class
  final int? count; // Optional count, for works like Bedroom

  WorkModel({
    required this.name,
    required this.iconUrl,
    required this.color,
    this.count,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      name: json['name'],
      iconUrl: json['iconUrl'],
      color: Color(int.parse(json['color'].replaceFirst('#', '0xFF'))),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'count': count,
    };
  }
}
