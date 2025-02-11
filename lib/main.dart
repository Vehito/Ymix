import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './ui/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.cyan,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
        fontFamily: 'Times New Roman',
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shadowColor: colorScheme.shadow,
        ));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => TransactionsManager(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ymix'),
          ),
          body: const TransactionsScreen(),
        ),
      ),
    );
  }
}
