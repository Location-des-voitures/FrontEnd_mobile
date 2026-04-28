import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'user_list_screen.dart';

/// Stub — à implémenter avec la maquette du profil loueur
class UserProfileScreen extends StatelessWidget {
  final UserListItem user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user.fullName),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Profile screen — coming soon',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}