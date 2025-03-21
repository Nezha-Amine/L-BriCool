import 'package:flutter/material.dart';

class TaskSelector extends StatefulWidget {
  final List<String> selectedTasks;
  final Function(List<String>) onTasksChanged;

  const TaskSelector({
    Key? key,
    required this.selectedTasks,
    required this.onTasksChanged,
  }) : super(key: key);

  @override
  _TaskSelectorState createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> {
  final List<String> _availableTasks = [
    'Bottle feeding',
    'Preparing snacks',
    'Diaper changes',
    'Playtime',
    'Bedtime routine',
    'Light cleaning',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _availableTasks.map((task) {
            final isSelected = widget.selectedTasks.contains(task);
            return FilterChip(
              label: Text(task),
              selected: isSelected,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              selectedColor: Color(0xFFE1D9F6),
              onSelected: (selected) {
                final updatedTasks = List<String>.from(widget.selectedTasks);
                if (selected) {
                  if (!updatedTasks.contains(task)) {
                    updatedTasks.add(task);
                  }
                } else {
                  updatedTasks.remove(task);
                }
                widget.onTasksChanged(updatedTasks);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}