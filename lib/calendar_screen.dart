import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class Event {
  String title;
  Color color;
  String? imagePath; // ✅ 사진 경로 추가
  Event({required this.title, required this.color, this.imagePath});
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  final Map<String, List<Event>> events = {};
  late final PageController _pageController;
  late final int _initialPage;

  final ImagePicker _picker = ImagePicker(); // ✅ 이미지 선택기

  // 연도 범위 설정 (현재년도 ±50)
  final int _yearRangeSpan = 50;

  @override
  void initState() {
    super.initState();
    _initialPage = 1000;
    _pageController = PageController(initialPage: _initialPage);
  }

  DateTime _getMonthDate(int pageIndex) {
    final int monthOffset = pageIndex - _initialPage;
    return DateTime(DateTime.now().year, DateTime.now().month + monthOffset, 1);
  }

  // ✅ 사진 확대 보기
  void _showImagePreview(String path) {
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(child: InteractiveViewer(child: Image.file(File(path)))),
    );
  }

  // ✅ 사진 선택
  Future<String?> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  void _openEventList(DateTime day) {
    final String key = DateFormat('yyyy-MM-dd').format(day);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        Color selectedColor = Colors.blue;
        String? selectedImage; // ✅ 선택된 이미지 (다이얼로그 레벨)

        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final dayEvents = events[key] ?? [];
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      '일정 (${DateFormat('yyyy-MM-dd').format(day)})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final event = dayEvents[index];
                          return Dismissible(
                            key: ValueKey(event),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              setState(() {
                                events[key]!.removeAt(index);
                              });
                              setModalState(() {});
                            },
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.title),
                                  if (event.imagePath !=
                                      null) // ✅ 일정에 사진 있으면 썸네일
                                    GestureDetector(
                                      onTap: () =>
                                          _showImagePreview(event.imagePath!),
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        height: 80,
                                        child: Image.file(
                                          File(event.imagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              tileColor: event.color.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              // 우측에 사진 즉시 삭제 아이콘 추가
                              trailing: event.imagePath != null
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_forever),
                                      tooltip: '사진 제거',
                                      onPressed: () {
                                        setState(() {
                                          event.imagePath = null;
                                        });
                                        setModalState(() {}); // 모달 UI 갱신
                                      },
                                    )
                                  : null,
                              onTap: () {
                                // 편집: 기존 이벤트 정보 로드
                                _controller.text = event.title;
                                selectedColor = event.color;
                                selectedImage = event.imagePath;

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('일정 수정'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(controller: _controller),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _colorOption(
                                              Colors.red,
                                              selectedColor,
                                              (c) {
                                                selectedColor = c;
                                                setModalState(() {});
                                              },
                                            ),
                                            _colorOption(
                                              Colors.blue,
                                              selectedColor,
                                              (c) {
                                                selectedColor = c;
                                                setModalState(() {});
                                              },
                                            ),
                                            _colorOption(
                                              Colors.green,
                                              selectedColor,
                                              (c) {
                                                selectedColor = c;
                                                setModalState(() {});
                                              },
                                            ),
                                            _colorOption(
                                              Colors.orange,
                                              selectedColor,
                                              (c) {
                                                selectedColor = c;
                                                setModalState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                final path = await _pickImage();
                                                if (path != null) {
                                                  selectedImage = path;
                                                  setModalState(() {});
                                                }
                                              },
                                              icon: const Icon(Icons.image),
                                              label: const Text('사진 추가/변경'),
                                            ),
                                            // 사진이 있으면 제거 버튼 표시
                                            if (selectedImage != null)
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  selectedImage = null;
                                                  setModalState(() {});
                                                },
                                                icon: const Icon(Icons.delete),
                                                label: const Text('사진 제거'),
                                              ),
                                          ],
                                        ),
                                        if (selectedImage != null)
                                          GestureDetector(
                                            onTap: () => _showImagePreview(
                                              selectedImage!,
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              height: 80,
                                              child: Image.file(
                                                File(selectedImage!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('취소'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_controller.text.trim().isEmpty)
                                            return;
                                          setState(() {
                                            event.title = _controller.text
                                                .trim();
                                            event.color = selectedColor;
                                            event.imagePath =
                                                selectedImage; // null 가능 -> 사진 제거
                                          });
                                          setModalState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: const Text('저장'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 추가 다이얼로그 초기화
                        _controller.clear();
                        selectedColor = Colors.blue;
                        selectedImage = null;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('일정 추가'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    labelText: '제목',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _colorOption(Colors.red, selectedColor, (
                                      c,
                                    ) {
                                      selectedColor = c;
                                      setModalState(() {});
                                    }),
                                    _colorOption(Colors.blue, selectedColor, (
                                      c,
                                    ) {
                                      selectedColor = c;
                                      setModalState(() {});
                                    }),
                                    _colorOption(Colors.green, selectedColor, (
                                      c,
                                    ) {
                                      selectedColor = c;
                                      setModalState(() {});
                                    }),
                                    _colorOption(Colors.orange, selectedColor, (
                                      c,
                                    ) {
                                      selectedColor = c;
                                      setModalState(() {});
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final path = await _pickImage();
                                        if (path != null) {
                                          selectedImage = path;
                                          setModalState(() {});
                                        }
                                      },
                                      icon: const Icon(Icons.image),
                                      label: const Text('사진 추가'),
                                    ),
                                    // 추가 다이얼로그에서도 사진 제거 버튼 제공
                                    if (selectedImage != null)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          selectedImage = null;
                                          setModalState(() {});
                                        },
                                        icon: const Icon(Icons.delete),
                                        label: const Text('사진 제거'),
                                      ),
                                  ],
                                ),
                                if (selectedImage != null)
                                  GestureDetector(
                                    onTap: () =>
                                        _showImagePreview(selectedImage!),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      height: 80,
                                      child: Image.file(
                                        File(selectedImage!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_controller.text.trim().isEmpty) return;
                                  setState(() {
                                    if (!events.containsKey(key))
                                      events[key] = [];
                                    events[key]!.add(
                                      Event(
                                        title: _controller.text.trim(),
                                        color: selectedColor,
                                        imagePath: selectedImage,
                                      ),
                                    );
                                  });
                                  setModalState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Text('저장'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('일정 추가'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _colorOption(Color color, Color selected, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected == color
              ? Border.all(width: 2, color: Colors.black)
              : null,
        ),
      ),
    );
  }

  // ✅ 년/월 선택 다이얼로그 (Wheel)
  Future<void> _showYearMonthPicker() async {
    final int nowYear = DateTime.now().year;
    final int startYear = nowYear - _yearRangeSpan;
    final int yearCount = _yearRangeSpan * 2 + 1;

    int selectedYear = _currentMonth.year;
    int selectedMonth = _currentMonth.month;

    final FixedExtentScrollController yearController =
        FixedExtentScrollController(initialItem: selectedYear - startYear);
    final FixedExtentScrollController monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("년 / 월 선택"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: yearController,
                          itemExtent: 44,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            selectedYear = startYear + index;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final year = startYear + index;
                              final isSelected = year == selectedYear;
                              return Center(
                                child: Text(
                                  "$year 년",
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              );
                            },
                            childCount: yearCount,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: monthController,
                          itemExtent: 44,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            selectedMonth = index + 1;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final month = index + 1;
                              final isSelected = month == selectedMonth;
                              return Center(
                                child: Text(
                                  "$month 월",
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              );
                            },
                            childCount: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                // 선택된 년월로 이동
                setState(() {
                  _currentMonth = DateTime(selectedYear, selectedMonth, 1);
                });

                // PageView 페이지 계산 및 이동
                final int diffMonths =
                    (selectedYear - DateTime.now().year) * 12 +
                    (selectedMonth - DateTime.now().month);
                _pageController.jumpToPage(_initialPage + diffMonths);

                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat('yyyy.M').format(_currentMonth),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _showYearMonthPicker, // ✅ 년월 뷰 열기
                  ),
                ],
              ),
            ),
            // 요일
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: (d == '토')
                                  ? Colors.blue
                                  : (d == '일')
                                  ? Colors.red
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // 달력
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentMonth = _getMonthDate(index);
                  });
                },
                itemBuilder: (context, pageIndex) {
                  final monthDate = _getMonthDate(pageIndex);
                  return _buildMonthGrid(monthDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime focusedMonth) {
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final int daysInMonth = lastDayOfMonth.day;

    final int firstWeekday = firstDayOfMonth.weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    final double horizontalPadding = 12;
    final availableHeight =
        MediaQuery.of(context).size.height - 60 - 36 - 16 - 48;
    final double gridWidth =
        MediaQuery.of(context).size.width - horizontalPadding * 2;
    final double cellWidth = gridWidth / 7;
    final double cellHeight = (availableHeight / weeks) - 1;
    final double childAspectRatio = cellWidth / cellHeight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: availableHeight,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: weeks * 7,
          itemBuilder: (context, index) {
            final int dayIndex = index - firstWeekday + 1;
            if (dayIndex < 1 || dayIndex > daysInMonth) return Container();

            final DateTime day = DateTime(year, month, dayIndex);
            final key = DateFormat('yyyy-MM-dd').format(day);
            final bool isToday = _isSameDate(day, DateTime.now());
            final bool isSelected = _isSameDate(day, _selectedDay);
            final dayEvents = events[key] ?? [];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
                _openEventList(day);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isToday && !isSelected
                        ? Colors.black
                        : Colors.grey.shade200,
                    width: isToday && !isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayIndex',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (day.weekday == DateTime.sunday
                                  ? Colors.red
                                  : (day.weekday == DateTime.saturday
                                        ? Colors.blue
                                        : Colors.black87)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...dayEvents
                        .take(2)
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: e.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (e.imagePath != null) // ✅ 셀에도 사진 있으면 아이콘 표시
                                  GestureDetector(
                                    onTap: () =>
                                        _showImagePreview(e.imagePath!),
                                    child: const Icon(Icons.image, size: 12),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    if (dayEvents.length > 2)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${dayEvents.length - 2}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}