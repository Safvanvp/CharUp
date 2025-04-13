import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String name;
  final void Function()? onTap;

  const UserTile(
      {super.key, required this.text, required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
