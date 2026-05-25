/// -------------------------------------------------------
/// VALIDATORS — Aligné sur les règles de validation API
/// -------------------------------------------------------
/// API validation rules :
///   name     → required, string, max:255
///   email    → required, email, unique
///   password → required, min:8, confirmed
/// -------------------------------------------------------
library;

class Validators {
  Validators._();

  /// Champ obligatoire
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Nom (API: required, string, max:255)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length > 255) {
      return 'Maximum 255 caractères';
    }
    return null;
  }

  /// Email (API: required, email, unique)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  /// Mot de passe (API: required, min:8, confirmed)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    return null;
  }

  /// Confirmation de mot de passe (API: confirmed)
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirmez le mot de passe';
      }
      if (value != password) {
        return 'Les mots de passe ne correspondent pas';
      }
      return null;
    };
  }

  /// Numéro de téléphone marocain
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }
    final phoneRegex = RegExp(r'^(\+212|0)(6|7)\d{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Longueur minimale
  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Ce champ est obligatoire';
      }
      if (value.trim().length < min) {
        return 'Minimum $min caractères';
      }
      return null;
    };
  }

  /// Nombre positif
  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Entrez un nombre positif';
    }
    return null;
  }

  /// Prix valide
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le prix est obligatoire';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Prix invalide';
    }
    return null;
  }

  /// Combiner plusieurs validateurs
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}