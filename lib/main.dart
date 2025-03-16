import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ymix/models/transactions.dart';
import 'package:ymix/models/wallet.dart';

import './ui/screen.dart';
import './managers/managers.dart';

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
        ),
        ChangeNotifierProvider(
          create: (ctx) => ExpensesManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => IncomeManager.instance,
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoryManager.instance,
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletManager.instance,
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrencyManager.instance,
        ),
        ChangeNotifierProvider(
          create: (ctx) => SpendingLimitManager.instance,
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
            final transaction = settings.arguments as Transactions?;
            return MaterialPageRoute(
                builder: (context) => TransactionForm(transaction));
          }
          //Transaction Detail
          else if (settings.name == TransactionDetail.routeName) {
            final transaction = settings.arguments as Transactions;
            return MaterialPageRoute(
                builder: (context) => TransactionDetail(transaction.id!));
          }
          // Wallet Form
          else if (settings.name == WalletForm.routeName) {
            final wallet = settings.arguments as Wallet?;
            return MaterialPageRoute(builder: (context) => WalletForm(wallet));
          }
          // Transaction List
          else if (settings.name == TransactionList.routeName) {
            final data = settings.arguments;
            if (data is List<String>) {
              return MaterialPageRoute(
                  builder: (context) => TransactionList(transactionsId: data));
            } else {
              return MaterialPageRoute(
                  builder: (context) =>
                      TransactionList(categoryId: data as String));
            }
          }

          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
        home: const Home(),
      ),
    );
  }
}
