import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:recettescarnet/services/meal_api_service.dart';

import '../fakes/fake_http_client.dart';

void main() {
  group('MealApiService - searchMeals', () {
    test(
      'searchMeals transforme correctement la réponse JSON en Meal',
          () async {
        // ------------------------------------------------------------
        // ARRANGE
        // ------------------------------------------------------------
        // Nous préparons une réponse JSON simulant TheMealDB.
        //
        // Aucun appel Internet réel ne sera effectué.
        final fakeResponse = http.Response(
          '''
          {
            "meals": [
              {
                "idMeal": "52771",
                "strMeal": "Spicy Arrabiata Penne",
                "strCategory": "Vegetarian",
                "strArea": "Italian",
                "strInstructions": "Bring a large pot of water to a boil.",
                "strMealThumb": "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
                "strTags": null,
                "strYoutube": null,
                "strIngredient1": "penne rigate",
                "strMeasure1": "1 pound",
                "strIngredient2": "olive oil",
                "strMeasure2": "1/4 cup"
              }
            ]
          }
          ''',
          200,
        );

        // Notre faux client retournera la réponse préparée
        // ci-dessus au lieu d'appeler Internet.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // On injecte le faux client dans notre service.
        final service = MealApiService(
          client: fakeClient,
        );

        // ------------------------------------------------------------
        // ACT
        // ------------------------------------------------------------
        // On appelle exactement la même méthode que
        // l'application utilisera.
        final meals = await service.searchMeals('Arrabiata');

        // ------------------------------------------------------------
        // ASSERT
        // ------------------------------------------------------------

        // TheMealDB simulé contient une seule recette.
        expect(meals, hasLength(1));

        // Vérification de l'identifiant.
        expect(meals.first.idMeal, '52771');

        // Vérification du nom.
        expect(
          meals.first.strMeal,
          'Spicy Arrabiata Penne',
        );

        // Vérification de la catégorie.
        expect(
          meals.first.strCategory,
          'Vegetarian',
        );

        // Vérification de la zone géographique.
        expect(
          meals.first.strArea,
          'Italian',
        );

        // Vérification des ingrédients.
        expect(
          meals.first.ingredients,
          isNotEmpty,
        );
      },
    );


    test(
      'searchMeals retourne une liste vide lorsqu aucune recette est trouvée',
          () async {
        // ------------------------------------------------------------
        // ARRANGE
        // ------------------------------------------------------------
        // TheMealDB peut retourner "meals": null
        // lorsqu'aucune recette ne correspond à la recherche.
        final fakeResponse = http.Response(
          '''
      {
        "meals": null
      }
      ''',
          200,
        );

        // Le faux client retournera cette réponse
        // sans effectuer de requête Internet.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        final service = MealApiService(
          client: fakeClient,
        );

        // ------------------------------------------------------------
        // ACT
        // ------------------------------------------------------------
        final meals = await service.searchMeals(
          'RecetteQuiNExistePas',
        );

        // ------------------------------------------------------------
        // ASSERT
        // ------------------------------------------------------------
        // Le service doit retourner une liste vide,
        // et non provoquer une exception.
        expect(meals, isEmpty);
      },
    );


    test(
      'searchMeals lève une exception lorsque le serveur retourne une erreur HTTP',
          () async {
        // ------------------------------------------------------------
        // ARRANGE
        // ------------------------------------------------------------
        // Nous simulons une erreur serveur HTTP 500.
        //
        // Aucun appel réseau réel ne sera effectué.
        final fakeResponse = http.Response(
          'Internal Server Error',
          500,
        );

        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        final service = MealApiService(
          client: fakeClient,
        );

        // ------------------------------------------------------------
        // ACT + ASSERT
        // ------------------------------------------------------------
        // Nous vérifions que searchMeals() lève bien une exception.
        expect(
              () => service.searchMeals('Arrabiata'),
          throwsException,
        );
      },
    );


    group('MealApiService - getMealById', () {
      test(
        'getMealById retourne une recette lorsque l identifiant existe',
            () async {
          // ------------------------------------------------------------
          // ARRANGE
          // ------------------------------------------------------------
          // Nous simulons la réponse JSON de TheMealDB
          // pour la recette 52771.
          final fakeResponse = http.Response(
            '''
        {
          "meals": [
            {
              "idMeal": "52771",
              "strMeal": "Spicy Arrabiata Penne",
              "strCategory": "Vegetarian",
              "strArea": "Italian",
              "strInstructions": "Bring a large pot of water to a boil.",
              "strMealThumb": "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
              "strTags": null,
              "strYoutube": null,
              "strIngredient1": "penne rigate",
              "strMeasure1": "1 pound"
            }
          ]
        }
        ''',
            200,
          );

          // Notre faux client remplace le réseau réel.
          final fakeClient = FakeHttpClient(
            response: fakeResponse,
          );

          // Injection du faux client dans le service.
          final service = MealApiService(
            client: fakeClient,
          );

          // ------------------------------------------------------------
          // ACT
          // ------------------------------------------------------------
          final meal = await service.getMealById('52771');

          // ------------------------------------------------------------
          // ASSERT
          // ------------------------------------------------------------

          // Une recette doit avoir été retournée.
          expect(meal, isNotNull);

          // Vérification de l'identifiant.
          expect(
            meal!.idMeal,
            '52771',
          );

          // Vérification du nom.
          expect(
            meal.strMeal,
            'Spicy Arrabiata Penne',
          );

          // Vérification de la catégorie.
          expect(
            meal.strCategory,
            'Vegetarian',
          );

          // Vérification de la zone géographique.
          expect(
            meal.strArea,
            'Italian',
          );
        },
      );
    });

    test(
      'getMealById retourne null lorsque la recette n existe pas',
          () async {
        // ------------------------------------------------------------
        // ARRANGE
        // ------------------------------------------------------------
        // Nous simulons la réponse de TheMealDB lorsqu'aucune
        // recette ne correspond à l'identifiant demandé.
        final fakeResponse = http.Response(
          '''
      {
        "meals": null
      }
      ''',
          200,
        );

        // Le faux client retourne cette réponse
        // sans effectuer de requête Internet.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        final service = MealApiService(
          client: fakeClient,
        );

        // ------------------------------------------------------------
        // ACT
        // ------------------------------------------------------------
        // Nous utilisons volontairement un identifiant inexistant.
        final meal = await service.getMealById(
          '99999999',
        );

        // ------------------------------------------------------------
        // ASSERT
        // ------------------------------------------------------------
        // Le service doit retourner null,
        // et non provoquer une exception.
        expect(meal, isNull);
      },
    );


    group('MealApiService - getRandomMeal', () {
      test(
        'getRandomMeal retourne une recette aléatoire',
            () async {
          // ------------------------------------------------------------
          // ARRANGE
          // ------------------------------------------------------------
          // Nous simulons la réponse de l'endpoint random.php
          // de TheMealDB.
          final fakeResponse = http.Response(
            '''
        {
          "meals": [
            {
              "idMeal": "53466",
              "strMeal": "Belgian Waterzooi Chicken",
              "strCategory": "Chicken",
              "strArea": "Belgian",
              "strInstructions": "Cook the chicken.",
              "strMealThumb": "https://example.com/chicken.jpg",
              "strTags": null,
              "strYoutube": null,
              "strIngredient1": "Chicken",
              "strMeasure1": "1 whole"
            }
          ]
        }
        ''',
            200,
          );

          // Le faux client remplace le véritable réseau.
          final fakeClient = FakeHttpClient(
            response: fakeResponse,
          );

          // Injection du faux client dans le service.
          final service = MealApiService(
            client: fakeClient,
          );

          // ------------------------------------------------------------
          // ACT
          // ------------------------------------------------------------
          final meal = await service.getRandomMeal();

          // ------------------------------------------------------------
          // ASSERT
          // ------------------------------------------------------------

          // Une recette doit être retournée.
          expect(meal, isNotNull);

          // Vérification de l'identifiant.
          expect(
            meal.idMeal,
            '53466',
          );

          // Vérification du nom.
          expect(
            meal.strMeal,
            'Belgian Waterzooi Chicken',
          );

          // Vérification de la catégorie.
          expect(
            meal.strCategory,
            'Chicken',
          );

          // Vérification de la zone géographique.
          expect(
            meal.strArea,
            'Belgian',
          );
        },
      );
    });


    test(
      'getRandomMeal lève une exception lorsqu aucune recette n est retournée',
          () async {
        // ------------------------------------------------------------
        // ARRANGE
        // ------------------------------------------------------------
        // Nous simulons une réponse HTTP correcte (200),
        // mais TheMealDB ne retourne aucune recette.
        final fakeResponse = http.Response(
          '''
      {
        "meals": []
      }
      ''',
          200,
        );

        // Le faux client retourne notre réponse simulée.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client.
        final service = MealApiService(
          client: fakeClient,
        );

        // ------------------------------------------------------------
        // ACT + ASSERT
        // ------------------------------------------------------------
        // Même si le serveur répond HTTP 200,
        // l'absence de recette constitue une erreur
        // pour cette méthode.
        expect(
              () => service.getRandomMeal(),
          throwsException,
        );
      },
    );



    test(
      'searchMeals lève une exception lorsque la réponse JSON est invalide',
          () async {
        // Réponse volontairement invalide :
        // ce n'est pas un JSON correctement formé.
        final fakeResponse = http.Response(
          '''
      Ceci n'est pas un JSON valide
      ''',
          200,
        );

        // On utilise notre faux client HTTP.
        //
        // Le service pensera recevoir une vraie réponse
        // provenant de TheMealDB.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // On vérifie que le décodage du JSON provoque
        // bien une exception.
        expect(
              () => service.searchMeals('Arrabiata'),
          throwsException,
        );
      },
    );

    test(
      'getMealById lève une exception lorsque la réponse JSON est invalide',
          () async {
        // Réponse qui n'est pas un JSON valide.
        final fakeResponse = http.Response(
          '''
      Ceci n'est pas un JSON valide
      ''',
          200,
        );

        // Faux client HTTP :
        // aucune requête Internet réelle ne sera effectuée.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans MealApiService.
        final service = MealApiService(
          client: fakeClient,
        );

        // Le service doit lever une exception
        // lorsque jsonDecode() essaie de décoder
        // une réponse qui n'est pas du JSON valide.
        expect(
              () => service.getMealById('52771'),
          throwsException,
        );
      },
    );


    test(
      'getCategories transforme correctement la réponse JSON',
          () async {
        // Réponse JSON simulée de TheMealDB.
        //
        // Nous simulons ici deux catégories
        // afin de vérifier que le service les transforme
        // correctement en objets Category.
        final fakeResponse = http.Response(
          '''
      {
        "categories": [
          {
            "idCategory": "1",
            "strCategory": "Beef",
            "strCategoryThumb": "https://example.com/beef.jpg",
            "strCategoryDescription": "Beef recipes"
          },
          {
            "idCategory": "2",
            "strCategory": "Chicken",
            "strCategoryThumb": "https://example.com/chicken.jpg",
            "strCategoryDescription": "Chicken recipes"
          }
        ]
      }
      ''',
          200,
        );

        // Création du faux client HTTP.
        //
        // Aucune connexion Internet réelle ne sera utilisée.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans MealApiService.
        final service = MealApiService(
          client: fakeClient,
        );

        // Appel de la méthode que nous voulons tester.
        final categories = await service.getCategories();

        // Vérifie que deux catégories ont été retournées.
        expect(categories, hasLength(2));

        // Vérifie les données de la première catégorie.
        expect(categories[0].idCategory, '1');
        expect(categories[0].strCategory, 'Beef');

        // Vérifie les données de la deuxième catégorie.
        expect(categories[1].idCategory, '2');
        expect(categories[1].strCategory, 'Chicken');
      },
    );


    test(
      'getCategories retourne une liste vide lorsqu aucune catégorie n est retournée',
          () async {
        // La requête HTTP réussit, mais l'API ne retourne
        // aucune catégorie.
        final fakeResponse = http.Response(
          '''
      {
        "categories": []
      }
      ''',
          200,
        );

        // Création du faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // Appel de la méthode.
        final categories = await service.getCategories();

        // Le résultat attendu est une liste vide.
        expect(categories, isEmpty);
      },
    );


    test(
      'getCategories lève une exception lorsque le serveur retourne une erreur HTTP',
          () async {
        // Nous simulons une erreur serveur HTTP 500.
        final fakeResponse = http.Response(
          '''
      {
        "error": "Internal Server Error"
      }
      ''',
          500,
        );

        // Faux client HTTP.
        //
        // Aucune requête réelle ne sera envoyée à Internet.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // getCategories() doit lever une exception
        // lorsque le code HTTP n'est pas 200.
        expect(
              () => service.getCategories(),
          throwsException,
        );
      },
    );


    test(
      'getCategories lève une exception lorsque la réponse JSON est invalide',
          () async {
        // Réponse HTTP correcte (200),
        // mais contenu qui n'est pas un JSON valide.
        final fakeResponse = http.Response(
          '''
      Ceci n'est pas un JSON valide
      ''',
          200,
        );

        // Faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client.
        final service = MealApiService(
          client: fakeClient,
        );

        // jsonDecode() doit provoquer une exception.
        expect(
              () => service.getCategories(),
          throwsException,
        );
      },
    );


    test(
      'getMealById retourne null lorsque la liste des recettes est vide',
          () async {
        // L'API répond correctement avec HTTP 200,
        // mais aucune recette n'est présente dans la liste.
        final fakeResponse = http.Response(
          '''
      {
        "meals": []
      }
      ''',
          200,
        );

        // Faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // Appel de la méthode.
        final meal = await service.getMealById('52771');

        // Lorsqu'aucune recette n'est retournée,
        // le service doit retourner null.
        expect(meal, isNull);
      },
    );



    test(
      'getRandomMeal lève une exception lorsque la réponse JSON est invalide',
          () async {
        // La réponse HTTP est correcte (200),
        // mais son contenu n'est pas un JSON valide.
        final fakeResponse = http.Response(
          '''
      Ceci n'est pas un JSON valide
      ''',
          200,
        );

        // Création du faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // Le décodage avec jsonDecode() doit provoquer
        // une exception.
        expect(
              () => service.getRandomMeal(),
          throwsException,
        );
      },
    );


    test(
      'getMealById lève une exception lorsque le serveur retourne une erreur HTTP',
          () async {
        // Nous simulons une erreur serveur HTTP 500.
        final fakeResponse = http.Response(
          '''
      {
        "error": "Internal Server Error"
      }
      ''',
          500,
        );

        // Faux client HTTP.
        //
        // Aucune requête réelle ne sera envoyée.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans MealApiService.
        final service = MealApiService(
          client: fakeClient,
        );

        // getMealById() doit lever une exception
        // lorsque le serveur ne retourne pas HTTP 200.
        expect(
              () => service.getMealById('52771'),
          throwsException,
        );
      },
    );

    test(
      'getRandomMeal lève une exception lorsque le serveur retourne une erreur HTTP',
          () async {
        // Nous simulons une erreur serveur HTTP 500.
        final fakeResponse = http.Response(
          '''
      {
        "error": "Internal Server Error"
      }
      ''',
          500,
        );

        // Faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // getRandomMeal() doit lever une exception
        // lorsque le serveur ne retourne pas HTTP 200.
        expect(
              () => service.getRandomMeal(),
          throwsException,
        );
      },
    );


    test(
      'getCategories retourne une liste vide lorsque la clé categories est absente',
          () async {
        // La réponse HTTP est correcte (200),
        // mais la propriété "categories" n'existe pas.
        final fakeResponse = http.Response(
          '''
      {
        "message": "Aucune catégorie disponible"
      }
      ''',
          200,
        );

        // Faux client HTTP.
        final fakeClient = FakeHttpClient(
          response: fakeResponse,
        );

        // Injection du faux client dans le service.
        final service = MealApiService(
          client: fakeClient,
        );

        // Appel de la méthode.
        final categories = await service.getCategories();

        // Le service doit gérer l'absence de la clé
        // et retourner une liste vide.
        expect(categories, isEmpty);
      },
    );


  });
}