import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final String userName; // ✅ Add this

  const HomeAppBar({
    super.key,
    required this.userName, // ✅ Add this
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";

    if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17) {
      greeting = "Good Evening";
    }

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$greeting 👋",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.notifications_none),
        )
      ],
    );
  }
}