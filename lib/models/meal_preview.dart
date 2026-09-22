/// Représente un aperçu d'une recette provenant
/// des endpoints de filtrage de TheMealDB.
///
/// Les endpoints comme :
///
/// filter.php?c=Seafood
/// filter.php?a=Canadian
/// filter.php?i=chicken_breast
///
/// retournent principalement les informations nécessaires
/// pour identifier et afficher une recette dans une liste.
///
/// Exemple de données reçues :
///
/// {
///   "strMeal": "Baked salmon with fennel & tomatoes",
///   "strMealThumb": "https://...",
///   "idMeal": "52959"
/// }
class MealPreview {
  /// Identifiant unique de la recette dans TheMealDB.
  final String idMeal;

  /// Nom de la recette.
  final String strMeal;

  /// URL de l'image de la recette.
  final String? strMealThumb;

  /// Constructeur du modèle [MealPreview].
  const MealPreview({
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
  });

  /// Construit un objet [MealPreview] à partir
  /// des données JSON retournées par TheMealDB.
  factory MealPreview.fromJson(Map<String, dynamic> json) {
    return MealPreview(
      idMeal: json['idMeal']?.toString() ?? '',
      strMeal: json['strMeal']?.toString() ?? '',
      strMealThumb: json['strMealThumb']?.toString(),
    );
  }
}