class TimeRange {
  final String start;
  final String end;

  TimeRange(this.start, this.end);
}

List<TimeRange> parseTimeRanges(String input) {
  final ranges = <TimeRange>[];
  final parts = input.trim().split(RegExp(r'\s+'));
  for (int i = 0; i < parts.length; i += 2) {
    if (i + 1 < parts.length) {
      final start = parts[i];
      final end = parts[i+1];
      if (start != '-' && end != '-') {
        ranges.add(TimeRange(start, end));
      }
    }
  }
  return ranges;
}
