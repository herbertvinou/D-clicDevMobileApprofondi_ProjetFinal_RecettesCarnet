import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Thème global de RecettesCarnet.
///
/// Cette classe centralise l'apparence générale de l'application :
///
/// - couleurs ;
/// - typographie ;
/// - boutons ;
/// - champs de saisie ;
/// - cartes ;
/// - AppBar ;
/// - navigation inférieure.
///
/// L'objectif est d'éviter de redéfinir ces propriétés
/// dans chaque écran.
class AppTheme {
  AppTheme._();

  /// Thème clair principal de RecettesCarnet.
  static ThemeData lightTheme = ThemeData(
    // ------------------------------------------------------------
    // COULEUR PRINCIPALE
    // ------------------------------------------------------------

    /// Couleur principale utilisée par les composants Material.
    primaryColor: AppColors.primary,

    /// Couleur de fond générale de l'application.
    scaffoldBackgroundColor: AppColors.white,

    /// Utilisation de Material 3.
    useMaterial3: true,

    // ------------------------------------------------------------
    // PALETTE MATERIAL
    // ------------------------------------------------------------

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    // ------------------------------------------------------------
    // TYPOGRAPHIE
    // ------------------------------------------------------------

    textTheme: const TextTheme(
      /// Très grand titre.
      displayLarge: TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.bold,
      ),

      /// Grand titre.
      displayMedium: TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.bold,
      ),

      /// Titre d'écran.
      headlineMedium: TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.bold,
      ),

      /// Titre de section.
      titleLarge: TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.bold,
      ),

      /// Texte courant.
      bodyLarge: TextStyle(
        color: AppColors.dark,
      ),

      /// Texte secondaire.
      bodyMedium: TextStyle(
        color: AppColors.gray,
      ),

      /// Petit texte.
      bodySmall: TextStyle(
        color: AppColors.gray,
      ),
    ),

    // ------------------------------------------------------------
    // CHAMPS DE SAISIE
    // ------------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,

      /// Bordure normale du champ.
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.lightGray,
        ),
      ),

      /// Bordure lorsque le champ est sélectionné.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      /// Bordure en cas d'erreur.
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      /// Bordure lorsque le champ contenant une erreur
      /// reçoit le focus.
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),

    // ------------------------------------------------------------
    // BOUTONS PRINCIPAUX
    // ------------------------------------------------------------

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ------------------------------------------------------------
    // BOUTONS SECONDAIRES
    // ------------------------------------------------------------

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        side: const BorderSide(
          color: AppColors.primary,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ------------------------------------------------------------
    // CARTES
    // ------------------------------------------------------------

    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.lightGray,
        ),
      ),

      margin: EdgeInsets.zero,
    ),

    // ------------------------------------------------------------
    // APP BAR
    // ------------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.deepNavy,
      elevation: 0,
      centerTitle: false,
    ),
  );
}