import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recettescarnet/core/theme/app_colors.dart';
import 'package:recettescarnet/providers/favorite_provider.dart';
import 'package:recettescarnet/providers/user_session.dart';
import 'package:recettescarnet/models/meal.dart';
import 'package:recettescarnet/screens/recipe_detail_page.dart';

import '../models/favorite_recipe.dart';

/// Écran affichant les recettes enregistrées dans les favoris.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

/// État de l'écran des recettes favorites.
class _FavoritesPageState extends State<FavoritesPage> {

  /// Initialise l'écran et lance le chargement
  /// des recettes favorites de l'utilisateur connecté.
  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  /// Récupère les recettes favorites de l'utilisateur connecté.
  Future<void> _loadFavorites() async {
    final userId = UserSession.instance.userId;

    if (userId == null) {
      return;
    }

    await context.read<FavoriteProvider>().loadFavorites(userId);
  }

  /// Transforme une recette favorite enregistrée dans SQLite
  /// en objet Meal utilisable par l'écran de détail.
  ///
  /// Les informations nécessaires au détail sont déjà stockées
  /// localement dans la table favorite_recipes.
  Meal _favoriteToMeal(FavoriteRecipe favorite) {
    return Meal(
      idMeal: favorite.mealId,
      strMeal: favorite.title,
      strCategory: favorite.category,
      strArea: favorite.area,
      strMealThumb: favorite.thumbnail,
      strInstructions: favorite.instructions,
      ingredients: favorite.ingredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        title: const Text(
          'Mes favoris',
        ),
      ),

      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {

          // Affiche un indicateur pendant le chargement
          // des favoris depuis SQLite.
          if (favoriteProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Affiche un message lorsque l'utilisateur
          // n'a encore enregistré aucune recette.
          if (favoriteProvider.favorites.isEmpty) {
            return const Center(
              child: Text(
                'Aucune recette favorite.',
              ),
            );
          }

          // Affiche la liste des recettes favorites.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProvider.favorites.length,
            itemBuilder: (context, index) {
              final favorite =
              favoriteProvider.favorites[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),

                // Ouvre le détail de la recette sélectionnée.
                onTap: () {
                  final meal = _favoriteToMeal(favorite);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailPage(
                        meal: meal,
                      ),
                    ),
                  );
                },

                child: Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // ----------------------------------------------------------
                        // IMAGE DE LA RECETTE
                        // ----------------------------------------------------------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: favorite.thumbnail != null &&
                              favorite.thumbnail!.isNotEmpty
                              ? Image.network(
                            favorite.thumbnail!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 90,
                            height: 90,
                            color: AppColors.lightGray,
                            child: const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ----------------------------------------------------------
                        // INFORMATIONS DE LA RECETTE
                        // ----------------------------------------------------------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favorite.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: AppColors.deepNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                favorite.category ?? 'Catégorie inconnue',
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

                        // ----------------------------------------------------------
                        // ICÔNE FAVORI
                        // ----------------------------------------------------------
                        const Icon(
                          Icons.favorite,
                          color: AppColors.favorite,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );

            },
          );
        },
      ),

    );
  }
}