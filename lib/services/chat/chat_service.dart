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

  //get only user who are not blocked and chatroom with current user

  //send message

  Future<void> sendMessage(String receiverID, message) async {
    //get current user info

    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chatroom id for the two users(sorted to ensure uniqueness)

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    //add new message to database

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(
          newMessage.toMap(),
        );
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
