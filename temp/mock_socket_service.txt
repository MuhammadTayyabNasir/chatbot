// --- START OF FILE mock_socket_service.dart ---

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/past_response.dart';
import '../models/question.dart';
import 'api_service.dart';

class MockSocketService {
  final _apiService = ApiService();
  final _controller = StreamController<Message>.broadcast();
  final _typingStateController = StreamController<bool>.broadcast();
  final _uuid = const Uuid();

  // --- State ---
  bool _isInStandup = false;
  bool get isInStandup => _isInStandup;
  bool _isEditingStandup = false;
  bool get isEditing => _isEditingStandup;
  bool _hasSubmittedToday = false;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  String? _parentId;
  final List<Map<String, dynamic>> _answers = [];
  String? _editingReportId;
  PastResponse? _editingReport;

  Stream<Message> get messages => _controller.stream;
  Stream<bool> get typingState => _typingStateController.stream;

  Future<void> init() async {
    try {
      _questions = await _apiService.fetchQuestions();
      final pastResponses = await _apiService.fetchPastResponses();
      final today = DateTime.now();
      _hasSubmittedToday = pastResponses.any((entry) =>
      entry.createdAt.year == today.year &&
          entry.createdAt.month == today.month &&
          entry.createdAt.day == today.day);
    } catch (e) {
      print("Failed to initialize socket service: $e");
    }
  }

  void connect() {
    print("MockSocket connecting...");
    Future.delayed(const Duration(milliseconds: 100), () {
      print("MockSocket connected.");
    });
  }

  void send(String text) {
    final trimmed = text.trim().toLowerCase();
    final isCommand = trimmed == "standup" ||
        trimmed == "ready" ||
        trimmed == 'checkin edit' ||
        trimmed == 'help';

    if (_isInStandup || _isEditingStandup) {
      _emitUserMessage(text);

      if (_isEditingStandup) {
        if (trimmed == "end" || trimmed == "stop" || trimmed == "cancel") {
          _emitBotMessage("Edit session cancelled.");
          _resetSession();
        } else {
          _handleEditResponse(text);
        }
      } else {
        if (trimmed == "end" || trimmed == "stop" || trimmed == "cancel") {
          _emitBotMessage("Standup session cancelled.");
          _resetSession();
        } else {
          _handleStandupResponse(text);
        }
      }
      return;
    }

    if (isCommand) {
      if (trimmed == "standup" || trimmed == "ready") {
        _startNewStandup();
      } else if (trimmed == 'checkin edit') {
        _startEditStandup();
      } else if (trimmed == 'help') {
        _emitBotMessage(
          "I can help you with daily standups. What would you like to do?",
          suggestions: ['standup', 'checkin edit'],
        );
      }
    } else {
      _emitBotMessage(
        "I'm DailyBot. You can say 'standup' to start a new check-in or 'help' for options.",
      );
    }
  }

  void _startNewStandup() {
    if (_hasSubmittedToday) {
      _emitBotMessage(
        "You've already submitted a standup today. To change it, type 'checkin edit'.",
        suggestions: ['checkin edit'],
      );
      return;
    }
    _resetSession();
    _isInStandup = true;
    _parentId = _uuid.v4();
    if (_questions.isNotEmpty) {
      _emitBotMessage(_questions.first.text);
    }
  }

