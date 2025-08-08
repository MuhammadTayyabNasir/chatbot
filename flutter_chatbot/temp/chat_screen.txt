import 'package:flutter/material.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_list_view.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Corresponds to the 'Chat' and 'About' tabs
      child: Scaffold(
        appBar: const ChatAppBar(),
        body: TabBarView(
          children: [
            // Chat Tab Content
            const Column(
              children: [
                Expanded(child: ChatListView()),
                ChatInputBar(),
              ],
            ),
            // About Tab Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/bot_avatar.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DailyBot',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your friendly standup assistant.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}