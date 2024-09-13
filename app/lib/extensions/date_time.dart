extension DateTimeFormat on DateTime {
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String formatWithMinutePrecision() {
    final year = this.year.toString();
    final month = _twoDigits(this.month);
    final day = _twoDigits(this.day);
    final hour = _twoDigits(this.hour);
    final minute = _twoDigits(this.minute);

    return '$year-$month-$day $hour:$minute';
  }
}
