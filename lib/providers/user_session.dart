import 'package:flutter/foundation.dart';

/// Représente la session de l'utilisateur actuellement connecté.
///
/// Cette classe est un Singleton :
/// une seule instance de UserSession existe dans toute l'application.
///
/// Elle permet de conserver les informations essentielles
/// de l'utilisateur connecté entre les différentes pages.
class UserSession extends ChangeNotifier {
  UserSession._();

  /// Instance unique de la session utilisateur.
  static final UserSession instance = UserSession._();

  /// Identifiant SQLite de l'utilisateur connecté.
  int? _userId;

  /// Nom d'utilisateur de l'utilisateur connecté.
  String? _username;

  /// Retourne l'identifiant de l'utilisateur connecté.
  int? get userId => _userId;

  /// Retourne le nom d'utilisateur de l'utilisateur connecté.
  String? get username => _username;

  /// Indique si un utilisateur est actuellement connecté.
  bool get isLoggedIn => _userId != null;

  /// Enregistre les informations de l'utilisateur connecté.
  ///
  /// [userId] correspond à l'identifiant SQLite.
  /// [username] correspond au nom d'utilisateur.
  void setUser({
    required int userId,
    required String username,
  }) {
    _userId = userId;
    _username = username;

    notifyListeners();
  }

  /// Supprime les informations de la session actuelle.
  ///
  /// Cette méthode sera notamment utilisée lors de la déconnexion.
  void clearUser() {
    _userId = null;
    _username = null;

    notifyListeners();
  }
}