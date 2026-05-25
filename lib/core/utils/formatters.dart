/// -------------------------------------------------------
/// FORMATTERS (Formatage)
/// -------------------------------------------------------
/// Fonctions pour formater les dates, prix, durées, etc.
/// Utilisées partout dans l'UI.
///
/// Utilisation :
///   AppFormatters.price(250)     → "250,00 DH"
///   AppFormatters.date(dateObj)  → "15/04/2026"
/// -------------------------------------------------------
library;

import '../constants/app_constants.dart';

class AppFormatters {
  AppFormatters._();

  // ── Prix ─────────────────────────────────────────────

  /// Formate un prix en DH
  /// price(250) → "250,00 DH"
  /// price(1500.5) → "1 500,50 DH"
  static String price(double amount) {
    // Séparer la partie entière et décimale
    final parts = amount.toStringAsFixed(2).split('.');
    final integer = parts[0];
    final decimal = parts[1];

    // Ajouter les espaces pour les milliers
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integer[i]);
    }

    return '${buffer.toString()},$decimal ${AppConstants.currency}';
  }

  /// Prix court (sans décimales si entier)
  /// priceShort(250) → "250 DH"
  /// priceShort(250.5) → "250,50 DH"
  static String priceShort(double amount) {
    if (amount == amount.truncateToDouble()) {
      return '${amount.toInt()} ${AppConstants.currency}';
    }
    return price(amount);
  }

  /// Prix par jour
  /// pricePerDay(300) → "300 DH/jour"
  static String pricePerDay(double amount) {
    return '${priceShort(amount)}/jour';
  }

  // ── Dates ────────────────────────────────────────────

  /// Formate une date : "15/04/2026"
  static String date(DateTime date) {
    return '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
  }

  /// Formate date + heure : "15/04/2026 14:30"
  static String dateTime(DateTime date) {
    return '${_pad(date.day)}/${_pad(date.month)}/${date.year} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  /// Heure seule : "14:30"
  static String time(DateTime date) {
    return '${_pad(date.hour)}:${_pad(date.minute)}';
  }

  /// Date relative : "Aujourd'hui", "Hier", "Il y a 3 jours"
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes < 1) return 'À l\'instant';
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours}h';
    }
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    if (diff.inDays < 30) return 'Il y a ${diff.inDays ~/ 7} semaines';
    if (diff.inDays < 365) return 'Il y a ${diff.inDays ~/ 30} mois';
    return 'Il y a ${diff.inDays ~/ 365} ans';
  }

  /// Période : "15/04 - 20/04/2026"
  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${_pad(start.day)} - ${_pad(end.day)}/${_pad(end.month)}/${end.year}';
    }
    return '${date(start)} - ${date(end)}';
  }

  // ── Durées ───────────────────────────────────────────

  /// Durée en jours : "3 jours", "1 jour"
  static String duration(int days) {
    if (days == 1) return '1 jour';
    return '$days jours';
  }

  /// Durée entre deux dates
  static String durationBetween(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return duration(days);
  }

  // ── Texte ────────────────────────────────────────────

  /// Tronque un texte long : "Lorem ipsum dolor si..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Première lettre en majuscule
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Initiales d'un nom : "Mohammed Ali" → "MA"
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── Numéros ──────────────────────────────────────────

  /// Formate un téléphone : "06 12 34 56 78"
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} '
          '${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} '
          '${cleaned.substring(8, 10)}';
    }
    return phone;
  }

  /// Kilomètres : "45 230 km"
  static String km(int kilometers) {
    final str = kilometers.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} km';
  }

  // ── Helpers privés ───────────────────────────────────

  static String _pad(int n) => n.toString().padLeft(2, '0');
}