  String _generateSummaryMessage() {
    if (_answers.isEmpty) return "Something went wrong, no summary available.";

    final summaryBody = _answers.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final question = entry.value['question'];
      final answer = entry.value['answer'];
      final formattedAnswer = answer.toString().replaceAll('\n', '\n  ');
      return "Q$index: $question\nA: $formattedAnswer";
    }).join('\n\n');

    return "Thanks! Here's a summary of your report:\n\n$summaryBody";
  }

  Future<void> _startEditStandup() async {
    _resetSession();
    try {
      final pastResponses = await _apiService.fetchPastResponses();
      if (pastResponses.isEmpty) {
        _emitBotMessage("You don't have any past reports to edit.");
        return;
      }
      pastResponses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _editingReport = pastResponses.first;
      _editingReportId = _editingReport!.id;

      _isEditingStandup = true;
      _currentQuestionIndex = 0;

      _emitBotMessage("Let's edit your last report. Type 'cancel' to stop.");
      _askNextEditQuestion();
    } catch (e) {
      _emitBotMessage("Sorry, I couldn't load your past reports to edit.");
      print("Error starting edit: $e");
    }
  }

  void _askNextEditQuestion() {
    if (_editingReport == null ||
        _currentQuestionIndex >= _editingReport!.entries.length) return;
    final entry = _editingReport!.entries[_currentQuestionIndex];

    _answers.add({
      'question': entry.question,
      'questionTimestamp': DateTime.now().toIso8601String(),
      'answer': entry.answer,
      'answerTimestamp': entry.answerTimestamp.toIso8601String(),
    });

    _emitBotMessage(
        "${entry.question}\n\n*Previous answer:* ${entry.answer}\n\nEnter a new answer, or submit with an empty field to keep the old one.");
  }

  // --- THIS METHOD CONTAINS THE FIX for the 'skip' keyword ---
  void _handleStandupResponse(String text) {
    if (_currentQuestionIndex >= _questions.length) return;

    // --- FIX: Check for 'skip' keyword and save an empty answer if found ---
    final String answer = text.trim().toLowerCase() == 'skip' ? '' : text;
    // --- END OF FIX ---

    final currentQ = _questions[_currentQuestionIndex];
    _answers.add({
      'question': currentQ.text,
      'questionTimestamp': DateTime.now().toIso8601String(),
      'answer': answer, // Use the processed answer
      'answerTimestamp': DateTime.now().toIso8601String(),
    });

    _currentQuestionIndex++;

    if (_currentQuestionIndex < _questions.length) {
      final nextQ = _questions[_currentQuestionIndex];
      _emitBotMessage(nextQ.text);
    } else {
      _finalizeNewStandup();
    }
  }

  void _handleEditResponse(String text) {
    if (_editingReport == null ||
        _currentQuestionIndex >= _editingReport!.entries.length) return;

    // In edit mode, an empty response keeps the old answer, which is correct.
    // Typing 'skip' will explicitly set the answer to "skip".
    if (text.trim().isNotEmpty) {
      _answers[_currentQuestionIndex]['answer'] = text;
      _answers[_currentQuestionIndex]['answerTimestamp'] =
          DateTime.now().toIso8601String();
    }

    _currentQuestionIndex++;

    if (_currentQuestionIndex < _editingReport!.entries.length) {
      _askNextEditQuestion();
    } else {
      _finalizeEditedStandup();
    }
  }

  Future<void> _finalizeNewStandup() async {
    final parentId = _parentId;
    if (parentId == null) return;

    _isInStandup = false;
    _emitBotMessage("Saving your report...");

    try {
      final standupData = {
        "id": parentId,
        "createdAt": DateTime.now().toIso8601String(),
        "entries": _answers,
      };
      await _apiService.postStandup(standupData);
      print("Standup responses saved.");
      _hasSubmittedToday = true;
      _emitBotMessage(_generateSummaryMessage());
    } catch (e) {
      print("Failed to save standup: $e");
      _emitBotMessage("Sorry, there was an error saving your report.");
    } finally {
      _resetSession();
    }
  }

  Future<void> _finalizeEditedStandup() async {
    final reportId = _editingReportId;
    if (reportId == null) return;

    _isEditingStandup = false;
    _emitBotMessage("Updating your report...");

    try {
      final standupData = {
        "id": reportId,
        "createdAt": _editingReport!.createdAt.toIso8601String(),
        "entries": _answers,
      };
      await _apiService.updateStandup(reportId, standupData);
      print("Standup report updated.");
      _emitBotMessage(_generateSummaryMessage());
    } catch (e) {
      print("Failed to update standup: $e");
      _emitBotMessage("Sorry, there was an error updating your report.");
    } finally {
      _resetSession();
    }
  }

  void _resetSession() {
    _isInStandup = false;
    _isEditingStandup = false;
    _currentQuestionIndex = 0;
    _parentId = null;
    _editingReportId = null;
    _editingReport = null;
    _answers.clear();
  }

  void dispose() {
    _controller.close();
    _typingStateController.close();
  }

  void _emitUserMessage(String content) {
    if (content.trim().isEmpty) return;
    _controller.add(
      Message(
        id: _uuid.v4(),
        text: content,
        timestamp: DateTime.now(),
        type: MessageType.user,
        richTextJson: null,
        repliedTo: null,
        attachment: null,
      ),
    );
  }

  void _emitBotMessage(String content, {List<String>? suggestions}) {
    _typingStateController.add(true);
    final delay = 800 + (content.length * 15);

    Future.delayed(Duration(milliseconds: delay > 2500 ? 2500 : delay), () {
      if (!_controller.isClosed) {
        _controller.add(Message(
          type: MessageType.bot,
          text: content,
          timestamp: DateTime.now(),
          id: _uuid.v4(),
          richTextJson: null,
          repliedTo: null,
          attachment: null,
          suggestions: suggestions,
        ));
        _typingStateController.add(false);
      }
    });
  }
}
// --- END OF FILE mock_socket_service.dart ---