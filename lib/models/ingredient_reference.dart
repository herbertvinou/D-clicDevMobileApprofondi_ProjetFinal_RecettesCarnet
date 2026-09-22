/// Représente une fiche de référence d'un ingrédient
/// provenant de TheMealDB.
///
/// IMPORTANT :
///
/// Cette classe ne représente PAS un ingrédient utilisé
/// dans une recette.
///
/// Elle représente une fiche du catalogue des ingrédients
/// proposé par TheMealDB.
///
/// Exemple :
///
/// {
///   "idIngredient": "1",
///   "strIngredient": "Chicken",
///   "strDescription": "...",
///   "strThumb":
///       "https://www.themealdb.com/images/ingredients/chicken.png",
///   "strType": null
/// }
class IngredientReference {
  /// Identifiant de l'ingrédient dans TheMealDB.
  final String idIngredient;

  /// Nom de l'ingrédient.
  final String strIngredient;

  /// Description générale de l'ingrédient.
  ///
  /// Cette valeur peut être absente dans la réponse de l'API.
  final String? strDescription;

  /// URL de l'image de l'ingrédient.
  ///
  /// Cette valeur peut être absente dans la réponse de l'API.
  final String? strThumb;

  /// Type de l'ingrédient.
  ///
  /// Cette valeur peut être absente dans la réponse de l'API.
  final String? strType;

  /// Constructeur du modèle.
  const IngredientReference({
    required this.idIngredient,
    required this.strIngredient,
    this.strDescription,
    this.strThumb,
    this.strType,
  });

  /// Construit un objet IngredientReference à partir
  /// des données JSON retournées par TheMealDB.
  ///
  /// Exemple :
  ///
  /// final ingredient = IngredientReference.fromJson(json);
  factory IngredientReference.fromJson(
      Map<String, dynamic> json,
      ) {
    return IngredientReference(
      idIngredient: json['idIngredient']?.toString() ?? '',
      strIngredient: json['strIngredient']?.toString() ?? '',
      strDescription: json['strDescription']?.toString(),
      strThumb: json['strThumb']?.toString(),
      strType: json['strType']?.toString(),
    );
  }
}