class TimeUtils {
  static int getUpcomingRangeIndex() {
    List<TimeRange> timeRanges = TimeUtils.getTimeRanges();

    for (int i = 0; i <= timeRanges.length; i++) {
      return getCurrentRangeIndex() + 1;
    }
    return 0;
  }

  static int getCurrentRangeIndex() {
    DateTime now = DateTime.now();
    List<TimeRange> timeRanges = TimeUtils.getTimeRanges();
    print(timeRanges.length);
    for (int i = 1; i < timeRanges.length; i++) {
      if (now.isAfter(timeRanges[i].start) && now.isBefore(timeRanges[i].end)) {
        print(timeRanges[i].start);
        print(timeRanges[i].end);
        print(now);
        print(i);
        return i + 1;
      }
    }
    return 0;
  }

  static List<TimeRange> getTimeRanges() {
    DateTime now = DateTime.now();
    return [
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
  }
}

class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange(this.start, this.end);
}
