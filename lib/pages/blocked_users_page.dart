import 'package:chatup/components/user_tile.dart';
import 'package:chatup/services/auth/auth_service.dart';
import 'package:chatup/services/chat/chat_service.dart';

import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({
    super.key,
  });

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  //show confirm unlbock box
  void showUnblockBox(BuildContext context, userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Unblock User'),
              content:
                  const Text('Are you sure you want to unblock this user?'),
              actions: [
                //cancel button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                //unblock button
                TextButton(
                  onPressed: () {
                    chatService.unblockUser(userId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User Unblocked'),
                      ),
                    );
                  },
                  child: const Text('Unblock'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    String userID = authService.getCurrentUser()!.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        title: const Text('blocked Users'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ChatService().getBlockedUserStream(userID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading...'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Loading...'),
                ],
              ),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text('No blocked users'),
            );
          }
          return ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return UserTile(
                  photoUrl: user['photoUrl'],
                      
                  text: user['email'],
                  onTap: () {
                    showUnblockBox(context, user['uid']);
                  },
                  name: user['name'],
                );
              });
        },
      ),
    );
  }
}
