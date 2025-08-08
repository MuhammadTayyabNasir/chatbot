import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/date_formatter.dart';
import '../data/models/off_day.dart';
import '../data/models/past_response.dart';
import '../data/models/weekend_day.dart';

String getEnrichedQuestion(
    String questionText,
    List<PastResponse> pastMessages,
    List<OffDay> offDays,
    List<WeekendDay> weekendDays,
    ) {
  final dayMap = [
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
  ];

  if (questionText != kTargetQuestion || pastMessages.isEmpty) {
    return questionText;
  }

  // Create copies and sort past messages to find the most recent
  final sortedMessages = List<PastResponse>.from(pastMessages);
  sortedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  PastResponse? validMessage;
  for (final msg in sortedMessages) {
    final date = msg.createdAt;
    final dayName = dayMap[date.weekday % 7]; // Sunday is 7, not 0
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final isOffDay = offDays.any((d) => d.date == formattedDate);
    final isWeekend = weekendDays.any((d) => d.day == dayName);
    final hasSourceQuestion = msg.entries.any((entry) => entry.question == kSourceQuestion);

    if (!isOffDay && !isWeekend && hasSourceQuestion) {
      validMessage = msg;
      break; // Found the most recent valid message
    }
  }

  if (validMessage == null) return questionText;

  final plannedEntry = validMessage.entries.firstWhere(
        (entry) => entry.question == kSourceQuestion,
    orElse: () => Entry(question: '', answer: '', questionTimestamp: DateTime.now(), answerTimestamp: DateTime.now()), // Should not happen due to check above
  );

  if (plannedEntry.answer.isEmpty) return questionText;

  final formattedDate = formatDisplayDateChckIns(plannedEntry.answerTimestamp);

  return '$questionText \n\nYou previously planned to work on (📅 $formattedDate):\n${plannedEntry.answer}';
}