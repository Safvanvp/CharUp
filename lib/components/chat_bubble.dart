import 'package:chatup/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final DateTime timestamp;
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userId,
    required this.timestamp,
  });

  //show options

  void showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
            child: Wrap(
          children: [
            //report message button

            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report'),
              onTap: () {
                //report message

                Navigator.pop(context);
                _reportMassege(context, messageId, userId);
              },
            ),

            //block user button

            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () {
                //block user
                Navigator.pop(context);
                _blockUser(context, userId);
              },
            ),

            //cencel button

            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            //delete message button

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                //delete message
                Navigator.pop(context);
                _deleteMessage(context, messageId);
              },
            ),
          ],
        ));
      },
    );
  }

  //report message

  void _reportMassege(BuildContext conntext, String messageId, String userId) {
    showDialog(
        context: conntext,
        builder: (conntext) => AlertDialog(
              title: Text('report message'),
              content: Text('Are you sure you want to report this message?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () {
                      Navigator.pop(conntext);
                    },
                    child: Text('Cancel')),

                //report button
                TextButton(
                    onPressed: () {
                      //report message
                      ChatService().reportUser(messageId, userId);
                      Navigator.pop(conntext);
                      ScaffoldMessenger.of(conntext).showSnackBar(
                        SnackBar(
                          content: Text('Message reported'),
                        ),
                      );
                    },
                    child: Text('Report')),
              ],
            ));
  }

  //block user

  void _blockUser(BuildContext conntext, String userId) {
    showDialog(
        context: conntext,
        builder: (conntext) => AlertDialog(
              title: Text('block user'),
              content: Text('Are you sure you want to block this user?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () {
                      Navigator.pop(conntext);
                    },
                    child: Text('Cancel')),

                //block button
                TextButton(
                    onPressed: () {
                      ChatService().blockUser(userId);
                      Navigator.pop(conntext);
                      Navigator.pop(conntext);
                      ScaffoldMessenger.of(conntext).showSnackBar(
                        SnackBar(
                          content: Text('User blocked'),
                        ),
                      );
                    },
                    child: Text('Block')),
              ],
            ));
  }

  //delete message

  void _deleteMessage(BuildContext context, String messageId) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final List<String> ids = [
      currentUserID,
      userId
    ]; // userId is the receiver/sender
    ids.sort();
    final chatRoomId = ids.join('_');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatService().deleteMessage(chatRoomId, messageId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          //show options
          showOptions(context, messageId, userId);
        }
      },
      child: Container(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 10,
                left: isCurrentUser ? 60 : 10,
                right: isCurrentUser ? 10 : 60,
              ),
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                right: isCurrentUser ? 20 : 15,
                left: isCurrentUser ? 20 : 15,
              ),
              decoration: BoxDecoration(
                color:
                    isCurrentUser ? Colors.blue.shade400 : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isCurrentUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      isCurrentUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(
                        timestamp), // You'll need to pass this in too
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
