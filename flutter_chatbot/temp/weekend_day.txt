class WeekendDay {
  final String day; // "Saturday", "Sunday"

  WeekendDay({required this.day});

  factory WeekendDay.fromJson(Map<String, dynamic> json) {
    return WeekendDay(day: json['day']);
  }
}