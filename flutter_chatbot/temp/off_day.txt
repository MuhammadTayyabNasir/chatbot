class OffDay {
  final String date; // yyyy-MM-dd

  OffDay({required this.date});

  factory OffDay.fromJson(Map<String, dynamic> json) {
    return OffDay(date: json['date']);
  }
}