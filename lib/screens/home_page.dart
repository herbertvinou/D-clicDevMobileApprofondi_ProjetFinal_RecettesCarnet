import 'package:flutter/material.dart';
import 'package:recettescarnet/screens/recipe_detail_page.dart';
import 'package:recettescarnet/screens/search_page.dart';

import '../core/theme/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/user_session.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_section_title.dart';
import '../widgets/recipe_card.dart';

import 'package:provider/provider.dart';
import 'package:recettescarnet/screens/favorites_page.dart';



/// Écran principal de l'application.
///
/// Cette page présente :
/// - le message de bienvenue de l'utilisateur connecté ;
/// - la barre de recherche ;
/// - la bannière "Recettes du monde" ;
/// - les catégories provenant de TheMealDB ;
/// - les recettes du moment ;
/// - la navigation principale.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Index de l'élément sélectionné dans la navigation.
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Récupère le Provider des catégories.
    final categoryProvider =
    Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Récupère le Provider des recettes.
    final mealProvider =
    Provider.of<MealProvider>(
      context,
      listen: false,
    );

    // Charge les catégories depuis TheMealDB.
    categoryProvider.loadCategories();

    // Charge 5 recettes aléatoires depuis TheMealDB.
    mealProvider.loadRandomMeals(
      count: 5,
      // count: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération de la session de l'utilisateur connecté.
    final userSession = UserSession.instance;

    return Scaffold(
      backgroundColor: AppColors.white,

      // ------------------------------------------------------------
      // CONTENU PRINCIPAL
      // ------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // EN-TÊTE
              // ----------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${userSession.username ?? ''} 👋',

                          // Le nom reste sur une seule ligne.
                          maxLines: 1,

                          // Si le nom est trop long, Flutter
                          // affiche automatiquement "...".
                          overflow: TextOverflow.ellipsis,

                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.bold,

                            // Taille légèrement réduite
                            // pour mieux gérer les noms longs.
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Prêt à découvrir une nouvelle recette ?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton de notification.
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Action à implémenter plus tard.
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------
              // BARRE DE RECHERCHE
              // ----------------------------------------------------
              TextField(
                readOnly: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Rechercher une recette...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),

              //const SizedBox(height: 24),
              /*

              // ----------------------------------------------------
              // BANNIÈRE "RECETTES DU MONDE"
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                height: 250,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // ------------------------------------------------
                    // CONTENU TEXTUEL
                    // ------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Padding(
                        // On réserve une partie de la droite
                        // pour l'illustration.
                        padding: const EdgeInsets.only(
                          right: 95,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            /*
                            const Icon(
                              Icons.public,
                              size: 34,
                              color: AppColors.white,
                            ),

                             */

                            const SizedBox(height: 14),

                            Text(
                              'Recettes du monde',
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color:
                                AppColors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Expanded(
                              child: Text(
                                'Découvrez de nouvelles saveurs '
                                    'venues des quatre coins du monde.',
                                maxLines: 3,
                                overflow:
                                TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: AppColors
                                      .white
                                      .withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),

                            FilledButton(
                              onPressed: () {
                                // Action à implémenter plus tard.
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                AppColors.white,
                                foregroundColor:
                                AppColors.primaryDark,
                              ),
                              child: const Text(
                                'Découvrir',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // ILLUSTRATION TRANSPARENTE
                    // ------------------------------------------------
                    Positioned(
                      right: -18,
                      bottom: -12,
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets/images/world_recipes.png',
                          width: 165,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),


               */
              const SizedBox(height: 28),



              // ----------------------------------------------------
              // ILLUSTRATION « RECETTES DU MONDE »
              //
              // L'illustration porte maintenant elle-même
              // le message de découverte et de cuisine du monde.
              // ----------------------------------------------------
              SizedBox(
                height: 340,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/world_recipes.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------
              // CATÉGORIES
              // ----------------------------------------------------
              const AppSectionTitle(
                title: 'Catégories',
                showScrollHint: true,
              ),
              const SizedBox(height: 14),

              Consumer<CategoryProvider>(
                builder: (
                    context,
                    categoryProvider,
                    child,
                    ) {
                  // Pendant la récupération des catégories.
                  if (categoryProvider.isLoading) {
                    return const SizedBox(
                      height: 42,
                      child: Center(
                        child:
                        CircularProgressIndicator(),
                      ),
                    );
                  }

                  // En cas d'erreur ou si aucune catégorie
                  // n'a été récupérée.
                  if (categoryProvider.error != null ||
                      categoryProvider.categories.isEmpty) {
                    return const SizedBox(
                      height: 42,
                      child: Center(
                        child: Text(
                          'Impossible de charger les catégories.',
                        ),
                      ),
                    );
                  }

                  // Affichage des catégories reçues
                  // depuis TheMealDB.
                  return SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection:
                      Axis.horizontal,
                      itemCount:
                      categoryProvider.categories.length,
                      itemBuilder: (
                          context,
                          index,
                          ) {
                        final category =
                        categoryProvider
                            .categories[index];

                        return _CategoryChip(
                          label:
                          category.strCategory,
                          icon:
                          Icons.restaurant,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------
              // RECETTES DU MOMENT
              // ----------------------------------------------------
              Consumer<MealProvider>(
                builder: (
                    context,
                    mealProvider,
                    child,
                    ) {
                  // ------------------------------------------------
                  // CHARGEMENT
                  // ------------------------------------------------
                  if (mealProvider.isLoading) {
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const AppSectionTitle(
                          title: 'Recettes du moment',
                          showScrollHint: true,
                        ),

                        const SizedBox(height: 8),

                        /*
                        Text(
                          'Recettes reçues : '
                              '${mealProvider.randomMeals.length}',
                          style:
                          const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),

                         */

                        const SizedBox(height: 14),

                        const SizedBox(
                          height: 210,
                          child: Center(
                            child:
                            CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    );
                  }

                  // ------------------------------------------------
                  // ERREUR OU AUCUNE RECETTE
                  // ------------------------------------------------
                  if (mealProvider.error != null ||
                      mealProvider.randomMeals.isEmpty) {
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const AppSectionTitle(
                          title: 'Recettes du moment',
                          showScrollHint: true,
                        ),

                        const SizedBox(height: 14),

                        const SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              'Impossible de charger les recettes.',
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // ------------------------------------------------
                  // RECETTES RÉCUPÉRÉES DEPUIS THEMEALDB
                  // ------------------------------------------------
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(
                        title: 'Recettes du moment',
                        showScrollHint: true,
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection:
                          Axis.horizontal,
                          itemCount:
                          mealProvider
                              .randomMeals
                              .length,
                          itemBuilder: (
                              context,
                              index,
                              ) {
                            final meal =
                            mealProvider
                                .randomMeals[index];

                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                right: 14,
                              ),
                              child: RecipeCard(
                                meal: meal,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                          RecipeDetailPage(
                                            meal: meal,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ------------------------------------------------------------
      // NAVIGATION PRINCIPALE
      // ------------------------------------------------------------
      bottomNavigationBar:
      AppBottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FavoritesPage(),
              ),
            );

            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),

    );
  }
}

/// Widget réutilisable permettant d'afficher
/// une catégorie de recettes sous forme de bouton.
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryChip({
    required this.label,
    required this.icon,
  });

  /// Ouvre l'écran de recherche avec la catégorie sélectionnée.
  ///
  /// La catégorie est transmise à [SearchPage], qui pourra ensuite
  /// demander au MealProvider de récupérer les recettes correspondantes.
  void _openCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchPage(
          category: label,
        ),
      ),
    );
  }

  /// Construit le bouton représentant la catégorie.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _openCategory(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/*
/// Petit widget réutilisable pour afficher une catégorie.
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        right: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
*/