// import 'dart:typed_data';
//
// class MessageAttachment {
//   final String fileName;
//   final double? fileSize; // in bytes
//   final String? path;     // local path for mobile/desktop
//   final String? url;      // remote url OR blob url for audio
//   final Duration? duration;
//   final Uint8List? bytes; // --- NEW: Stores file bytes for web downloads
//
//   MessageAttachment({
//     required this.fileName,
//     this.fileSize,
//     this.path,
//     this.url,
//     this.duration,
//     this.bytes, // --- NEW
//   });
//
//   bool get isAudio {
//     final lowerCase = fileName.toLowerCase();
//     return lowerCase == "voice message" ||
//         lowerCase.endsWith('.m4a') ||
//         lowerCase.endsWith('.mp3') ||
//         lowerCase.endsWith('.aac') ||
//         lowerCase.endsWith('.ogg');
//   }
// }
//
// // ... Message class is unchanged ...
// enum MessageType { bot, user }
// class Message {
//   final String id;
//   final String text;
//   final String? richTextJson;
//   final DateTime timestamp;
//   final MessageType type;
//   final Message? repliedTo;
//   final MessageAttachment? attachment;
//
//   Message({
//     required this.id,
//     required this.text,
//     this.richTextJson,
//     required this.timestamp,
//     required this.type,
//     this.repliedTo,
//     this.attachment,
//   });
//
//   bool get isAttachmentOnly => (text.trim().isEmpty && attachment != null);
// }















// --- START OF FILE message.dart ---

import 'dart:typed_data';

class MessageAttachment {
  final String fileName;
  final double? fileSize; // in bytes
  final String? path;     // local path for mobile/desktop
  final String? url;      // remote url OR blob url for audio
  final Duration? duration;
  final Uint8List? bytes;

  MessageAttachment({
    required this.fileName,
    this.fileSize,
    this.path,
    this.url,
    this.duration,
    this.bytes,
  });

  bool get isAudio {
    final lowerCase = fileName.toLowerCase();
    return lowerCase == "voice message" ||
        lowerCase.endsWith('.m4a') ||
        lowerCase.endsWith('.mp3') ||
        lowerCase.endsWith('.aac') ||
        lowerCase.endsWith('.ogg');
  }
}

enum MessageType { bot, user }
class Message {
  final String id;
  final String text;
  final String? richTextJson;
  final DateTime timestamp;
  final MessageType type;
  final Message? repliedTo;
  final MessageAttachment? attachment;
  final List<String>? suggestions; // --- NEW: For quick replies

  Message({
    required this.id,
    required this.text,
    this.richTextJson,
    required this.timestamp,
    required this.type,
    this.repliedTo,
    this.attachment,
    this.suggestions, // --- NEW
  });

  bool get isAttachmentOnly => (text.trim().isEmpty && attachment != null);
}
// --- END OF FILE message.dart ---