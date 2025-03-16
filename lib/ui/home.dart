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
    const WalletScreen(),
    const SpendingLimitScreen(),
  ];

  final List<Widget> _pagesIcon = <Widget>[
    const NavigationDestination(icon: Icon(Icons.home), label: "Home"),
    const NavigationDestination(icon: Icon(Icons.wallet), label: "Wallet"),
    const NavigationDestination(
        icon: Icon(Icons.show_chart), label: "Spending Limit"),
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
        leading: Builder(
          builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu));
          },
        ),
      ),
      drawer: _buildAppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        destinations: _pagesIcon,
        animationDuration: const Duration(seconds: 1),
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.green.shade200,
        indicatorColor: Colors.green,
      ),
      floatingActionButton:
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
