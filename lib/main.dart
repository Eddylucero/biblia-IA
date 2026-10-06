import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'screens/bible/chapter_view_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/main_navigation.dart';
import 'repositories/bible_repository.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final BibleDataSource? bibleDataSource;

  const MyApp({super.key, this.bibleDataSource});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblia',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          surface: AppColors.bgSurface,
        ),
        scaffoldBackgroundColor: AppColors.bgSurface,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainNavigationScreen(dataSource: bibleDataSource),
        '/bible': (context) =>
            MainNavigationScreen(initialIndex: 1, dataSource: bibleDataSource),
        '/chapter': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          final routeArguments = arguments is Map
              ? arguments
              : const <String, Object>{};
          final bookName = routeArguments['bookName'];
          final chapterNumber = routeArguments['chapterNumber'];
          final bookId = routeArguments['bookId'];
          final chaptersCount = routeArguments['chaptersCount'];
          final selectedVerseNumber = routeArguments['selectedVerseNumber'];

          return ChapterViewScreen(
            bookId: bookId is int ? bookId : 0,
            bookName: bookName is String ? bookName : 'Juan',
            chapterNumber: chapterNumber is int ? chapterNumber : 3,
            chaptersCount: chaptersCount is int ? chaptersCount : 0,
            selectedVerseNumber: selectedVerseNumber is int
                ? selectedVerseNumber
                : null,
            dataSource: bibleDataSource,
          );
        },
        '/favorites': (context) => const FavoritesScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) =>
            MainNavigationScreen(initialIndex: 2, dataSource: bibleDataSource),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
