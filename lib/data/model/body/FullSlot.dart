class FullSlot {
  DateTime startTime;
  DateTime endTime;

  FullSlot({required this.startTime,
    required this.endTime});

  @override
  String toString() {
    return 'Start: ${startTime.toString()}, End: ${endTime.toString()}';
  }
}
