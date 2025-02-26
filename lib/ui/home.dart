import 'package:flutter/material.dart';
import 'screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const TransactionsScreen(),
    Container(
      color: Colors.red,
    )
  ];

  final List<Widget> _pagesIcon = <Widget>[
    const NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    const NavigationDestination(icon: Icon(Icons.timeline), label: "Target"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ymix"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: _pagesIcon,
        animationDuration: const Duration(seconds: 1),
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.green.shade200,
        indicatorColor: Colors.green,
      ),
    );
  }
}
