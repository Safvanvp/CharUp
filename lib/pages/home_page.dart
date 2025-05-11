import 'package:chatup/components/my_drawer.dart';
import 'package:chatup/components/user_tile.dart';
import 'package:chatup/pages/chat_page.dart';
import 'package:chatup/pages/chat_ai.dart';
import 'package:chatup/services/auth/auth_service.dart';
import 'package:chatup/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //reload
  Future<void> _reload() async {
    return await Future.delayed(const Duration(seconds: 1));
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatAi(),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // 🔍 Search Bar
  Widget _buildSearchBar(context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query.trim(); // update query
            });
          },
          decoration: InputDecoration(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // 👥 User List (dynamic stream based on query)
  Widget _buildUserList() {
    final isSearching = _searchQuery.isNotEmpty;
    final stream = isSearching
        ? _chatService.searchUser(_searchQuery)
        // : _chatService.getSharedChatrooms(_authService.getCurrentUser()!.email!);
        : _chatService.getUsersWithLastMessageAndUnread(
            _authService.getCurrentUser()!.uid);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return LiquidPullToRefresh(
          onRefresh: _reload,
          color: Theme.of(context).colorScheme.secondary,
          height: 100,
          animSpeedFactor: 2,
          showChildOpacityTransition: false,
          child: ListView(
            children: users
                .map((userData) => _buildUserListItem(userData, context))
                .toList(),
          ),
        );
      },
    );
  }

  // Individual user tile
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData['email'],
        name: userData['name'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverName: userData['name'],
                receiverID: userData['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
