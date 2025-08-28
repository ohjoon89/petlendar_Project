import 'package:flutter/material.dart';

class Event {
  String title;
  Color color;
  String? imagePath;

  Event({required this.title, required this.color, this.imagePath});
}
