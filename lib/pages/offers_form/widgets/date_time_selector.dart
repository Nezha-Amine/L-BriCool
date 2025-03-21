import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final bool isDateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(bool) onIsDateRangeChanged;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;

  const DateTimeSelector({
    Key? key,
    required this.startDate,
    this.endDate,
    required this.isDateRange,
    required this.startTime,
    required this.endTime,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onIsDateRangeChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  }) : super(key: key);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != startDate) {
      onStartDateChanged(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate.add(Duration(days: 1)),
      firstDate: startDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      onEndDateChanged(picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      onStartTimeChanged(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      onEndTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        // Date selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: isDateRange,
                  activeColor: Color(0xFF4527A0),
                  onChanged: (value) {
                    onIsDateRangeChanged(value);
                  },
                ),
                Text(
                  isDateRange ? 'Date Range' : 'Single Day',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_month, color: Color(0xFF4527A0)),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text(
                    DateFormat('dd MMM, yyyy').format(startDate),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isDateRange) ...[
                  Text(' - '),
                  TextButton(
                    onPressed: () => _selectEndDate(context),
                    child: Text(
                      endDate != null
                          ? DateFormat('dd MMM, yyyy').format(endDate!)
                          : 'Select End Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        // Time selection
        Row(
          children: [
            Icon(Icons.access_time, color: Color(0xFF4527A0)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () => _selectStartTime(context),
              child: Text(
                startTime.format(context),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(' - '),
            TextButton(
              onPressed: () => _selectEndTime(context),
              child: Text(
                endTime.format(context),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}