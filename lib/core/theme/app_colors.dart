import 'package:flutter/material.dart';

/// Palette officielle de conception de RecettesCarnet.
///
/// Cette classe centralise toutes les couleurs principales
/// utilisées dans l'application.
///
/// L'objectif est d'éviter de disperser les valeurs hexadécimales
/// directement dans les différents écrans et widgets.
///
/// Exemple :
///
/// Au lieu de :
///
/// Color(0xFF115ADA)
///
/// on utilisera :
///
/// AppColors.primary
class AppColors {
  AppColors._();

  // ============================================================
  // COULEURS PRINCIPALES
  // ============================================================

  /// Bleu primaire de RecettesCarnet.
  static const Color primary = Color(0xFF115ADA);

  /// Bleu foncé utilisé pour les éléments importants.
  static const Color primaryDark = Color(0xFF0946DC);

  /// Bleu très foncé utilisé notamment pour les titres.
  static const Color navy = Color(0xFF092E86);

  /// Bleu profond utilisé pour les titres à fort contraste.
  static const Color deepNavy = Color(0xFF17336E);

  // ============================================================
  // COULEURS SECONDAIRES
  // ============================================================

  /// Bleu gris utilisé pour les textes secondaires
  /// et certains éléments d'interface.
  static const Color blueGray = Color(0xFF4A689F);

  /// Bleu clair utilisé notamment pour les éléments
  /// secondaires et certains arrière-plans.
  static const Color lightBlue = Color(0xFF9AB2D5);

  // ============================================================
  // COULEURS NEUTRES
  // ============================================================

  /// Gris très clair utilisé notamment pour les bordures
  /// et les séparations.
  static const Color lightGray = Color(0xFFE4E6E8);

  /// Gris utilisé pour les textes secondaires.
  static const Color gray = Color(0xFF818282);

  /// Couleur sombre utilisée pour le texte courant.
  static const Color dark = Color(0xFF292C2C);

  // ============================================================
  // COULEURS UTILITAIRES
  // ============================================================

  /// Couleur utilisée pour représenter les recettes favorites.
  static const Color favorite = Color(0xFFE53935);

  /// Surface principale de l'application.
  static const Color white = Colors.white;

  /// Noir.
  static const Color black = Colors.black;

  // ============================================================
  // DÉGRADÉS
  // ============================================================

  /// Premier dégradé bleu utilisé pour les éléments
  /// de mise en valeur.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primaryDark,
      Color(0xFF42A5F5),
    ],
  );

  /// Second dégradé bleu proposé par le cahier des charges.
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      primary,
      Color(0xFF2196F3),
    ],
  );
}