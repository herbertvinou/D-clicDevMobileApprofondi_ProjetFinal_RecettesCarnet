import 'package:flutter/material.dart';

import 'package:recettescarnet/core/theme/app_colors.dart';
import 'package:recettescarnet/models/meal.dart';

/// Carte réutilisable permettant d'afficher une recette.
///
/// Cette carte pourra être utilisée sur plusieurs écrans :
///
/// - Accueil ;
/// - Recherche ;
/// - Mes recettes ;
/// - Favoris.
///
/// Le widget reçoit un objet [Meal] provenant du modèle
/// de l'application.
///
/// Il ne récupère donc pas lui-même les données depuis Internet.
/// La responsabilité de récupérer les données appartient
/// aux services et aux providers.
class RecipeCard extends StatelessWidget {
  /// Recette affichée dans la carte.
  final Meal meal;

  /// Fonction appelée lorsque l'utilisateur sélectionne
  /// la recette.
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 280,

      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // IMAGE DE LA RECETTE
              // ----------------------------------------------------

              SizedBox(
                height: 135,
                width: double.infinity,

                // ------------------------------------------------------------
                // IMAGE DE LA RECETTE
                // ------------------------------------------------------------
                //
                // strMealThumb est nullable (String?).
                //
                // Nous vérifions donc d'abord si TheMealDB nous fournit
                // réellement une URL d'image.
                child: meal.strMealThumb != null &&
                    meal.strMealThumb!.isNotEmpty
                    ? Image.network(
                  meal.strMealThumb!,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  // ------------------------------------------------------
                  // IMAGE DE REMPLACEMENT EN CAS D'ERREUR
                  // ------------------------------------------------------
                  //
                  // Même avec une URL présente, l'image peut ne pas
                  // être accessible.
                  //
                  // Nous affichons donc une interface de secours.
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return _buildImagePlaceholder();
                  },
                )
                    : _buildImagePlaceholder(),
              ),


              // ----------------------------------------------------
              // INFORMATIONS DE LA RECETTE
              // ----------------------------------------------------

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // NOM DE LA RECETTE
                      // ------------------------------------------------

                      SizedBox(
                        height: 52,
                        child: Text(
                          meal.strMeal,
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
                      ),

                      const SizedBox(height: 6),

                      // ------------------------------------------------
                      // CATÉGORIE + PAYS
                      // ------------------------------------------------

                      Row(
                        children: [
                          if (meal.strCategory != null &&
                              meal.strCategory!.isNotEmpty)
                            Flexible(
                              child: Text(
                                meal.strCategory!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: AppColors.gray,
                                ),
                              ),
                            ),

                          if (meal.strCategory != null &&
                              meal.strCategory!.isNotEmpty &&
                              meal.strArea != null &&
                              meal.strArea!.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors.lightBlue,
                                ),
                              ),
                            ),

                          if (meal.strArea != null &&
                              meal.strArea!.isNotEmpty)
                            Flexible(
                              child: Text(
                                meal.strArea!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: AppColors.gray,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'affichage de remplacement lorsque
  /// l'image de la recette n'est pas disponible.
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.lightGray,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppColors.gray,
      ),
    );
  }

}