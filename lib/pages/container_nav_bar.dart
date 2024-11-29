import 'package:flutter/material.dart';

//service
import 'package:strive_project/services/auth_service.dart';

//page
import 'package:strive_project/pages/index.dart';

class ContainerBar extends StatefulWidget {
  ContainerBar({Key? key}) : super(key: key);

  @override
  _ContainerBarState createState() => _ContainerBarState();
}

class _ContainerBarState extends State<ContainerBar> {
  int _selectedIndex = 0;

  //List of pages for the bottom navigation
  final List<Widget> _pages = [
    HomePage(),
    FocusTimePage(),
    SocialSharePage(),
    NearbySpotPage(),
    AccountPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index when tapped
    });
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  // Sign out button widget
  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  // Display content based on selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,  // Change the index when a nav item is tapped
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later_outlined),
            label: 'Focus Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Spots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),

    );
  }
}
