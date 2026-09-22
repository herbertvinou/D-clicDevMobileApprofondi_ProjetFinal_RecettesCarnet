import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Titre réutilisable pour les différentes sections de l'application.
///
/// Exemple :
///
///     Catégories                         →
///
/// La flèche est uniquement une indication
/// visuelle permettant de signaler qu'un contenu
/// horizontal peut être défilé.
class AppSectionTitle extends StatelessWidget {
  final String title;

  /// Affiche une flèche à droite du titre.
  ///
  /// Cette flèche n'est volontairement pas cliquable.
  final bool showScrollHint;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.showScrollHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---------------------------------------------------------------
        // TITRE DE LA SECTION
        // ---------------------------------------------------------------
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ---------------------------------------------------------------
        // INDICATION DE DÉFILEMENT HORIZONTAL
        // ---------------------------------------------------------------
        if (showScrollHint)
          const Icon(
            Icons.arrow_forward,
            color: AppColors.primary,
            size: 28,
          ),
      ],
    );
  }
}