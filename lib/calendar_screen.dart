import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  Event({required this.title});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 날짜별 이벤트 저장
  final Map<DateTime, List<Event>> _events = {};

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  void _addOrEditEvent(DateTime day) async {
    final controller = TextEditingController();
    final events = _getEventsForDay(day);
    if (events.isNotEmpty) {
      controller.text = events.first.title;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(events.isEmpty ? '일정 추가' : '일정 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '일정 제목'),
          autofocus: true,
        ),
        actions: [
          if (events.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _events.remove(DateTime(day.year, day.month, day.day));
                });
                Navigator.pop(context);
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        final key = DateTime(day.year, day.month, day.day);
        if (_events.containsKey(key)) {
          _events[key]!.add(Event(title: result));
        } else {
          _events[key] = [Event(title: result)];
        }
      });
    }
  }

  Widget _buildEventMarkers(List<Event> events, bool isSelected) {
    // 최대 3개까지 표시, 나머지는 +n
    final displayEvents = events.take(3).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayEvents.map(
          (e) => Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.orangeAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              e.title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (events.length > 3)
          Text(
            '+${events.length - 3}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar<Event>(
                    locale: 'ko_KR',
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _addOrEditEvent(selectedDay);
                    },
                    eventLoader: _getEventsForDay,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronVisible: true,
                      rightChevronVisible: true,
                    ),
                    calendarStyle: const CalendarStyle(
                      isTodayHighlighted: true,
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.redAccent),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final events = _getEventsForDay(day);
                        return Container(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              _buildEventMarkers(events, false),
                            ],
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final events = _getEventsForDay(day);
                        return Container(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              _buildEventMarkers(events, false),
                            ],
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final events = _getEventsForDay(day);
                        return Container(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              _buildEventMarkers(events, true),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
