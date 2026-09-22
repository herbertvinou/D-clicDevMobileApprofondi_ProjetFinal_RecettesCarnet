import 'package:recettescarnet/models/favorite_recipe.dart';

/// Contrat utilisé par FavoriteProvider pour accéder
/// aux recettes favorites.
///
/// Cette abstraction permet de séparer :
///
///     FavoriteProvider
///            ↓
///     FavoriteRepository
///            ↓
///     DatabaseService
///            ↓
///          SQLite
///
/// L'intérêt principal est que FavoriteProvider ne connaît
/// plus directement SQLite.
///
/// En production, DatabaseService implémentera ce contrat.
///
/// Dans les tests, nous pourrons créer une fausse implémentation
/// qui fonctionne uniquement en mémoire.
abstract class FavoriteRepository {
  // ----------------------------------------------------------
  // INSERTION
  // ----------------------------------------------------------

  /// Enregistre une recette favorite.
  Future<int> insertFavorite(
      FavoriteRecipe favorite,
      );

  // ----------------------------------------------------------
  // LECTURE
  // ----------------------------------------------------------

  /// Récupère toutes les recettes favorites
  /// appartenant à un utilisateur.
  Future<List<FavoriteRecipe>> getFavoritesByUser(
      int userId,
      );

  // ----------------------------------------------------------
  // VÉRIFICATION
  // ----------------------------------------------------------

  /// Vérifie si une recette est déjà enregistrée
  /// dans les favoris d'un utilisateur.
  Future<bool> isFavorite(
      int userId,
      String mealId,
      );

  // ----------------------------------------------------------
  // SUPPRESSION
  // ----------------------------------------------------------

  /// Supprime une recette favorite.
  ///
  /// La méthode retourne le nombre de lignes supprimées.
  Future<int> deleteFavorite(
      int userId,
      String mealId,
      );
}