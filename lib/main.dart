import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/expenses_manager.dart';
import 'package:ymix/managers/income_manager.dart';
import 'package:ymix/managers/wallet_manager.dart';
import 'package:ymix/models/transaction.dart';

import './ui/screen.dart';

import './ui/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      primary: Colors.green.shade600,
      secondary: Colors.blueGrey,
      surface: Colors.white,
      surfaceTint: Colors.white,
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
          create: (ctx) => ExpensesManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => IncomeManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoryManager.instance,
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletManager(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        initialRoute: "/",
        // routes: {
        //   TransactionForm.routeName: (context) => const TransactionForm(null),
        // },
        onGenerateRoute: (settings) {
          //Transaction Form
          if (settings.name == TransactionForm.routeName) {
            final transaction = settings.arguments as Transaction?;
            return MaterialPageRoute(
                builder: (context) => TransactionForm(transaction));
          }
          //Transaction Detail
          else if (settings.name == TransactionDetail.routeName) {
            final transaction = settings.arguments as Transaction;
            return MaterialPageRoute(
                builder: (context) => TransactionDetail(transaction.id!));
          }

          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
        home: const Home(),
      ),
    );
  }
}
