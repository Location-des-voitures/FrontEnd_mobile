/// -------------------------------------------------------
/// USER STATUS BADGE
/// -------------------------------------------------------
/// Badge réutilisable qui affiche le statut d'un user :
///   - Actif   → badge vert "Active"
///   - Inactif → badge rouge "Inactive"
///
/// Utilisation :
///   UserStatusBadge(isActive: user.isActive)
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';

class UserStatusBadge extends StatelessWidget {
  final bool isActive;

  const UserStatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: isActive
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}