import 'package:flutter/foundation.dart';

import 'package:recettescarnet/models/meal.dart';
import 'package:recettescarnet/services/meal_api_service.dart';
import 'package:recettescarnet/models/meal_preview.dart';

/// Provider responsable de la gestion des recettes.
///
/// Il fait le lien entre :
///
/// HomePage
///    ↓
/// MealProvider
///    ↓
/// MealApiService
///    ↓
/// TheMealDB
class MealProvider extends ChangeNotifier {
  /// Service responsable des appels vers TheMealDB.
  final MealApiService _mealApiService;

  /// Liste des recettes aléatoires affichées sur l'accueil.
  List<Meal> _randomMeals = [];

  /// Indique si les recettes sont en cours de chargement.
  bool _isLoading = false;

  /// Contient un éventuel message d'erreur.
  String? _error;

  /// Liste des recettes retournées par la recherche.
  List<Meal> _searchResults = [];

  /// Liste des recettes retournées lors d'une recherche
  /// effectuée à partir d'une catégorie.
  List<MealPreview> _categoryResults = [];

  /// Indique si une recherche est actuellement en cours.
  bool _isSearching = false;

  /// Contient le message d'erreur éventuel de la recherche.
  String? _searchError;

  /// Constructeur du Provider.
  ///
  /// L'injection du service facilitera les tests unitaires.
  MealProvider({
    MealApiService? mealApiService,
  }) : _mealApiService =
      mealApiService ?? MealApiService();

  /// Liste des recettes aléatoires.
  List<Meal> get randomMeals =>
      List.unmodifiable(_randomMeals);

  /// Retourne la liste des recettes trouvées
  /// pour la catégorie actuellement recherchée.
  List<MealPreview> get categoryResults =>
      List.unmodifiable(_categoryResults);

  /// Indique si le chargement est en cours.
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel.
  String? get error => _error;

  /// Retourne les résultats de la recherche.
  ///
  /// List.unmodifiable() empêche l'interface ou un autre
  /// composant de modifier directement la liste interne.
  List<Meal> get searchResults =>
      List.unmodifiable(_searchResults);

  /// Indique si une recherche est actuellement en cours.
  bool get isSearching => _isSearching;

  /// Retourne le message d'erreur éventuel de la recherche.
  String? get searchError => _searchError;

