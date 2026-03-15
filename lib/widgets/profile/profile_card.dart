import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../glass_container.dart';
import 'profile_field.dart';

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({
    super.key,
    required this.user,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C5CBF),
                  Color(0xFFB794F4),
                ],
              ),
            ),
            child: Center(
              child: Text(
                _getInitial(user.name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          // Profile fields
          ProfileField(
            label: '이름',
            value: user.name,
          ),
          ProfileField(
            label: '이메일',
            value: user.email,
          ),
        ],
      ),
    );
  }
}
