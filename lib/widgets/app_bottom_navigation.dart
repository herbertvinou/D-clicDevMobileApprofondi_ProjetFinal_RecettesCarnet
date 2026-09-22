import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Navigation principale de l'application.
///
/// Ce widget est volontairement réutilisable.
/// Il ne connaît pas les pages de l'application.
/// Il se contente de signaler quel élément a été sélectionné.
///
/// La page qui utilise ce widget reste responsable
/// de gérer la navigation réelle.
class AppBottomNavigation extends StatelessWidget {
  /// Index de l'élément actuellement sélectionné.
  final int currentIndex;

  /// Fonction appelée lorsqu'un élément est sélectionné.
  final ValueChanged<int> onItemSelected;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onItemSelected,

      // Couleur de fond de la navigation.
      backgroundColor: AppColors.white,

      // Couleur utilisée pour l'élément sélectionné.
      indicatorColor: AppColors.lightBlue.withValues(alpha: 0.35),

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),

        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Mes recettes',
        ),

        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoris',
        ),

        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}