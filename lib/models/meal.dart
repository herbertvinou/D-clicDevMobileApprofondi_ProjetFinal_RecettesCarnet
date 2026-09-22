import 'package:recettescarnet/models/ingredient.dart';

/// Représente une recette provenant de TheMealDB.
///
/// Cette classe transforme les données reçues depuis l'API
/// en un objet Dart facilement utilisable dans l'application.
///
/// Exemple de données provenant de TheMealDB :
///
/// {
///   "idMeal": "52772",
///   "strMeal": "Teriyaki Chicken Casserole",
///   "strCategory": "Chicken",
///   "strArea": "Japanese",
///   "strInstructions": "...",
///   "strMealThumb": "https://..."
/// }
class Meal {
  /// Identifiant unique de la recette dans TheMealDB.
  ///
  /// Exemple :
  /// "52772"
  final String idMeal;

  /// Nom de la recette.
  ///
  /// Exemple :
  /// "Teriyaki Chicken Casserole"
  final String strMeal;

  /// Catégorie de la recette.
  ///
  /// Exemple :
  /// "Chicken"
  final String? strCategory;

  /// Origine géographique de la recette.
  ///
  /// Exemple :
  /// "Japanese"
  final String? strArea;

  /// URL de l'image de la recette.
  ///
  /// Exemple :
  /// https://www.themealdb.com/images/media/meals/...
  final String? strMealThumb;

  /// Instructions de préparation de la recette.
  final String? strInstructions;

  /// Liste des ingrédients utilisés dans la recette.
  ///
  /// TheMealDB fournit séparément le nom de l'ingrédient
  /// et sa quantité.
  ///
  /// Nous les regroupons dans des objets Ingredient.
  final List<Ingredient> ingredients;

  /// Constructeur du modèle Meal.
  const Meal({
    required this.idMeal,
    required this.strMeal,
    this.strCategory,
    this.strArea,
    this.strMealThumb,
    this.strInstructions,
    this.ingredients = const [],
  });

  /// Construit un objet Meal à partir des données JSON
  /// reçues depuis TheMealDB.
  ///
  /// TheMealDB ne fournit pas les ingrédients sous forme
  /// de liste.
  ///
  /// Les données sont organisées ainsi :
  ///
  /// strIngredient1
  /// strMeasure1
  ///
  /// strIngredient2
  /// strMeasure2
  ///
  /// ...
  ///
  /// jusqu'à :
  ///
  /// strIngredient20
  /// strMeasure20
  ///
  /// Nous allons donc parcourir les 20 positions possibles
  /// et transformer chaque couple ingrédient + mesure
  /// en objet Ingredient.
  factory Meal.fromJson(Map<String, dynamic> json) {
    // Cette liste contiendra les ingrédients reconstruits
    // à partir des champs envoyés par TheMealDB.
    final ingredients = <Ingredient>[];

    // TheMealDB prévoit 20 emplacements maximum
    // pour les ingrédients d'une recette.
    for (int i = 1; i <= 20; i++) {
      // Exemple :
      //
      // i = 1  → strIngredient1
      // i = 2  → strIngredient2
      // i = 3  → strIngredient3
      //
      // Le nom du champ est donc construit dynamiquement.
      final ingredient = json['strIngredient$i']?.toString().trim();

      // Même principe pour la quantité / mesure.
      //
      // Exemple :
      //
      // i = 1  → strMeasure1
      // i = 2  → strMeasure2
      final measure = json['strMeasure$i']?.toString().trim();

      // Certaines recettes n'utilisent pas les 20 emplacements.
      //
      // Nous ajoutons uniquement un ingrédient lorsque
      // le nom existe réellement et n'est pas vide.
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(
          Ingredient(
            name: ingredient,

            // Si aucune mesure n'est fournie,
            // nous conservons null plutôt qu'une chaîne vide.
            measure: (measure == null || measure.isEmpty)
                ? null
                : measure,
          ),
        );
      }
    }

    // Une fois les données générales et les ingrédients
    // récupérés, nous construisons notre objet Meal.
    return Meal(
      idMeal: json['idMeal']?.toString() ?? '',
      strMeal: json['strMeal']?.toString() ?? '',
      strCategory: json['strCategory']?.toString(),
      strArea: json['strArea']?.toString(),
      strMealThumb: json['strMealThumb']?.toString(),
      strInstructions: json['strInstructions']?.toString(),
      ingredients: ingredients,
    );
  }
}