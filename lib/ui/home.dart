import 'package:flutter/material.dart';
import 'package:ymix/ui/spending_limit/spending_limit_form.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent.withAlpha(180),
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: _onFloatingActionButton,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _onFloatingActionButton() {
    switch (_selectedIndex) {
      case 0:
        Navigator.pushNamed(context, TransactionForm.routeName);
        break;
      case 1:
        Navigator.pushNamed(context, WalletForm.routeName);
        break;
      case 2:
        Navigator.pushNamed(context, SpendingLimitForm.routeName);
        break;
    }
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Hi User'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Report'),
            onTap: () => Navigator.pushNamed(context, ReportScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.dataset_linked),
            title: const Text('Data Manager'),
            onTap: () =>
                Navigator.pushNamed(context, DataManagerScreen.routeName),
          ),
        ],
      ),
    );
  }
}