  /// Récupère plusieurs recettes aléatoires
  /// depuis TheMealDB.
  Future<void> loadRandomMeals({
    int count = 10,
  }) async {
    // ------------------------------------------------------------
    // DÉBUT DU CHARGEMENT
    // ------------------------------------------------------------

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      // ------------------------------------------------------------
      // RÉCUPÉRATION DES RECETTES
      // ------------------------------------------------------------
      //
      // Nous effectuons plusieurs appels à l'endpoint
      // random.php de TheMealDB.
      //
      // Chaque appel peut réussir ou échouer indépendamment.
      // Ainsi, si une recette ne peut pas être récupérée,
      // les autres recettes restent disponibles.
      final meals = <Meal>[];

      for (int i = 0; i < count; i++) {
        try {
          final meal =
          await _mealApiService.getRandomMeal();

          meals.add(meal);

          debugPrint(
            'Recette ${i + 1}/$count : ${meal.strMeal}',
          );
        } catch (e) {
          // Une erreur sur une recette ne doit pas
          // empêcher les autres appels de continuer.
          debugPrint(
            'Erreur lors de la recette ${i + 1}/$count : $e',
          );
        }
      }

      // ------------------------------------------------------------
      // MISE À JOUR DE LA LISTE
      // ------------------------------------------------------------

      _randomMeals = meals;

      // Si aucune recette n'a pu être récupérée,
      // nous conservons un message d'erreur.
      if (_randomMeals.isEmpty) {
        _error =
        'Impossible de récupérer les recettes.';
      }
    } catch (e, stackTrace) {
      _randomMeals = [];

      debugPrint(
        'ERREUR RANDOM MEALS : $e',
      );

      debugPrint(
        'STACK TRACE : $stackTrace',
      );

      _error =
      'Impossible de récupérer les recettes.';
    } finally {
      // ------------------------------------------------------------
      // FIN DU CHARGEMENT
      // ------------------------------------------------------------

      _isLoading = false;

      notifyListeners();
    }
  }


  /// Recherche des recettes à partir du texte saisi par l'utilisateur.
  ///
  /// Cette méthode appelle MealApiService.searchMeals()
  /// puis met à jour l'état du Provider afin que l'interface
  /// puisse afficher les résultats, le chargement ou une erreur.
  Future<void> searchMeals(String query) async {
    // Supprime les espaces inutiles placés
    // au début ou à la fin de la recherche.
    final normalizedQuery = query.trim();

    // Si l'utilisateur n'a rien saisi,
    // nous vidons les résultats précédents.
    if (normalizedQuery.isEmpty) {
      _searchResults = [];
      _searchError = null;
      _isSearching = false;

      notifyListeners();

      return;
    }

    // ------------------------------------------------------------
    // DÉBUT DE LA RECHERCHE
    // ------------------------------------------------------------

    _isSearching = true;
    _searchError = null;

    notifyListeners();

    try {
      // ----------------------------------------------------------
      // APPEL DU SERVICE
      // ----------------------------------------------------------
      //
      // Le Provider ne construit pas lui-même l'URL.
      //
      // Il délègue cette responsabilité à MealApiService.
      final meals =
      await _mealApiService.searchMeals(normalizedQuery);

      // ----------------------------------------------------------
      // MISE À JOUR DES RÉSULTATS
      // ----------------------------------------------------------

      _searchResults = meals;

      // Une liste vide signifie simplement que
      // TheMealDB n'a trouvé aucune recette.
      if (_searchResults.isEmpty) {
        _searchError = null;
      }
    } catch (e, stackTrace) {
      // ----------------------------------------------------------
      // GESTION DE L'ERREUR
      // ----------------------------------------------------------

      // En cas d'erreur, nous supprimons les anciens résultats
      // afin de ne pas afficher des résultats qui correspondent
      // à une ancienne recherche.
      _searchResults = [];

      debugPrint(
        'ERREUR RECHERCHE : $e',
      );

      debugPrint(
        'STACK TRACE : $stackTrace',
      );

      _searchError =
      'Impossible de rechercher les recettes.';
    } finally {
      // ----------------------------------------------------------
      // FIN DE LA RECHERCHE
      // ----------------------------------------------------------

      _isSearching = false;

      notifyListeners();
    }
  }


  /// Recherche les recettes appartenant à une catégorie donnée.
  ///
  /// Cette méthode appelle MealApiService.filterByCategory()
  /// puis met à jour les résultats de catégorie afin que
  /// l'interface puisse afficher les recettes correspondantes.
  Future<void> searchMealsByCategory(String category) async {
    final normalizedCategory = category.trim();

    /// Une catégorie vide ne peut pas produire
    /// une recherche valide.
    if (normalizedCategory.isEmpty) {
      _categoryResults = [];
      _searchError = null;
      _isSearching = false;
      notifyListeners();

      return;
    }

    /// Signale à l'interface que la recherche
    /// est actuellement en cours.
    _isSearching = true;
    _searchError = null;

    notifyListeners();

    try {
      /// Demande au service API les recettes
      /// appartenant à la catégorie sélectionnée.
      final meals = await _mealApiService.filterByCategory(
        normalizedCategory,
      );

      /// Enregistre les résultats retournés
      /// par TheMealDB.
      _categoryResults = meals;
    } catch (e, stackTrace) {
      /// En cas d'erreur, on vide les anciens résultats
      /// afin de ne pas afficher des données obsolètes.
      _categoryResults = [];

      debugPrint(
        'ERREUR RECHERCHE CATÉGORIE : $e',
      );

      debugPrint(
        'STACK TRACE : $stackTrace',
      );

      /// Message destiné à l'interface utilisateur.
      _searchError =
      'Impossible de charger les recettes de cette catégorie.';
    } finally {
      /// La recherche est terminée, qu'elle soit réussie
      /// ou qu'une erreur se soit produite.
      _isSearching = false;

      notifyListeners();
    }
  }

  /// Récupère une recette complète à partir de son identifiant.
  ///
  /// Cette méthode est utilisée lorsque l'utilisateur sélectionne
  /// une recette provenant d'une recherche par catégorie.
  ///
  /// La recherche par catégorie retourne uniquement un MealPreview.
  /// Nous utilisons donc son identifiant pour récupérer le Meal
  /// complet auprès de TheMealDB.
  ///
  /// La méthode peut retourner null si aucune recette
  /// ne correspond à l'identifiant demandé.
  Future<Meal?> getMealById(String mealId) async {
    return await _mealApiService.getMealById(mealId);
  }


}