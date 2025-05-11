import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditDetailsPage extends StatefulWidget {
  const EditDetailsPage({super.key});

  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  DateTime? _selectedDOB;

  // Calculate age from DOB
  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Pick DOB
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDOB = pickedDate;
      });
    }
  }

  // Update details in Firestore
  Future<void> _updateDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();

    if (!phone.startsWith('+91')) {
      phone = '+91 $phone';
    }

    int? age;
    if (_selectedDOB != null) {
      age = calculateAge(_selectedDOB!);
    }

    String bio = _bioController.text.trim();

    Map<String, dynamic> updateData = {};

    if (phone.isNotEmpty) updateData['phoneNumber'] = phone;
    if (name.isNotEmpty) updateData['name'] = name;
    if (age != null) updateData['age'] = age;
    if (bio.isNotEmpty) updateData['bio'] = bio;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String dobText = _selectedDOB != null
        ? DateFormat.yMMMMd().format(_selectedDOB!)
        : 'Pick your Date of Birth';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Edit Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // DOB Picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  dobText,
                  style: TextStyle(
                    color: _selectedDOB == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your name',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phone Input
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your phone number',
                ),
              ),
            ),
            const SizedBox(height: 20),

            //bio
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: _bioController,
                minLines: 1,
                maxLines: null, // allows it to grow as needed
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your bio',
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Update Button
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: _updateDetails,
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )),
            //
          ],
        ),
      ),
    );
  }
}
