import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';

class ChatAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  ConsumerState<ChatAppBar> createState() => _ChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

class _ChatAppBarState extends ConsumerState<ChatAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        // Request focus when search opens
        _searchFocusNode.requestFocus();
      } else {
        // Clear search when it closes
        _searchController.clear();
        ref.read(chatProvider.notifier).setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = theme.textTheme.titleLarge?.color?.withOpacity(0.8);

    // Watch for theme changes to update the theme toggle icon
    final themeMode = ref.watch(themeProvider);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 2,
      leading: _isSearching
          ? null // Hide leading icon when searching to make space
          : IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      title: _isSearching
          ? TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          border: InputBorder.none,
          hintStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
        onChanged: (query) {
          ref.read(chatProvider.notifier).setSearchQuery(query);
        },
        style: theme.textTheme.titleLarge,
      )
          : InkWell(
        onTap: () {
          // TODO: Implement channel switcher dropdown
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DailyBot',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: iconColor, size: 20),
          ],
        ),
      ),
      actions: _isSearching
          ? [
        IconButton(
          icon: Icon(Icons.close, color: iconColor),
          onPressed: _toggleSearch,
        ),
      ]
          : [
        IconButton(
          icon: Icon(Icons.search, color: iconColor),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: iconColor,
          ),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
      ],
      bottom: TabBar(
        labelColor: colorScheme.primary,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        indicatorColor: colorScheme.primary,
        tabs: const [
          Tab(text: 'Chat'),
          Tab(text: 'About'),
        ],
      ),
    );
  }
}