import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String name;
  final String? photoUrl;
  final bool unread;
  final String? lastMessage;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.photoUrl,
    required this.name,
    this.unread = false,
    this.lastMessage,
    required this.onTap,
  });

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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: photoUrl != null
                  ? Image.network(
                      photoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'Images/3d-black-icon-user-account-person-for-user-interface-website-mobile-apps-free-png.webp',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : const Icon(Icons.person),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      )),
                  if (lastMessage != null)
                    Text(
                      lastMessage!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
