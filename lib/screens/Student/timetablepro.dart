import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimetableProvider with ChangeNotifier {
  bool isLoading = true;
  String errorMessage = '';
  QuerySnapshot? timetableSnapshot;

  void fetchTimetable(Student student) {
    FirebaseFirestore.instance
        .collection('timetable')
        .doc(student.currentYear ?? "")
        .collection(student.branch ?? "")
        .where('day', isEqualTo: getCurrentDay())
        .where('index', isEqualTo: showUpcomingRange())
        .snapshots()
        .listen((snapshot) {
      isLoading = false;
      timetableSnapshot = snapshot;
      notifyListeners();
    }).onError((error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  int showUpcomingRange() {
    DateTime now = DateTime.now();

    List<TimeRange> ranges = [
      TimeRange(DateTime(now.year, now.month, now.day, 8, 30),
          DateTime(now.year, now.month, now.day, 9, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 9, 30),
          DateTime(now.year, now.month, now.day, 10, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 10, 30),
          DateTime(now.year, now.month, now.day, 11, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 11, 30),
          DateTime(now.year, now.month, now.day, 12, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 12, 30),
          DateTime(now.year, now.month, now.day, 13, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 13, 30),
          DateTime(now.year, now.month, now.day, 14, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 14, 30),
          DateTime(now.year, now.month, now.day, 15, 30)),
      TimeRange(DateTime(now.year, now.month, now.day, 15, 30),
          DateTime(now.year, now.month, now.day, 16, 30)),
    ];

    for (int i = 0; i < ranges.length; i++) {
      if (now.isAfter(ranges[i].start) && now.isBefore(ranges[i].end)) {
        return i + 2; // Next range is the one after the current one
      }
    }

    return 1; // Default to range 1 if no match
  }

  int checkTimeRange() {
    return showUpcomingRange() - 1; // Adjusting for index difference
  }

  String getCurrentDay() {
    DateTime now = DateTime.now();
    List<String> daysOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];

    int dayIndex = now.weekday - 1;
    return daysOfWeek[dayIndex];
  }

  String getCurrentMonth() {
    int currentMonth = DateTime.now().month;
    List<String> monthNames = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];

    return monthNames[currentMonth - 1]; // Adjust for zero-based index
  }
}

class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange(this.start, this.end);
}

class Student {
  final String? currentYear;
  final String? branch;

  Student({this.currentYear, this.branch});
}
