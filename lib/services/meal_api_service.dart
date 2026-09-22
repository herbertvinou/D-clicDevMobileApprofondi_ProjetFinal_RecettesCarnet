import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:recettescarnet/models/meal.dart';
import 'package:recettescarnet/models/category.dart';
import 'package:recettescarnet/models/meal_preview.dart';
import 'package:recettescarnet/models/area.dart';
import 'package:recettescarnet/models/ingredient_reference.dart';

/// Service responsable de la communication avec l'API TheMealDB.
///
/// Pour l'instant, ce service contient une seule responsabilité :
/// rechercher des recettes à partir de leur nom.
///
/// Exemple :
///
/// searchMeals('Arrabiata')
///
/// permettra d'interroger :
///
/// https://www.themealdb.com/api/json/v1/1/search.php?s=Arrabiata
class MealApiService {
  /// Client HTTP utilisé pour communiquer avec TheMealDB.
  ///
  /// Nous l'injectons dans le service afin de pouvoir :
  ///
  /// - utiliser le vrai client HTTP dans l'application ;
  /// - utiliser un faux client HTTP pendant les tests.
  final http.Client _client;

  /// Constructeur du service.
  ///
  /// Si aucun client n'est fourni, on utilise automatiquement
  /// le client HTTP standard de la bibliothèque `http`.
  MealApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();
  /// URL de base de l'API TheMealDB.
  ///
  /// Nous la centralisons ici afin d'éviter de répéter
  /// l'URL complète dans chaque méthode du service.
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  /// Recherche des recettes par leur nom.
  ///
  /// Exemple :
  ///
  /// searchMeals('Arrabiata')
  ///
  /// retourne une liste de [Meal].
  Future<List<Meal>> searchMeals(String query) async {
    // Construction de l'URL avec le paramètre "s".
    //
    // Uri.encodeQueryComponent() permet de gérer correctement
    // les espaces et caractères spéciaux présents dans le nom
    // de la recette.
    final encodedQuery = Uri.encodeQueryComponent(query);

    final uri = Uri.parse(
      '$_baseUrl/search.php?s=$encodedQuery',
    );

    // Envoi de la requête HTTP GET vers TheMealDB.
        //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Le code HTTP 200 signifie que la requête
    // a été traitée correctement par le serveur.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des recettes '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // TheMealDB retourne les données au format JSON.
    //
    // jsonDecode() transforme le texte JSON en objets Dart
    // (Map, List, String, etc.).
    final Map<String, dynamic> data =
    jsonDecode(response.body);

    // Lorsque TheMealDB ne trouve aucune recette,
    // la propriété "meals" peut être null.
    //
    // Dans ce cas, nous retournons simplement une liste vide.
    final mealsJson = data['meals'];

    if (mealsJson == null) {
      return [];
    }

    // Conversion de chaque élément JSON en objet Meal.
    //
    // C'est ici que notre méthode Meal.fromJson()
    // créée précédemment est utilisée.
    return (mealsJson as List)
        .map(
          (json) => Meal.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Récupère une recette complète à partir de son identifiant TheMealDB.
  ///
  /// Exemple :
  ///
  /// getMealById('52772')
  ///
  /// interroge l'endpoint :
  ///
  /// lookup.php?i=52772
  ///
  /// La méthode retourne :
  ///
  /// - un objet Meal si la recette existe ;
  /// - null si aucune recette ne correspond à l'identifiant.
  Future<Meal?> getMealById(String mealId) async {
    // Construction de l'URL.
    //
    // Uri.encodeQueryComponent() permet de sécuriser
    // la valeur envoyée dans l'URL.
    final encodedMealId = Uri.encodeQueryComponent(mealId);

    final uri = Uri.parse(
      '$_baseUrl/lookup.php?i=$encodedMealId',
    );

    // Envoi de la requête HTTP GET.
    //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Vérification du code HTTP.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération de la recette '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Transformation du JSON reçu en objet Dart.
    final Map<String, dynamic> data =
    jsonDecode(response.body);

    // TheMealDB retourne une propriété "meals".
    //
    // Si l'identifiant n'existe pas, cette propriété
    // peut être null.
    final mealsJson = data['meals'];

    if (mealsJson == null || mealsJson is! List) {
      return null;
    }

    // L'endpoint lookup.php correspond à une recette précise.
    //
    // Nous vérifions néanmoins que la liste n'est pas vide
    // avant d'accéder au premier élément.
    if (mealsJson.isEmpty) {
      return null;
    }

    // Conversion du premier résultat JSON en objet Meal.
    return Meal.fromJson(
      mealsJson.first as Map<String, dynamic>,
    );
  }

  /// Récupère une recette aléatoire depuis TheMealDB.
  ///
  /// L'endpoint utilisé est :
  ///
  /// https://www.themealdb.com/api/json/v1/1/random.php
  ///
  /// TheMealDB retourne une seule recette.
  /// La méthode retourne donc directement un objet [Meal].
  Future<Meal> getRandomMeal() async {
    // Construction de l'URL de l'endpoint.
    final uri = Uri.parse(
      '$_baseUrl/random.php',
    );

    // Envoi de la requête HTTP GET.
    //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Vérification du code HTTP.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération de la recette aléatoire '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Conversion de la réponse JSON en structure Dart.
    final Map<String, dynamic> data =
    jsonDecode(response.body);

    // Récupération de la propriété "meals".
    final mealsJson = data['meals'];

    // Vérification de la structure retournée par l'API.
    if (mealsJson is! List || mealsJson.isEmpty) {
      throw Exception(
        'TheMealDB n\'a retourné aucune recette aléatoire.',
      );
    }

    // Conversion du premier résultat JSON
    // en objet Meal grâce à notre modèle.
    return Meal.fromJson(
      mealsJson.first as Map<String, dynamic>,
    );
  }

  /// Récupère la liste des catégories de recettes
  /// disponibles dans TheMealDB.
  ///
  /// L'endpoint utilisé est :
  ///
  /// categories.php
  ///
  /// La méthode retourne une liste d'objets [Category].
  Future<List<Category>> getCategories() async {
    // Construction de l'URL de l'endpoint.
    final uri = Uri.parse(
      '$_baseUrl/categories.php',
    );

    // Envoi de la requête HTTP GET vers TheMealDB.
    //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Vérification du code HTTP.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des catégories '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Transformation de la réponse JSON en structure Dart.
    final Map<String, dynamic> data =
    jsonDecode(response.body);

    // Récupération de la propriété "categories".
    final categoriesJson = data['categories'];

    // Si aucune catégorie n'est retournée,
    // nous renvoyons une liste vide.
    if (categoriesJson == null) {
      return [];
    }

    // Conversion de chaque élément JSON
    // en objet Category.
    return (categoriesJson as List)
        .map(
          (json) => Category.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Récupère les recettes appartenant à une catégorie donnée.
  ///
  /// Exemple :
  ///
  /// filterByCategory('Seafood')
  ///
  /// utilise l'endpoint :
  ///
  /// filter.php?c=Seafood
  ///
  /// L'endpoint de filtrage retourne des informations
  /// limitées sur chaque recette.
  ///
  /// Nous utilisons donc [MealPreview] plutôt que [Meal].
  Future<List<MealPreview>> filterByCategory(
      String category,
      ) async {
    // Encodage du nom de la catégorie afin de gérer
    // correctement les espaces et caractères spéciaux.
    final encodedCategory =
    Uri.encodeQueryComponent(category);

    // Construction de l'URL de l'endpoint.
    final uri = Uri.parse(
      '$_baseUrl/filter.php?c=$encodedCategory',
    );

    // Envoi de la requête HTTP GET.
    //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Vérification du code HTTP.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des recettes '
            'de la catégorie "$category" '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Conversion de la réponse JSON en structure Dart.
    final Map<String, dynamic> data =
    jsonDecode(response.body);

    // Récupération de la propriété "meals".
    final mealsJson = data['meals'];

    // Si aucune recette n'est trouvée,
    // nous retournons une liste vide.
    if (mealsJson == null) {
      return [];
    }

    // Transformation de chaque élément JSON
    // en objet MealPreview.
    return (mealsJson as List)
        .map(
          (json) => MealPreview.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Récupère les recettes correspondant à une zone géographique.
  ///
  /// TheMealDB fournit ici uniquement un aperçu de chaque recette :
  ///
  /// - idMeal
  /// - strMeal
  /// - strMealThumb
  ///
  /// Les informations complètes d'une recette pourront ensuite
  /// être récupérées avec getMealById().
  Future<List<MealPreview>> filterByArea(
      String area,
      ) async {
    // Encode la zone pour pouvoir l'utiliser correctement
    // dans l'URL, notamment si elle contient des espaces
    // ou des caractères spéciaux.
    final encodedArea = Uri.encodeQueryComponent(area);

    // Construit l'URL de l'endpoint TheMealDB.
    //
    // Exemple :
    // filter.php?a=Canadian
    final uri = Uri.parse(
      '$_baseUrl/filter.php?a=$encodedArea',
    );

    // Envoie la requête HTTP à TheMealDB.
    //final response = await http.get(uri);
    final response = await _client.get(uri);

    // Vérifie que le serveur a répondu correctement.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des recettes '
            'de la zone "$area" '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Transforme la réponse JSON en objet Dart.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Récupère la propriété "meals" retournée par TheMealDB.
    final mealsJson = data['meals'];

    // Si aucune recette n'est retournée,
    // on renvoie simplement une liste vide.
    if (mealsJson == null) {
      return [];
    }

    // Transforme chaque élément JSON en MealPreview.
    return (mealsJson as List)
        .map(
          (json) => MealPreview.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }


  /// Récupère les recettes contenant un ingrédient donné.
  ///
  /// TheMealDB fournit ici uniquement les informations nécessaires
  /// pour afficher un aperçu de chaque recette :
  ///
  /// - idMeal
  /// - strMeal
  /// - strMealThumb
  ///
  /// Exemple d'appel :
  ///
  /// filterByIngredient('chicken_breast')
  ///
  /// correspond à l'endpoint :
  ///
  /// filter.php?i=chicken_breast
  ///
  /// Les informations complètes d'une recette pourront ensuite
  /// être récupérées avec getMealById().
  Future<List<MealPreview>> filterByIngredient(
      String ingredient,
      ) async {
    // Encode l'ingrédient afin qu'il puisse être utilisé
    // correctement dans l'URL.
    //
    // Exemple :
    // "chicken breast" devient "chicken%20breast".
    final encodedIngredient =
    Uri.encodeQueryComponent(ingredient);

    // Construit l'URL de l'endpoint TheMealDB.
    final uri = Uri.parse(
      '$_baseUrl/filter.php?i=$encodedIngredient',
    );

    // Envoie la requête HTTP.
    //final response = await http.get(uri)
    final response = await _client.get(uri);

    // Vérifie que TheMealDB a répondu correctement.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des recettes '
            'contenant l\'ingrédient "$ingredient" '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Convertit la réponse JSON en objet Dart.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Récupère la propriété "meals" retournée par TheMealDB.
    final mealsJson = data['meals'];

    // Aucun résultat.
    if (mealsJson == null) {
      return [];
    }

    // Transforme chaque élément JSON en MealPreview.
    return (mealsJson as List)
        .map(
          (json) => MealPreview.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Recherche les recettes dont le nom commence par une lettre donnée.
  ///
  /// TheMealDB utilise l'endpoint :
  ///
  /// search.php?f=a
  ///
  /// Cet endpoint retourne les informations détaillées des recettes.
  /// Nous utilisons donc le modèle Meal.
  ///
  /// Exemple :
  ///
  /// searchMealsByFirstLetter('a')
  Future<List<Meal>> searchMealsByFirstLetter(
      String letter,
      ) async {
    // Supprime les espaces éventuellement présents autour
    // de la lettre fournie.
    final normalizedLetter = letter.trim();

    // Vérifie que nous avons bien reçu une seule lettre.
    if (normalizedLetter.length != 1) {
      throw ArgumentError(
        'La recherche par première lettre nécessite '
            'exactement une lettre.',
      );
    }

    // Transforme la lettre en minuscule pour respecter
    // le format habituellement utilisé par TheMealDB.
    final encodedLetter = Uri.encodeQueryComponent(
      normalizedLetter.toLowerCase(),
    );

    // Construit l'URL de l'endpoint TheMealDB.
    //
    // Exemple :
    // search.php?f=a
    final uri = Uri.parse(
      '$_baseUrl/search.php?f=$encodedLetter',
    );

    // Envoie la requête HTTP.
    //final response = await http.get(uri)
    final response = await _client.get(uri);

    // Vérifie que TheMealDB a répondu correctement.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la recherche des recettes '
            'commençant par "$normalizedLetter" '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Transforme la réponse JSON en objet Dart.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Récupère la propriété "meals".
    final mealsJson = data['meals'];

    // Si aucune recette n'est trouvée,
    // TheMealDB peut retourner null.
    if (mealsJson == null) {
      return [];
    }

    // Transforme chaque recette JSON en objet Meal.
    return (mealsJson as List)
        .map(
          (json) => Meal.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }


  /// Récupère la liste des zones géographiques proposées
  /// par TheMealDB.
  ///
  /// Endpoint utilisé :
  ///
  /// list.php?a=list
  ///
  /// La réponse contient notamment :
  ///
  /// - strArea
  /// - strCountry
  ///
  /// Chaque élément JSON est transformé en objet Area.
  Future<List<Area>> getAreas() async {
    // Construit l'URL de l'endpoint TheMealDB.
    final uri = Uri.parse(
      '$_baseUrl/list.php?a=list',
    );

    // Envoie la requête HTTP.
    //final response = await http.get(uri)
    final response = await _client.get(uri);

    // Vérifie que TheMealDB a répondu correctement.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des zones '
            'géographiques '
            '(code HTTP ${response.statusCode}).',
      );
    }

    // Transforme la réponse JSON en objet Dart.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Récupère la liste contenue dans "meals".
    final areasJson = data['meals'];

    // Aucune zone retournée.
    if (areasJson == null) {
      return [];
    }

    // Transforme chaque élément JSON en objet Area.
    return (areasJson as List)
        .map(
          (json) => Area.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Récupère la liste de référence des ingrédients
  /// proposée par TheMealDB.
  ///
  /// Endpoint utilisé :
  ///
  /// https://www.themealdb.com/api/json/v1/1/list.php?i=list
  ///
  /// Contrairement à `Ingredient`, qui représente un ingrédient
  /// utilisé dans une recette avec une mesure, cette méthode
  /// récupère les fiches générales des ingrédients.
  ///
  /// Retourne une liste vide si TheMealDB ne retourne aucun
  /// ingrédient.
  Future<List<IngredientReference>> getIngredients() async {
    final uri = Uri.parse(
      '$_baseUrl/list.php?i=list',
    );

    //final response = await http.get(uri)
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des ingrédients '
            '(code HTTP ${response.statusCode}).',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    final ingredientsJson = data['meals'];

    if (ingredientsJson == null) {
      return [];
    }

    return (ingredientsJson as List)
        .map(
          (json) => IngredientReference.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}