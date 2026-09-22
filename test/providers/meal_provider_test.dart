import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:recettescarnet/providers/meal_provider.dart';
import 'package:recettescarnet/services/meal_api_service.dart';

import '../fakes/fake_http_client.dart';

void main() {
  /// Vérifie que le Provider récupère correctement
  /// les recettes retournées par une recherche.
  test(
    'searchMeals récupère les recettes correspondant à une recherche',
        () async {
      // ------------------------------------------------------------
      // RÉPONSE JSON SIMULÉE
      // ------------------------------------------------------------
      //
      // Nous simulons ici la réponse que TheMealDB
      // pourrait retourner pour une recherche.
      //
      // Aucun appel Internet réel ne sera effectué.
      final response = http.Response(
        '''
        {
          "meals": [
            {
              "idMeal": "52771",
              "strMeal": "Spicy Arrabiata Penne",
              "strCategory": "Vegetarian",
              "strArea": "Italian",
              "strInstructions": "Cook the pasta and prepare the sauce.",
              "strMealThumb": "https://example.com/arrabiata.jpg",
              "strTags": null,
              "strYoutube": null,
              "strSource": null,
              "strImageSource": null,
              "strCreativeCommonsConfirmed": null,
              "strIngredient1": "penne rigate",
              "strIngredient2": "olive oil",
              "strIngredient3": "garlic",
              "strMeasure1": "1 pound",
              "strMeasure2": "1 tbsp",
              "strMeasure3": "2 cloves"
            }
          ]
        }
        ''',
        200,
      );

      // ------------------------------------------------------------
      // CLIENT HTTP FICTIF
      // ------------------------------------------------------------
      //
      // FakeHttpClient retourne notre réponse JSON
      // au lieu d'appeler réellement TheMealDB.
      final fakeClient = FakeHttpClient(
        response: response,
      );

      // ------------------------------------------------------------
      // SERVICE API
      // ------------------------------------------------------------
      //
      // Nous injectons le faux client HTTP
      // dans MealApiService.
      final mealApiService = MealApiService(
        client: fakeClient,
      );

      // ------------------------------------------------------------
      // PROVIDER
      // ------------------------------------------------------------
      //
      // Nous injectons ensuite le service API
      // dans MealProvider.
      final provider = MealProvider(
        mealApiService: mealApiService,
      );

      // ------------------------------------------------------------
      // EXÉCUTION DE LA RECHERCHE
      // ------------------------------------------------------------

      await provider.searchMeals('Arrabiata');

      // ------------------------------------------------------------
      // VÉRIFICATIONS
      // ------------------------------------------------------------

      // Une recette doit avoir été trouvée.
      expect(
        provider.searchResults,
        isNotEmpty,
      );

      // Nous vérifions que la recette reçue
      // correspond bien à notre JSON simulé.
      expect(
        provider.searchResults.first.strMeal,
        'Spicy Arrabiata Penne',
      );

      // Une fois la recherche terminée,
      // le Provider ne doit plus être en chargement.
      expect(
        provider.isSearching,
        false,
      );

      // Aucune erreur ne doit être présente.
      expect(
        provider.searchError,
        isNull,
      );
    },
  );


  /// Vérifie que le Provider gère correctement
  /// une recherche qui ne retourne aucune recette.
  test(
    'searchMeals retourne une liste vide si aucune recette n\'est trouvée',
        () async {
      // ------------------------------------------------------------
      // RÉPONSE JSON SIMULÉE
      // ------------------------------------------------------------
      //
      // TheMealDB utilise "meals": null
      // lorsqu'aucune recette ne correspond à la recherche.
      final response = http.Response(
        '''
      {
        "meals": null
      }
      ''',
        200,
      );

      // ------------------------------------------------------------
      // CLIENT HTTP FICTIF
      // ------------------------------------------------------------

      final fakeClient = FakeHttpClient(
        response: response,
      );

      // ------------------------------------------------------------
      // SERVICE API
      // ------------------------------------------------------------

      final mealApiService = MealApiService(
        client: fakeClient,
      );

      // ------------------------------------------------------------
      // PROVIDER
      // ------------------------------------------------------------

      final provider = MealProvider(
        mealApiService: mealApiService,
      );

      // ------------------------------------------------------------
      // EXÉCUTION DE LA RECHERCHE
      // ------------------------------------------------------------

      await provider.searchMeals('xyzabc123');

      // ------------------------------------------------------------
      // VÉRIFICATIONS
      // ------------------------------------------------------------

      // Aucune recette ne doit être présente.
      expect(
        provider.searchResults,
        isEmpty,
      );

      // L'absence de résultat n'est pas une erreur technique.
      expect(
        provider.searchError,
        isNull,
      );

      // La recherche doit être terminée.
      expect(
        provider.isSearching,
        false,
      );
    },
  );

  /// Vérifie qu'une recherche vide ne déclenche pas
  /// d'appel inutile vers TheMealDB.
  test(
    'searchMeals vide les résultats si la recherche est vide',
        () async {
      // ------------------------------------------------------------
      // PROVIDER
      // ------------------------------------------------------------
      //
      // Aucun service particulier n'est nécessaire ici,
      // car une recherche vide doit être arrêtée directement
      // par le Provider.
      final provider = MealProvider();

      // ------------------------------------------------------------
      // EXÉCUTION
      // ------------------------------------------------------------

      await provider.searchMeals('   ');

      // ------------------------------------------------------------
      // VÉRIFICATIONS
      // ------------------------------------------------------------

      // Aucun résultat ne doit être présent.
      expect(
        provider.searchResults,
        isEmpty,
      );

      // Une recherche vide ne constitue pas une erreur.
      expect(
        provider.searchError,
        isNull,
      );

      // Aucun chargement ne doit être en cours.
      expect(
        provider.isSearching,
        false,
      );
    },
  );


  /// Vérifie que le Provider gère correctement
  /// une erreur HTTP provenant du service API.
  test(
    'searchMeals gère une erreur HTTP',
        () async {
      // ------------------------------------------------------------
      // RÉPONSE HTTP SIMULÉE
      // ------------------------------------------------------------
      //
      // Nous simulons ici une erreur serveur HTTP 500.
      final response = http.Response(
        'Erreur serveur',
        500,
      );

      // ------------------------------------------------------------
      // CLIENT HTTP FICTIF
      // ------------------------------------------------------------

      final fakeClient = FakeHttpClient(
        response: response,
      );

      // ------------------------------------------------------------
      // SERVICE API
      // ------------------------------------------------------------

      final mealApiService = MealApiService(
        client: fakeClient,
      );

      // ------------------------------------------------------------
      // PROVIDER
      // ------------------------------------------------------------

      final provider = MealProvider(
        mealApiService: mealApiService,
      );

      // ------------------------------------------------------------
      // EXÉCUTION DE LA RECHERCHE
      // ------------------------------------------------------------

      await provider.searchMeals('Arrabiata');

      // ------------------------------------------------------------
      // VÉRIFICATIONS
      // ------------------------------------------------------------

      // Aucun résultat ne doit rester après l'erreur.
      expect(
        provider.searchResults,
        isEmpty,
      );

      // Une erreur doit être enregistrée par le Provider.
      expect(
        provider.searchError,
        isNotNull,
      );

      // La recherche doit être terminée malgré l'erreur.
      expect(
        provider.isSearching,
        false,
      );
    },
  );


  /// Vérifie qu'une recherche par catégorie
  /// retourne correctement les recettes correspondantes.
  test(
    'searchMealsByCategory retourne les recettes de la catégorie',
        () async {
      const responseBody = '''
    {
      "meals": [
        {
          "strMeal": "Beef and Mustard Pie",
          "strMealThumb": "https://example.com/beef.jpg",
          "idMeal": "52874"
        },
        {
          "strMeal": "Beef Wellington",
          "strMealThumb": "https://example.com/wellington.jpg",
          "idMeal": "52875"
        }
      ]
    }
    ''';

      final fakeClient = FakeHttpClient(
        response: http.Response(
          responseBody,
          200,
        ),
      );

      final apiService = MealApiService(
        client: fakeClient,
      );

      final provider = MealProvider(
        mealApiService: apiService,
      );

      await provider.searchMealsByCategory('Beef');

      expect(
        provider.categoryResults.length,
        2,
      );

      expect(
        provider.categoryResults.first.strMeal,
        'Beef and Mustard Pie',
      );

      expect(
        provider.categoryResults.last.strMeal,
        'Beef Wellington',
      );

      expect(
        provider.isSearching,
        false,
      );

      expect(
        provider.searchError,
        isNull,
      );
    },
  );

}