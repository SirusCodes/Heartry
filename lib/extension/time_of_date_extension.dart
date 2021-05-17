import 'package:flutter/material.dart';

extension FormatTimeOfDay on TimeOfDay {
  String toFormatedString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);
    final String amPm = period == DayPeriod.am ? "AM" : "PM";
    return "$hourLabel:$minuteLabel $amPm";
  }

  String toHmString() {
    return "$hour:$minute";
  }
}

extension FormatTimeOfDayString on String {
  TimeOfDay parse() {
    final data = split(":").map((e) => int.parse(e)).toList();
    return TimeOfDay(hour: data[0], minute: data[1]);
  }
}
