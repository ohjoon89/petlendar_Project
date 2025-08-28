import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class CalendarController {
  DateTime selectedDay = DateTime.now();
  DateTime currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  final Map<String, List<Event>> events = {};
  final ImagePicker _picker = ImagePicker();
  final int yearRangeSpan = 50;

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<String?> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  DateTime getMonthDate(int pageIndex, int initialPage) {
    final int monthOffset = pageIndex - initialPage;
    return DateTime(DateTime.now().year, DateTime.now().month + monthOffset, 1);
  }

  String formatDateKey(DateTime day) {
    return DateFormat('yyyy-MM-dd').format(day);
  }

  void addEvent(String key, Event event) {
    if (!events.containsKey(key)) events[key] = [];
    events[key]!.add(event);
  }

  void removeEvent(String key, int index) {
    events[key]?.removeAt(index);
  }

  List<Event> getEvents(String key) {
    return events[key] ?? [];
  }
}
