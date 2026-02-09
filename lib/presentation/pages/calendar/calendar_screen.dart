import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_notifier.dart';
import '../../../domain/entities/task_entity.dart';
import '../tasks/task_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final tasks = taskState.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario Académico')),
      body: Column(
        children: [
          _buildHeader(),
          _buildDaysOfWeek(),
          _buildCalendarGrid(tasks),
          const Divider(),
          Expanded(child: _buildTaskList(tasks)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            DateFormat.yMMMM('es').format(_focusedDay).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map(
              (day) => SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<Task> tasks) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday - 1; // 0 for Mon, 6 for Sun

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + weekdayOffset,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < weekdayOffset) {
          return const SizedBox.shrink();
        }

        final day = index - weekdayOffset + 1;
        final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = DateUtils.isSameDay(_selectedDay, currentDate);
        final isToday = DateUtils.isSameDay(DateTime.now(), currentDate);

        final tasksForDay = tasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  DateUtils.isSameDay(task.dueDate!, currentDate),
            )
            .toList();

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = currentDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : null,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(color: Theme.of(context).primaryColor)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (tasksForDay.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(List<Task> allTasks) {
    final tasksForSelectedDay = allTasks
        .where(
          (task) =>
              task.dueDate != null &&
              DateUtils.isSameDay(task.dueDate!, _selectedDay),
        )
        .toList();

    if (tasksForSelectedDay.isEmpty) {
      return Center(
        child: Text(
          'No hay tareas para ${DateFormat.yMd().format(_selectedDay)}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasksForSelectedDay.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDay[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description ?? ''),
          leading: Icon(
            Icons.circle,
            size: 12,
            color: task.priority == 'urgent' ? Colors.red : Colors.blue,
          ),
          trailing: task.status == 'completed'
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }
}
