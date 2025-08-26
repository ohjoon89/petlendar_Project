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
  String? imagePath;
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
  final ImagePicker _picker = ImagePicker();
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

  Future<String?> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  void _showImagePreview(String path) {
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(child: InteractiveViewer(child: Image.file(File(path)))),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void showOverlayToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("년 / 월 선택"),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          setDialogState(() {}); // 스크롤 시 색상 갱신
                          return false;
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: yearController,
                          itemExtent: 44,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            selectedYear = startYear + index;
                            setDialogState(() {}); // 선택 변경 시 색상 갱신
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final year = startYear + index;
                              final int currentIndex =
                                  yearController.selectedItem;
                              final isSelected = index == currentIndex;
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          setDialogState(() {}); // 스크롤 시 색상 갱신
                          return false;
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: monthController,
                          itemExtent: 44,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            selectedMonth = index + 1;
                            setDialogState(() {});
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final month = index + 1;
                              final int currentIndex =
                                  monthController.selectedItem;
                              final isSelected = index == currentIndex;
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
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(selectedYear, selectedMonth, 1);
                    });
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
      },
    );
  }

  void _openEventList(DateTime day) {
    final String key = DateFormat('yyyy-MM-dd').format(day);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Color _defaultColor = Colors.blue;
              final dayEvents = events[key] ?? [];

              List<Widget> _buildColorOptions(
                Color selected,
                Function(Color) onSelect,
              ) {
                final colors = [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ];
                return colors.map((c) {
                  return GestureDetector(
                    onTap: () => onSelect(c),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected == c
                            ? Border.all(width: 2, color: Colors.black)
                            : null,
                      ),
                    ),
                  );
                }).toList();
              }

              final ButtonStyle smallElevatedStyle = ElevatedButton.styleFrom(
                minimumSize: const Size(120, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 14),
              );

              final ButtonStyle smallOutlinedStyle = OutlinedButton.styleFrom(
                minimumSize: const Size(120, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 14),
              );

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '일정 (${DateFormat('yyyy-MM-dd').format(day)})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final event = dayEvents[index];
                          return Dismissible(
                            key: ValueKey(event.hashCode ^ index),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _controller.text = event.title;
                                  Color selectedColor = event.color;
                                  String? selectedImage = event.imagePath;

                                  showDialog(
                                    context: context,
                                    builder: (_) => StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          title: const Text('일정 수정'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: _controller,
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: _buildColorOptions(
                                                    selectedColor,
                                                    (c) {
                                                      setDialogState(() {
                                                        selectedColor = c;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text('선택 색상: '),
                                                    Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: selectedColor,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.black12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          width: 120,
                                                          child: ElevatedButton.icon(
                                                            style:
                                                                smallElevatedStyle,
                                                            icon: const Icon(
                                                              Icons.image,
                                                              size: 20,
                                                            ),
                                                            label: Text(
                                                              selectedImage ==
                                                                      null
                                                                  ? '사진 추가'
                                                                  : '사진 변경',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            onPressed: () async {
                                                              final path =
                                                                  await _pickImage();
                                                              if (path !=
                                                                  null) {
                                                                setDialogState(
                                                                  () {
                                                                    selectedImage =
                                                                        path;
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        if (selectedImage !=
                                                            null)
                                                          SizedBox(
                                                            width: 120,
                                                            child: OutlinedButton.icon(
                                                              style:
                                                                  smallOutlinedStyle,
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                size: 20,
                                                              ),
                                                              label: const Text(
                                                                '사진 제거',
                                                              ),
                                                              onPressed: () {
                                                                setDialogState(
                                                                  () {
                                                                    selectedImage =
                                                                        null;
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    AnimatedSize(
                                                      duration: const Duration(
                                                        milliseconds: 180,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                      child:
                                                          selectedImage != null
                                                          ? GestureDetector(
                                                              onTap: () =>
                                                                  _showImagePreview(
                                                                    selectedImage!,
                                                                  ),
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets.only(
                                                                      top: 8,
                                                                    ),
                                                                height: 80,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                  child: Image.file(
                                                                    File(
                                                                      selectedImage!,
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox.shrink(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('취소'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (_controller.text
                                                    .trim()
                                                    .isEmpty) {
                                                  showOverlayToast(
                                                    context,
                                                    '제목을 입력하세요',
                                                  );
                                                  return;
                                                }
                                                setState(() {
                                                  event.title = _controller.text
                                                      .trim();
                                                  event.color = selectedColor;
                                                  event.imagePath =
                                                      selectedImage;
                                                });
                                                setModalState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: const Text('저장'),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: event.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (event.imagePath != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                size: 20,
                                              ),
                                              tooltip: '사진 제거',
                                              onPressed: () {
                                                setState(() {
                                                  event.imagePath = null;
                                                });
                                                setModalState(() {});
                                              },
                                            ),
                                        ],
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeInOut,
                                        child: event.imagePath != null
                                            ? GestureDetector(
                                                onTap: () => _showImagePreview(
                                                  event.imagePath!,
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 8,
                                                  ),
                                                  height: 80,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: Image.file(
                                                      File(event.imagePath!),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _controller.clear();
                        Color selectedColor = _defaultColor;
                        String? selectedImage;

                        showDialog(
                          context: context,
                          builder: (_) => StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: const Text('일정 추가'),
                                content: SingleChildScrollView(
                                  child: Column(
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
                                            MainAxisAlignment.center,
                                        children: _buildColorOptions(
                                          selectedColor,
                                          (c) {
                                            setDialogState(() {
                                              selectedColor = c;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('선택 색상: '),
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: selectedColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton.icon(
                                                  style: smallElevatedStyle,
                                                  icon: const Icon(
                                                    Icons.image,
                                                    size: 20,
                                                  ),
                                                  label: const Text(
                                                    '사진 추가',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  onPressed: () async {
                                                    final path =
                                                        await _pickImage();
                                                    if (path != null) {
                                                      setDialogState(() {
                                                        selectedImage = path;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              if (selectedImage != null)
                                                SizedBox(
                                                  width: 120,
                                                  child: OutlinedButton.icon(
                                                    style: smallOutlinedStyle,
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 20,
                                                    ),
                                                    label: const Text(
                                                      '사진 제거',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    onPressed: () {
                                                      setDialogState(() {
                                                        selectedImage = null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: selectedImage != null
                                                ? GestureDetector(
                                                    onTap: () =>
                                                        _showImagePreview(
                                                          selectedImage!,
                                                        ),
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                      height: 80,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        child: Image.file(
                                                          File(selectedImage!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_controller.text.trim().isEmpty) {
                                        showOverlayToast(context, '제목을 입력하세요');
                                        return;
                                      }
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
                              );
                            },
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
                    ...dayEvents.take(2).map((e) {
                      return Container(
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
                            if (e.imagePath != null)
                              GestureDetector(
                                onTap: () => _showImagePreview(e.imagePath!),
                                child: const Icon(Icons.image, size: 12),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                    onPressed: _showYearMonthPicker,
                  ),
                ],
              ),
            ),
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
                              color: d == '토'
                                  ? Colors.blue
                                  : d == '일'
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentMonth = _getMonthDate(index);
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return _buildMonthGrid(_getMonthDate(pageIndex));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
