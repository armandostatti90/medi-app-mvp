import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/locked_screen_overlay.dart';
import 'medication_list_screen.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _calendarData;
  Map<String, dynamic>? _selectedDaySchedule;
  String? _selectedDate;
  DateTime _selectedDateTime = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  bool _isLoading = true;
  bool _isOnboardingCompleted = false;
  bool _showFullCalendar = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOnboardingAndLoad();
  }

  Future<void> _checkOnboardingAndLoad() async {
    setState(() => _isLoading = true);

    try {
      final completed = await _apiService.isOnboardingCompleted();

      setState(() {
        _isOnboardingCompleted = completed;
      });

      if (completed) {
        await _loadCalendar();
        final today = DateTime.now();
        await _loadDaySchedule(today.toIso8601String().split('T')[0]);
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCalendar() async {
    try {
      final monthStr =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
      final calendar = await _apiService.getCalendarMonth(monthStr);

      setState(() {
        _calendarData = calendar;
      });
    } catch (e) {
      print('Error loading calendar: $e');
    }
  }

  Future<void> _loadDaySchedule(String date) async {
    try {
      final schedule = await _apiService.getScheduleForDate(date);

      setState(() {
        _selectedDate = date;
        _selectedDateTime = DateTime.parse(date);
        _selectedDaySchedule = schedule;
      });
    } catch (e) {
      print('Error loading day schedule: $e');
    }
  }

  void _goToPreviousDay() {
    final newDate = _selectedDateTime.subtract(const Duration(days: 1));
    _loadDaySchedule(newDate.toIso8601String().split('T')[0]);
  }

  void _goToNextDay() {
    final newDate = _selectedDateTime.add(const Duration(days: 1));
    _loadDaySchedule(newDate.toIso8601String().split('T')[0]);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadCalendar();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadCalendar();
  }

  Future<void> _markSingleAsTaken(
    int medicationId,
    String time,
    String medName,
  ) async {
    try {
      await _apiService.markMedicationTaken(
        medicationId: medicationId,
        scheduledTime: time,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$medName als genommen markiert! ✓'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadCalendar();
        if (_selectedDate != null) {
          await _loadDaySchedule(_selectedDate!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'complete':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      case 'future':
        return Colors.grey.shade300;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'complete':
        return Icons.check_circle;
      case 'partial':
        return Icons.warning;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildHorizontalDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return _selectedDateTime.subtract(Duration(days: 3 - index));
    });

    return Column(
      children: [
        Container(
          height: 90,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: _goToPreviousDay,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final dateStr = date.toIso8601String().split('T')[0];
                    final isSelected = dateStr == _selectedDate;
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;

                    return GestureDetector(
                      onTap: () => _loadDaySchedule(dateStr),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : (isToday
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: isToday && !isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getWeekdayShort(date.weekday),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMonthShort(date.month),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: _goToNextDay,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        TextButton.icon(
          onPressed: () {
            setState(() {
              _showFullCalendar = !_showFullCalendar;
            });
          },
          icon: Icon(
            _showFullCalendar ? Icons.expand_less : Icons.calendar_month,
          ),
          label: Text(
            _showFullCalendar ? 'Kalender einklappen' : 'Kalender anzeigen',
          ),
        ),
      ],
    );
  }

  Widget _buildFullCalendar() {
    if (_calendarData == null || !_showFullCalendar) {
      return const SizedBox.shrink();
    }

    final days = _calendarData!['days'] as List;
    final monthName = _calendarData!['month_name'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '$monthName ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
                  .map(
                    (day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final date = day['date'];
                final dayNum = day['day'];
                final status = day['status'];
                final isToday = day['is_today'] ?? false;
                final isSelected = date == _selectedDate;

                return GestureDetector(
                  onTap: () {
                    _loadDaySchedule(date);
                    setState(() {
                      _showFullCalendar = false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : (isToday ? Colors.blue.shade50 : null),
                      border: isToday
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          _getStatusIcon(status),
                          size: 14,
                          color: _getStatusColor(status),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days[weekday - 1];
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    return months[month - 1];
  }

  Widget _buildDaySchedule() {
    if (_selectedDaySchedule == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedule = _selectedDaySchedule!['schedule'] as List? ?? [];
    final date = _selectedDaySchedule!['date'];
    final isToday = _selectedDaySchedule!['is_today'] ?? false;

    final dateObj = DateTime.parse(date);
    final dateStr = isToday
        ? 'Heute'
        : '${dateObj.day}. ${_getMonthName(dateObj.month)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dateStr,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        if (schedule.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('Keine Medikamente an diesem Tag')),
          )
        else
          ...schedule.map((timeSlot) {
            final time = timeSlot['time'];
            final meds = timeSlot['medications'] as List;
            final allTaken = timeSlot['all_taken'] as bool;
            final isUpcoming = timeSlot['is_upcoming'] as bool;
            final takenCount = timeSlot['taken_count'] as int;
            final totalCount = timeSlot['total_count'] as int;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ExpansionTile(
                leading: Icon(
                  allTaken ? Icons.check_circle : Icons.access_time,
                  color: allTaken
                      ? Colors.green
                      : (isUpcoming ? Colors.blue : Colors.orange),
                  size: 32,
                ),
                title: Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCount Med${totalCount > 1 ? 'ikamente' : 'ikament'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                subtitle: allTaken
                    ? const Text('Alle genommen ✓')
                    : (takenCount > 0
                          ? Text('$takenCount/$totalCount genommen')
                          : null),
                trailing: allTaken
                    ? const Chip(
                        label: Text('Erledigt', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : (!isUpcoming
                          ? const Chip(
                              label: Text(
                                'Verpasst',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange,
                            )
                          : const Icon(Icons.expand_more)),
                children: meds.map<Widget>((med) {
                  final medTaken = med['taken'] as bool;
                  return ListTile(
                    leading: Icon(
                      medTaken ? Icons.check_circle : Icons.medication,
                      color: medTaken ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      med['name'],
                      style: TextStyle(
                        decoration: medTaken
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(med['dose']),
                    trailing: medTaken || !isToday
                        ? null
                        : TextButton(
                            onPressed: () => _markSingleAsTaken(
                              med['medication_id'],
                              time,
                              med['name'],
                            ),
                            child: const Text('Genommen'),
                          ),
                  );
                }).toList(),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadCalendar();
        if (_selectedDate != null) {
          await _loadDaySchedule(_selectedDate!);
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHorizontalDatePicker(),
            _buildFullCalendar(),
            _buildDaySchedule(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isOnboardingCompleted) {
      return LockedScreenOverlay(child: _buildContentScaffold());
    }

    return _buildContentScaffold();
  }

  Widget _buildContentScaffold() {
    return Scaffold(
      body: _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicationListScreen(),
            ),
          );
        },
        icon: const Icon(Icons.medication),
        label: const Text('Verwalten'),
      ),
    );
  }
}
