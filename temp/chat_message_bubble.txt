// --- START OF FILE chat_message_bubble.dart ---

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../data/models/message.dart';
import '../../data/models/user.dart';
import '../../logic/enriched_question_logic.dart';
import '../providers/chat_provider.dart';
import 'audio_message_player.dart';

class ChatMessageBubble extends ConsumerWidget {
  final Message message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final bool isUser = message.type == MessageType.user;

    Widget messageContent;
    if (message.attachment != null && message.attachment!.isAudio) {
      messageContent = _buildMessageContent(context, ref, isUser);
    } else if (message.attachment != null) {
      messageContent = InkWell(
        onTap: () =>
            ref.read(chatProvider.notifier).openAttachment(message.attachment!),
        child: _buildMessageContent(context, ref, isUser),
        borderRadius: _getBubbleBorderRadius(isUser),
      );
    } else {
      messageContent = _buildMessageContent(context, ref, isUser);
    }

    final avatar = isUser
        ? _buildAvatar(chatState.currentUser)
        : _buildAvatar(chatState.botUser, isBot: true);

    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Dismissible(
          key: ValueKey(message.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.reply, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            ref.read(chatProvider.notifier).startReplying(message);
            return false;
          },
          child: GestureDetector(
            onLongPress: () =>
                ref.read(chatProvider.notifier).startReplying(message),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              // --- THIS IS THE WIDGET WITH THE FIX ---
              child: Row(
                mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) avatar,
                  if (!isUser) const SizedBox(width: 12),
                  // --- FIX: Wrap the message content in Flexible ---
                  // This prevents the content from overflowing the Row's constraints.
                  Flexible(child: messageContent),
                  // --- END OF FIX ---
                  if (isUser) const SizedBox(width: 12),
                  if (isUser) avatar,
                ],
              ),
            ),
          ),
        ),
        if (message.suggestions != null && message.suggestions!.isNotEmpty)
          _buildSuggestions(context, ref, chatState.currentUser),
      ],
    );
  }

  Widget _buildSuggestions(
      BuildContext context, WidgetRef ref, User? currentUser) {
    final lastMessage =
        ref.read(chatProvider).messagesByDate.values.lastOrNull?.lastOrNull;
    if (message.id != lastMessage?.id) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(
        left: 54,
        top: 4,
        right: MediaQuery.of(context).size.width * 0.2,
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: message.suggestions!.map((suggestion) {
          return ActionChip(
            label: Text(suggestion),
            onPressed: () {
              ref.read(chatProvider.notifier).sendMessage(text: suggestion);
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: BorderSide(color: Theme.of(context).dividerColor),
          );
        }).toList(),
      ),
    );
  }

  BorderRadius _getBubbleBorderRadius(bool isUser) {
    return isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      topRight: Radius.circular(4),
      bottomRight: Radius.circular(18),
    )
        : const BorderRadius.only(
      topRight: Radius.circular(18),
      bottomRight: Radius.circular(18),
      topLeft: Radius.circular(4),
      bottomLeft: Radius.circular(18),
    );
  }

  Widget _buildAvatar(User? user, {bool isBot = false}) {
    if (isBot) {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/bot_avatar.png'),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
      user?.profilePic != null ? NetworkImage(user!.profilePic!) : null,
      child: user?.profilePic == null
          ? Text(
        user?.initials ?? '?',
        style: const TextStyle(color: Colors.black54, fontSize: 14),
      )
          : null,
    );
  }

  Widget _buildMessageContent(
      BuildContext context,
      WidgetRef ref,
      bool isUser,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBot = !isUser;

    final bubbleColor = isUser ? colorScheme.userBubble : colorScheme.botBubble;
    final bubbleBorderRadius = _getBubbleBorderRadius(isUser);

    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (isBot) ...[
          Row(
            children: [
              Text(
                ref.watch(chatProvider).botUser?.name ?? 'Bot',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'App',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: bubbleBorderRadius,
            boxShadow: isBot && theme.brightness == Brightness.light
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 5.0,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: bubbleBorderRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.repliedTo != null)
                  _buildReplyPreview(context, ref, message.repliedTo!),
                if (message.attachment != null && message.attachment!.isAudio)
                  AudioMessagePlayer(message: message)
                else if (message.attachment != null)
                  _buildAttachmentContent(context, message.attachment!)
                else
                  _buildTextContent(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    String displayText = message.text;

    if (message.type == MessageType.bot) {
      final chatState = ref.watch(chatProvider);
      displayText = getEnrichedQuestion(
        message.text,
        chatState.rawPastResponses,
        chatState.offDays,
        chatState.weekendDays,
      );
    }

    try {
      if (message.richTextJson != null && message.richTextJson!.isNotEmpty) {
        final doc = quill.Document.fromJson(jsonDecode(message.richTextJson!));
        return quill.QuillEditor.basic(
          controller: quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          ),
          config: quill.QuillEditorConfig(
            // readOnly: true,
            showCursor: false,
            autoFocus: false,
            expands: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            onLaunchUrl: (url) async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            customStyles: quill.DefaultStyles(
              paragraph: quill.DefaultTextBlockStyle(
                theme.textTheme.bodyMedium!.copyWith(
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
                const quill.HorizontalSpacing(0, 0),
                const quill.VerticalSpacing(0, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
              link: TextStyle(
                color: theme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error rendering quill content: $e");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SelectableText(
        displayText,
        style: theme.textTheme.bodyMedium!.copyWith(height: 1.4),
      ),
    );
  }

  Widget _buildAttachmentContent(
      BuildContext context,
      MessageAttachment attachment,
      ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            color: theme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              attachment.fileName,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(
      BuildContext context,
      WidgetRef ref,
      Message repliedToMessage,
      ) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);
    final originalAuthor = repliedToMessage.type == MessageType.user
        ? chatState.currentUser
        : chatState.botUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        border: Border(left: BorderSide(color: theme.primaryColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalAuthor?.name ?? 'Unknown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            repliedToMessage.isAttachmentOnly
                ? "Attachment: ${repliedToMessage.attachment!.fileName}"
                : repliedToMessage.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
// --- END OF FILE chat_message_bubble.dart ---