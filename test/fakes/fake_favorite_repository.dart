import 'package:recettescarnet/models/favorite_recipe.dart';
import 'package:recettescarnet/services/favorite_repository.dart';

/// Fausse implémentation de FavoriteRepository.
///
/// Cette classe est utilisée uniquement pendant les tests.
///
/// Contrairement à DatabaseService, elle n'utilise pas SQLite.
/// Les favoris sont simplement conservés dans une liste en mémoire.
///
/// Cela permet de tester FavoriteProvider rapidement et
/// indépendamment de la base de données réelle.
class FakeFavoriteRepository implements FavoriteRepository {
  // ----------------------------------------------------------
  // DONNÉES EN MÉMOIRE
  // ----------------------------------------------------------

  /// Liste qui joue le rôle de notre petite base de données
  /// pendant les tests.
  final List<FavoriteRecipe> _favorites = [];

  // ----------------------------------------------------------
  // INSERTION
  // ----------------------------------------------------------

  @override
  Future<int> insertFavorite(
      FavoriteRecipe favorite,
      ) async {
    _favorites.add(favorite);

    // Nous retournons une valeur fictive représentant
    // l'identifiant SQLite de la ligne créée.
    return _favorites.length;
  }

  // ----------------------------------------------------------
  // LECTURE
  // ----------------------------------------------------------

  @override
  Future<List<FavoriteRecipe>> getFavoritesByUser(
      int userId,
      ) async {
    return _favorites
        .where(
          (favorite) =>
      favorite.userId == userId,
    )
        .toList();
  }

  // ----------------------------------------------------------
  // VÉRIFICATION
  // ----------------------------------------------------------

  @override
  Future<bool> isFavorite(
      int userId,
      String mealId,
      ) async {
    return _favorites.any(
          (favorite) =>
      favorite.userId == userId &&
          favorite.mealId == mealId,
    );
  }

  // ----------------------------------------------------------
  // SUPPRESSION
  // ----------------------------------------------------------

  @override
  Future<int> deleteFavorite(
      int userId,
      String mealId,
      ) async {
    final initialLength = _favorites.length;

    _favorites.removeWhere(
          (favorite) =>
      favorite.userId == userId &&
          favorite.mealId == mealId,
    );

    return initialLength - _favorites.length;
  }
}