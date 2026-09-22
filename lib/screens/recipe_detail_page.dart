import 'package:flutter/material.dart';

import 'package:recettescarnet/core/theme/app_colors.dart';
import 'package:recettescarnet/models/meal.dart';

import '../providers/user_session.dart';
import 'package:recettescarnet/models/favorite_recipe.dart';
import 'package:provider/provider.dart';
import 'package:recettescarnet/providers/favorite_provider.dart';

/// Écran affichant le détail d'une recette.
///
/// La recette est reçue depuis l'écran précédent
/// sous la forme d'un objet [Meal].
///
/// Exemple :
///
/// RecipeDetailPage(
///   meal: meal,
/// )

class RecipeDetailPage extends StatefulWidget {
  /// Recette à afficher.
  final Meal meal;

  const RecipeDetailPage({
    super.key,
    required this.meal,
  });

  @override
  State<RecipeDetailPage> createState() =>
      _RecipeDetailPageState();
}

/// État du favori pour la recette actuellement affichée.
enum FavoriteStatus {
  /// Nous sommes en train de vérifier SQLite.
  checking,

  /// La recette n'est pas dans les favoris.
  notFavorite,

  /// La recette est dans les favoris.
  favorite,
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {

  // Indique l'état actuel de la recette dans les favoris.
  FavoriteStatus _favoriteStatus = FavoriteStatus.checking;

  /// Initialise l'état de l'écran.
  ///
  /// Cette méthode est appelée une seule fois lorsque le State
  /// est créé. Elle lance la vérification permettant de savoir
  /// si la recette est déjà enregistrée dans les favoris.
  @override
  void initState() {
    super.initState();

    _checkFavoriteStatus();
  }

  /// Vérifie si la recette actuelle est déjà présente
  /// dans les favoris de l'utilisateur connecté.
  ///
  /// La méthode interroge le FavoriteProvider afin de savoir
  /// si la recette est déjà enregistrée dans SQLite.
  Future<void> _checkFavoriteStatus() async {
    // Le statut reste "checking" pendant la vérification.
    _favoriteStatus = FavoriteStatus.checking;

    final userId = UserSession.instance.userId;

    // Aucun utilisateur connecté : la recette ne peut pas
    // être associée aux favoris d'un utilisateur.
    if (userId == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _favoriteStatus = FavoriteStatus.notFavorite;
      });

      return;
    }

    /*
    final isFavorite = await DatabaseService.instance.isFavorite(
      userId,
      widget.meal.idMeal,
    );

     */
    final isFavorite =
    await context.read<FavoriteProvider>().isFavorite(
      userId,
      widget.meal.idMeal,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteStatus = isFavorite
          ? FavoriteStatus.favorite
          : FavoriteStatus.notFavorite;
    });
  }


  /// Ajoute ou retire la recette actuelle des favoris.
  ///
  /// Si la recette est déjà un favori, elle est supprimée
  /// via le FavoriteProvider. Sinon, elle est enregistrée
  /// comme favori via le même provider.
  Future<void> _toggleFavorite() async {
    final userId = UserSession.instance.userId;

    if (userId == null) {
      return;
    }

    final favoriteProvider =
    context.read<FavoriteProvider>();

    if (_favoriteStatus == FavoriteStatus.favorite) {
      await favoriteProvider.removeFavorite(
        userId,
        widget.meal.idMeal,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _favoriteStatus = FavoriteStatus.notFavorite;
      });

      return;
    }

    final favorite = FavoriteRecipe(
      userId: userId,
      mealId: widget.meal.idMeal,
      title: widget.meal.strMeal,
      category: widget.meal.strCategory,
      area: widget.meal.strArea,
      thumbnail: widget.meal.strMealThumb,
      ingredients: widget.meal.ingredients,
      instructions: widget.meal.strInstructions,
      createdAt: DateTime.now(),
    );

    await favoriteProvider.addFavorite(
      favorite,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteStatus = FavoriteStatus.favorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // --------------------------------------------------------------
      // BARRE SUPÉRIEURE
      // --------------------------------------------------------------
      
      appBar: AppBar(
        title: const Text(
          'Détail de la recette',
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        // ----------------------------------------------------------
        // BOUTON FAVORI
        // ----------------------------------------------------------

        actions: [
          IconButton(
            icon: Icon(
              _favoriteStatus == FavoriteStatus.favorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _favoriteStatus == FavoriteStatus.favorite
                  ? AppColors.favorite
                  : AppColors.navy,
            ),
            tooltip: _favoriteStatus == FavoriteStatus.favorite
                ? 'Retirer des favoris'
                : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
          ),
        ],
      ),


      // --------------------------------------------------------------
      // CONTENU
      // --------------------------------------------------------------

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------
            // IMAGE DE LA RECETTE
            // ----------------------------------------------------------

            if (widget.meal.strMealThumb != null &&
                widget.meal.strMealThumb!.isNotEmpty)
              Image.network(
                widget.meal.strMealThumb!,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,

                // Image de remplacement si l'image ne peut
                // pas être chargée.
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _buildImagePlaceholder();
                },
              )
            else
              _buildImagePlaceholder(),

            // ----------------------------------------------------------
            // INFORMATIONS DE LA RECETTE
            // ----------------------------------------------------------

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------------------
                  // NOM
                  // ----------------------------------------------------

                  Text(
                    widget.meal.strMeal,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ----------------------------------------------------
                  // CATÉGORIE
                  // ----------------------------------------------------

                  if (widget.meal.strCategory != null &&
                      widget.meal.strCategory!.isNotEmpty)
                    Text(
                      widget.meal.strCategory!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                // ----------------------------------------------------
                // INGRÉDIENTS
                // ----------------------------------------------------

                const SizedBox(height: 28),

                Text(
                  'Ingrédients',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (widget.meal.ingredients.isEmpty)
                  Text(
                    'Aucun ingrédient disponible.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                else
                  Column(
                    children: widget.meal.ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: AppColors.primary,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                ingredient.measure != null &&
                                    ingredient.measure!.isNotEmpty
                                    ? '${ingredient.measure} ${ingredient.name}'
                                    : ingredient.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // ----------------------------------------------------
                  // PRÉPARATION
                  // ----------------------------------------------------

                  const SizedBox(height: 32),

                  Text(
                    'Préparation',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.meal.strInstructions != null &&
                        widget.meal.strInstructions!.isNotEmpty
                        ? widget.meal.strInstructions!
                        : 'Aucune instruction disponible.',
                    textAlign: TextAlign.justify,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Affichage utilisé lorsque l'image de la recette
  /// n'est pas disponible.
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 320,
      color: AppColors.lightGray,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 64,
        color: AppColors.gray,
      ),
    );
  }
}