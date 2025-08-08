import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sticky_headers/sticky_headers.dart'; // --- NEW: Import package
import '../../data/models/user.dart';
import '../providers/chat_provider.dart';
import 'chat_message_bubble.dart';
import 'date_separator.dart';

class ChatListView extends ConsumerStatefulWidget {
  const ChatListView({super.key});

  @override
  ConsumerState<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<ChatListView> {
  final ScrollController _scrollController = ScrollController();
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = ref.read(chatProvider.notifier);
      chatNotifier.registerCallbacks(
        onNewMessage: _scrollToBottom,
        onBotMessage: (message) => _playNotificationSound(),
      );
      _scrollToBottom(isInitialLoad: true);
    });
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/notification.mp3');
    } catch (e) {
      debugPrint("Error loading sound asset: $e");
    }
  }

  void _playNotificationSound() {
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.play();
  }

  void _scrollToBottom({bool isInitialLoad = false}) {
    if (!_scrollController.hasClients) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.position.maxScrollExtent == 0 && !isInitialLoad) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: isInitialLoad ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final messageGroups = chatState.filteredMessagesByDate.entries.toList();
    final isBotTyping = chatState.isBotTyping;

    if (messageGroups.isEmpty && chatState.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your search for "${chatState.searchQuery}" did not match any messages.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // --- MODIFIED: Replaced ListView.builder with StickyHeader implementation ---
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: messageGroups.length, // Item count is now the number of groups
      itemBuilder: (context, groupIndex) {
        final group = messageGroups[groupIndex];
        final date = group.key;
        final messagesInGroup = group.value;

        // Check if this is the last group to append the typing indicator
        final isLastGroup = groupIndex == messageGroups.length - 1;
        final showTypingIndicator = isBotTyping && chatState.searchQuery.isEmpty && isLastGroup;

        return StickyHeader(
          header: Container(
            // This container ensures the header has a solid background
            // to hide content scrolling underneath it.
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.only(top: 8.0),
            alignment: Alignment.center,
            child: DateSeparator(date: date),
          ),
          content: Column(
            children: [
              ...messagesInGroup.map((message) => ChatMessageBubble(message: message)),
              if (showTypingIndicator)
                TypingIndicatorBubble(botUser: chatState.botUser),
            ],
          ),
        );
      },
    );
  }
}

// --- TypingIndicatorBubble widget remains unchanged ---
class TypingIndicatorBubble extends StatefulWidget {
  final User? botUser;
  const TypingIndicatorBubble({super.key, this.botUser});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _animation1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)));
    _animation2 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _animation3 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.4, 1.2, curve: Curves.easeOut)));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          color: Theme.of(context).textTheme.bodySmall?.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/bot_avatar.png'),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(_animation1),
                      _buildDot(_animation2),
                      _buildDot(_animation3),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}