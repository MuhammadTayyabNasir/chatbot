import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/message.dart';
import '../providers/chat_provider.dart';

String _formatDuration(Duration d) {
  if (d.inHours > 0) {
    return d.toString().split('.').first.padLeft(8, "0");
  }
  return d.toString().split('.').first.substring(2).padLeft(5, "0");
}

class AudioMessagePlayer extends ConsumerWidget {
  final Message message;
  const AudioMessagePlayer({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodySmall?.color ?? Colors.black54;

    // Listen to the central player's state from the provider
    final playerState = ref.watch(chatProvider.select((s) => s.audioPlayerState));
    final chatNotifier = ref.read(chatProvider.notifier);

    // Determine if this specific message is the one currently active
    final bool isActivePlayer = playerState.messageId == message.id;

    final position = isActivePlayer ? playerState.position : Duration.zero;
    final duration = isActivePlayer && playerState.duration.inMilliseconds > 0
        ? playerState.duration
        : (message.attachment?.duration ?? Duration.zero);
    final isPlaying = isActivePlayer ? playerState.isPlaying : false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 32,
                color: primaryColor
            ),
            onPressed: () => chatNotifier.playAudio(message),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                  max: duration.inMilliseconds.toDouble().isFinite && duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1.0, // Use a non-zero max to prevent layout errors
                  onChanged: (value) {
                    if (isActivePlayer) {
                      chatNotifier.seekAudio(Duration(milliseconds: value.toInt()));
                    }
                  },
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withOpacity(0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}