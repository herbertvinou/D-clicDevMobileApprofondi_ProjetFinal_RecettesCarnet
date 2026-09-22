import 'package:flutter/foundation.dart';

import 'package:recettescarnet/models/favorite_recipe.dart';
import 'package:recettescarnet/services/database_service.dart';
import 'package:recettescarnet/services/favorite_repository.dart';

/// Provider responsable de la gestion de l'état
/// des recettes favorites.
///
/// Architecture :
///
///     Interface Flutter
///            ↓
///     FavoriteProvider
///            ↓
///     FavoriteRepository
///            ↓
///     DatabaseService
///            ↓
///          SQLite
///
/// Le Provider ne dépend donc plus directement
/// de DatabaseService.
///
/// Cette séparation est importante pour les tests :
///
///     Test
///       ↓
///     FavoriteProvider
///       ↓
///     FakeFavoriteRepository
///
/// Nous pourrons ainsi tester le Provider sans utiliser
/// une véritable base SQLite.
class FavoriteProvider extends ChangeNotifier {
  // ----------------------------------------------------------
  // DÉPENDANCE
  // ----------------------------------------------------------

  /// Repository utilisé par le Provider.
  ///
  /// Nous utilisons l'abstraction FavoriteRepository
  /// plutôt que directement DatabaseService.
  final FavoriteRepository _repository;

  // ----------------------------------------------------------
  // CONSTRUCTEUR
  // ----------------------------------------------------------

  /// Crée un FavoriteProvider.
  ///
  /// Le repository est injectable.
  ///
  /// Dans l'application réelle, si aucun repository
  /// n'est fourni, nous utilisons DatabaseService.instance.
  ///
  /// Dans un test, nous pourrons fournir un faux repository :
  ///
  ///     FavoriteProvider(
  ///       repository: FakeFavoriteRepository(),
  ///     );
  ///
  FavoriteProvider({
    FavoriteRepository? repository,
  }) : _repository =
      repository ?? DatabaseService.instance;

  // ----------------------------------------------------------
  // ÉTAT DU PROVIDER
  // ----------------------------------------------------------

  /// Liste des recettes favorites actuellement chargées.
  List<FavoriteRecipe> _favorites = [];

  /// Indique si une opération de chargement
  /// est actuellement en cours.
  bool _isLoading = false;

  // ----------------------------------------------------------
  // GETTERS
  // ----------------------------------------------------------

  /// Permet à l'interface de consulter les favoris.
  ///
  /// List.unmodifiable() empêche l'interface de modifier
  /// directement la liste interne du Provider.
  List<FavoriteRecipe> get favorites =>
      List.unmodifiable(_favorites);

  /// Indique si le Provider est actuellement
  /// en train de charger les favoris.
  bool get isLoading => _isLoading;

  // ----------------------------------------------------------
  // CHARGEMENT
  // ----------------------------------------------------------

  /// Charge les favoris d'un utilisateur.
  ///
  /// Le Provider demande les données au repository.
  ///
  /// Il ne sait pas si les données viennent :
  /// - de SQLite ;
  /// - d'une autre source ;
  /// - ou d'un faux repository utilisé pendant un test.
  Future<void> loadFavorites(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites =
      await _repository.getFavoritesByUser(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // AJOUT
  // ----------------------------------------------------------

  /// Ajoute une recette aux favoris.
  ///
  /// L'enregistrement est d'abord effectué
  /// par le repository.
  ///
  /// Ensuite, la liste locale du Provider est mise à jour
  /// afin que l'interface puisse être rafraîchie.
  Future<void> addFavorite(
      FavoriteRecipe favorite,
      ) async {
    await _repository.insertFavorite(favorite);

    _favorites.add(favorite);

    notifyListeners();
  }


  // ----------------------------------------------------------
  // VÉRIFICATION
  // ----------------------------------------------------------

  /// Vérifie si une recette appartient aux favoris
  /// d'un utilisateur.
  ///
  /// Le Provider délègue cette vérification au repository.
  ///
  /// Cette méthode sera notamment utile à l'interface
  /// pour savoir quel état afficher sur le bouton favori :
  ///
  ///     ♡  Ajouter aux favoris
  ///
  /// ou :
  ///
  ///     ♥  Retirer des favoris
  Future<bool> isFavorite(
      int userId,
      String mealId,
      ) async {
    return await _repository.isFavorite(
      userId,
      mealId,
    );
  }



  // ----------------------------------------------------------
  // SUPPRESSION
  // ----------------------------------------------------------

  /// Supprime une recette des favoris.
  ///
  /// Le repository effectue d'abord la suppression
  /// dans la source de données.
  ///
  /// Si une ligne a réellement été supprimée,
  /// nous supprimons également la recette de la liste
  /// conservée en mémoire par le Provider.
  Future<void> removeFavorite(
      int userId,
      String mealId,
      ) async {
    final deletedRows =
    await _repository.deleteFavorite(
      userId,
      mealId,
    );

    if (deletedRows > 0) {
      _favorites.removeWhere(
            (favorite) =>
        favorite.userId == userId &&
            favorite.mealId == mealId,
      );

      notifyListeners();
    }
  }
}