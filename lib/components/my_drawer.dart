import 'package:chatup/pages/image_analyze_ai.dart';
import 'package:chatup/pages/chat_ai.dart';
import 'package:chatup/services/auth/auth_service.dart';
import 'package:chatup/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userName = '';
  String userEmail = '';

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      final uid = currentUser.uid;
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'];
          userEmail = doc['email'];
        });
      }
    }
  }

  void logout() {
    _authService.signOut();
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 70,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName.isNotEmpty ? userName : "Loading...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Text(
                      userEmail.isNotEmpty ? userEmail : "",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Home tile
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  leading: Icon(Icons.home,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text('HOME',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      )),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              //my ai tile
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  leading: Icon(Icons.memory_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    'AI TOOLS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    ListTile(
                      leading: Icon(Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text('Chat AI',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatAi()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image_search_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text('Image Analyze AI',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageAnalyzeAi()),
                        );
                      },
                    ),
                    // Add more tools in future here
                  ],
                ),
              ),

              // Settings tile
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListTile(
                  leading: Icon(Icons.settings,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text('SETTINGS',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                ),
              ),
            ],
          ),

          // Logout tile
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 25),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('LOGOUT',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary)),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
