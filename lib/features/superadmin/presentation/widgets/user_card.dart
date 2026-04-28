/// -------------------------------------------------------
/// USER CARD
/// -------------------------------------------------------
/// Card réutilisable pour afficher un user dans la liste.
/// Affiche : avatar (initiales), nom, email, rôle, statut.
/// Tap → navigue vers le détail.
///
/// Utilisation :
///   UserCard(
///     user: user,
///     onTap: () => context.push('/super-admin/users/${user.id}'),
///   )
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../auth/domain/entities/user.dart';
import 'user_status_badge.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E7E4).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // ── Avatar (initiales) ─────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor(user.role),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  AppFormatters.initials(user.name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Infos (nom, email) ─────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Rôle + Statut ──────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge rôle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _roleColor(user.role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: _roleColor(user.role),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Badge statut
                UserStatusBadge(isActive: user.isActive),
              ],
            ),

            // ── Chevron ────────────────────────────────
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  /// Couleur de l'avatar selon le rôle
  Color _avatarColor(String role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF7C3AED); // Violet
      case 'admin':
        return const Color(0xFF3B5BDB); // Bleu
      default:
        return const Color(0xFF6B7280); // Gris
    }
  }

  /// Couleur du badge rôle
  Color _roleColor(String role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF7C3AED);
      case 'admin':
        return const Color(0xFF3B5BDB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Label du rôle
  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'SUPER ADMIN';
      case 'admin':
        return 'ADMIN';
      default:
        return 'CLIENT';
    }
  }
}