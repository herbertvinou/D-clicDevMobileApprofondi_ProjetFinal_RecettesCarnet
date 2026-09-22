/// Représente une catégorie de recettes provenant de TheMealDB.
///
/// TheMealDB fournit notamment les informations suivantes
/// pour chaque catégorie :
///
/// - idCategory
/// - strCategory
/// - strCategoryThumb
/// - strCategoryDescription
///
/// Exemple de données reçues depuis l'API :
///
/// {
///   "idCategory": "1",
///   "strCategory": "Beef",
///   "strCategoryThumb": "https://...",
///   "strCategoryDescription": "Beef is..."
/// }
class Category {
  /// Identifiant unique de la catégorie dans TheMealDB.
  final String idCategory;

  /// Nom de la catégorie.
  ///
  /// Exemple : "Beef", "Chicken", "Dessert", etc.
  final String strCategory;

  /// URL de l'image représentant la catégorie.
  final String? strCategoryThumb;

  /// Description de la catégorie.
  final String? strCategoryDescription;

  /// Constructeur du modèle [Category].
  const Category({
    required this.idCategory,
    required this.strCategory,
    this.strCategoryThumb,
    this.strCategoryDescription,
  });

  /// Construit un objet [Category] à partir d'un objet JSON.
  ///
  /// Cette méthode sera utilisée plus tard par
  /// [MealApiService] lorsque nous appellerons :
  ///
  /// categories.php
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategory: json['idCategory']?.toString() ?? '',
      strCategory: json['strCategory']?.toString() ?? '',
      strCategoryThumb: json['strCategoryThumb']?.toString(),
      strCategoryDescription:
      json['strCategoryDescription']?.toString(),
    );
  }
}