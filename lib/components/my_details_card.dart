import 'package:chatup/pages/edit_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDetailsCard extends StatelessWidget {
  const MyDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("No user found"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No data found"));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'Images/image.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'Images/3d-black-icon-user-account-person-for-user-interface-website-mobile-apps-free-png.webp',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditDetailsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 31, 184, 0),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.edit, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labelText("Name"),
                    valueText(userData['name'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    labelText("Email"),
                    valueText(userData['email'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    labelText("Age"),
                    valueText(userData['age']?.toString() ?? 'N/A'),
                    const SizedBox(height: 10),
                    labelText("Phone"),
                    valueText(userData['phoneNumber'] ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget labelText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget valueText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    );
  }
}
