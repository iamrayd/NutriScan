import 'package:flutter/material.dart';
import 'package:nutriscan/utils/utils.dart';
import '../services/auth_service.dart';

class ScreenHandler extends StatefulWidget {
  const ScreenHandler({super.key});

  @override
  State<ScreenHandler> createState() => _ScreenHandlerState();
}

class _ScreenHandlerState extends State<ScreenHandler> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Meals Page")),
    const HistoryScreen(),
    const SavedProductsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    "Home",
    "Meals",
    "Scan History",
    "Saved Products",
    "Profile",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(milliseconds: 500),
      width: MediaQuery.of(context).size.width * 0.95,
      curve: Curves.decelerate,
      barColor: Colors.black,
      body: (context, controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: _titles[_selectedIndex]),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppColors.clipper),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                onTap: () async {
                  await _authService.signOut();
                  AppNavigator.pushAndRemoveUntil(context, SignInScreen());
                },
              ),
            ],
          ),
        ),
        body: SafeArea(child: _pages[_selectedIndex]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _floatingIconButton(Icons.person, 4),
          _floatingIconButton(Icons.restaurant, 1),
          _floatingIconButton(Icons.home, 0),
          _floatingIconButton(Icons.history, 2),
          _floatingIconButton(Icons.star, 3),
        ],
      ),
    );
  }

  Widget _floatingIconButton(IconData icon, int index) {
    return FloatingActionButton(
      heroTag: index,
      backgroundColor: _selectedIndex == index ? Colors.grey[200] : Colors.black,
      onPressed: () => _onItemTapped(index),
      mini: true,
      elevation: 2,
      child: Icon(
        icon,
        color: _selectedIndex == index ? Colors.black : Colors.white,
        size: 20,
      ),
    );
  }
}