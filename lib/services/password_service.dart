import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Service responsable des opérations liées aux mots de passe.
///
/// Cette classe permet notamment de transformer un mot de passe
/// en une empreinte (hash) avant son stockage dans SQLite.
///
/// Le mot de passe original n'est donc pas enregistré dans la base.
class PasswordService {
  PasswordService._privateConstructor();

  /// Instance unique du service.
  static final PasswordService instance =
  PasswordService._privateConstructor();

  /// Transforme un mot de passe en SHA-256.
  ///
  /// Exemple :
  ///
  /// "admin123"
  ///      ↓
  /// SHA-256
  ///      ↓
  /// "empreinte du mot de passe"
  ///
  /// Nous enregistrerons uniquement cette empreinte dans SQLite.
  String hashPassword(String password) {
    // Transforme le texte du mot de passe en données UTF-8.
    final bytes = utf8.encode(password);

    // Calcule l'empreinte SHA-256.
    final digest = sha256.convert(bytes);

    // Retourne l'empreinte sous forme de texte hexadécimal.
    return digest.toString();
  }

  /// Vérifie si un mot de passe correspond à une empreinte enregistrée.
  ///
  /// Le mot de passe saisi est à nouveau haché puis comparé
  /// à l'empreinte stockée dans SQLite.
  bool verifyPassword(
      String password,
      String storedHash,
      ) {
    // Hache le mot de passe fourni par l'utilisateur.
    final passwordHash = hashPassword(password);

    // Compare le hash calculé avec celui enregistré.
    return passwordHash == storedHash;
  }
}