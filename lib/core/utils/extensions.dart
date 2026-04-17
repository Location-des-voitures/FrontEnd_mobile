/// -------------------------------------------------------
/// EXTENSIONS
/// -------------------------------------------------------
/// Extensions Dart pour ajouter des méthodes utiles
/// aux types existants (String, DateTime, BuildContext...).
///
/// Ça rend ton code plus lisible :
///   "hello".capitalize    → "Hello"
///   context.screenWidth   → largeur de l'écran
///   DateTime.now().isToday → true
/// -------------------------------------------------------

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════
// STRING EXTENSIONS
// ═══════════════════════════════════════════════════════

extension StringExtensions on String {
  /// Première lettre en majuscule
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Est-ce un email valide ?
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Est-ce un numéro de téléphone marocain ?
  bool get isValidMoroccanPhone {
    return RegExp(r'^(\+212|0)(6|7)\d{8}$').hasMatch(replaceAll(' ', ''));
  }

  /// Convertir en double, null si impossible
  double? get toDoubleOrNull => double.tryParse(this);

  /// Convertir en int, null si impossible
  int? get toIntOrNull => int.tryParse(this);
}

// ═══════════════════════════════════════════════════════
// DATETIME EXTENSIONS
// ═══════════════════════════════════════════════════════

extension DateTimeExtensions on DateTime {
  /// Est-ce aujourd'hui ?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Est-ce hier ?
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Est-ce demain ?
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Est-ce dans le passé ?
  bool get isPast => isBefore(DateTime.now());

  /// Est-ce dans le futur ?
  bool get isFuture => isAfter(DateTime.now());

  /// Nombre de jours entre deux dates
  int daysUntil(DateTime other) => other.difference(this).inDays;
}

// ═══════════════════════════════════════════════════════
// BUILDCONTEXT EXTENSIONS
// ═══════════════════════════════════════════════════════

extension ContextExtensions on BuildContext {
  /// Largeur de l'écran
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Hauteur de l'écran
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Padding du système (notch, barre de navigation)
  EdgeInsets get systemPadding => MediaQuery.paddingOf(this);

  /// Est-ce un petit écran ? (< 360px)
  bool get isSmallScreen => screenWidth < 360;

  /// Est-ce une tablette ? (> 600px)
  bool get isTablet => screenWidth > 600;

  /// Thème actuel
  ThemeData get theme => Theme.of(this);

  /// Color scheme actuel
  ColorScheme get colorScheme => theme.colorScheme;

  /// Text theme actuel
  TextTheme get textTheme => theme.textTheme;

  /// Fermer le clavier
  void hideKeyboard() => FocusScope.of(this).unfocus();
}

// ═══════════════════════════════════════════════════════
// NUM EXTENSIONS
// ═══════════════════════════════════════════════════════

extension NumExtensions on num {
  /// Espacement vertical
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Espacement horizontal
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}