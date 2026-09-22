import 'package:flutter/foundation.dart' hide Category;

import 'package:recettescarnet/models/category.dart';
import 'package:recettescarnet/services/meal_api_service.dart';

/// Provider responsable de la récupération et de l'état
/// des catégories provenant de TheMealDB.
///
/// Il joue le rôle d'intermédiaire entre :
///
/// HomePage
///    ↓
/// CategoryProvider
///    ↓
/// MealApiService
///    ↓
/// TheMealDB
class CategoryProvider extends ChangeNotifier {
  /// Service responsable des appels vers TheMealDB.
  final MealApiService _mealApiService;

  /// Liste des catégories récupérées depuis l'API.
  List<Category> _categories = [];

  /// Indique si une récupération est actuellement en cours.
  bool _isLoading = false;

  /// Contient le message d'erreur éventuel.
  String? _error;

  /// Constructeur du Provider.
  ///
  /// Le service peut être injecté, ce qui facilitera
  /// les tests unitaires plus tard.
  CategoryProvider({
    MealApiService? mealApiService,
  }) : _mealApiService =
      mealApiService ?? MealApiService();

  /// Liste des catégories accessibles à l'interface.
  ///
  /// Nous retournons une liste non modifiable afin que
  /// l'interface ne puisse pas modifier directement
  /// l'état interne du Provider.
  List<Category> get categories =>
      List.unmodifiable(_categories);

  /// Indique si les catégories sont en cours de chargement.
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel.
  String? get error => _error;

  /// Récupère les catégories depuis TheMealDB.
  Future<void> loadCategories() async {
    // Passage à l'état "chargement".
    _isLoading = true;

    // On efface une éventuelle ancienne erreur.
    _error = null;

    // Informe les widgets qui écoutent le Provider
    // qu'un changement d'état vient d'avoir lieu.
    notifyListeners();

    try {
      // Appel de notre service API.
      _categories =
      await _mealApiService.getCategories();
    } catch (e) {
      // En cas d'erreur réseau ou API,
      // nous conservons une liste vide.
      _categories = [];

      // Message destiné à l'interface.
      _error =
      'Impossible de récupérer les catégories.';
    } finally {
      // Fin du chargement, qu'il soit réussi ou non.
      _isLoading = false;

      // Informe à nouveau l'interface.
      notifyListeners();
    }
  }
}