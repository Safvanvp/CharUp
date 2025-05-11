import 'package:chatup/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  //getinstence of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream

  /*

  List<Map<String, dynamic>> = [
    {
    'email' : test@gmail.com,
    'id' : ..,
    }
    {
    'email' : test@gmail.com,
    'id' : ..,
    }
  ]

  */

  //get all users stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((docs) {
        final user = docs.data();

        return user;
      }).toList();
    });
  }

  

  //order by last message

  Stream<List<Map<String, dynamic>>> getUsersWithLastMessageAndUnread(String currentUserId) {
  return _firestore
      .collection('chat_rooms')
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    List<Map<String, dynamic>> userList = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final participants = data['users'] as List<dynamic>;

      if (!participants.contains(currentUserId)) continue;

      final otherUserId = participants.firstWhere((id) => id != currentUserId);
      final userDoc = await _firestore.collection('Users').doc(otherUserId).get();
      final userData = userDoc.data();

      if (userData == null) continue;

      userList.add({
        'uid': otherUserId,
        'name': userData['name'],
        'email': userData['email'],
        'lastMessage': data['lastMessage'],
        'unread': (data['unreadMessages']?[userData['email']] ?? 0) > 0,
      });
    }

    return userList;
  });
}


  //get users only i share chatroom with

  Stream<List<Map<String, dynamic>>> getSharedChatrooms(
      String currentUserEmail) {
    return _firestore
        .collection('chatrooms')
        .where('users',
            arrayContains:
                currentUserEmail) // Check if the current user is in the chatroom
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  //get all users stream except blocked users

  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final usersSnapshot = await _firestore.collection('Users').get();

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  //generate chatroom id
  String generateChatRoomId(String userEmail1, String userEmail2) {
  List<String> sortedEmails = [userEmail1, userEmail2]..sort();
  return '${sortedEmails[0]}_${sortedEmails[1]}';
}



  //get only user who are not blocked and chatroom with current user

  Future<void> markMessagesAsRead(String chatRoomId, String userEmail) async {
  final docRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
  await docRef.update({
    'unreadMessages.$userEmail': 0,
  });
}


  //send message

  Future<void> sendMessage({
  required String chatRoomId,
  required Message message,
}) async {
  final docRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);

  // Add message to messages subcollection
  await docRef.collection('messages').add(message.toMap());

  final chatRoomSnapshot = await docRef.get();
  final chatRoomData = chatRoomSnapshot.data()!;
  final users = List<String>.from(chatRoomData['users']);
  final receiverEmail = users.firstWhere((email) => email != message.senderEmail);

  // Update last message + unread counts
  await docRef.update({
    'lastMessage': message.message,
    'lastMessageTime': message.timestamp,
    'unreadMessages.$receiverEmail': FieldValue.increment(1),
  });
}


  //get messages

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  //report user

  Future<void> reportUser(String messageID, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reporterID': currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  //Block user

  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userID)
        .set({});
    notifyListeners();
  }

  //unblock user

  Future<void> unblockUser(blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserID)
        .delete();
  }

  //delete message

  Future<void> deleteMessage(String roomId, String messageID) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageID)
        .delete();
  }

  //get bloked user stream

  Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userID) {
    return _firestore
        .collection('Users')
        .doc(userID)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
      final userDocs = await Future.wait(blockedUserIds
          .map((id) => _firestore.collection('Users').doc(id).get()));

      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  //serach user
  // Search user function
  Stream<List<Map<String, dynamic>>> searchUser(String query) {
    final lowerQuery = query.toLowerCase();

    return _firestore.collection('Users').snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) {
            final user = doc.data();

            final email = user['email']?.toString().toLowerCase();
            final name = user['name']?.toString().toLowerCase();

            final emailMatch = email != null && email.contains(lowerQuery);
            final nameMatch = name != null && name.contains(lowerQuery);

            return emailMatch || nameMatch ? user : null;
          })
          .where((user) => user != null)
          .cast<Map<String, dynamic>>() // 👈 Cast to correct type
          .toList();

      return results;
    });
  }
}
