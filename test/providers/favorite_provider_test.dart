import 'package:flutter_test/flutter_test.dart';

import 'package:recettescarnet/models/favorite_recipe.dart';
import 'package:recettescarnet/providers/favorite_provider.dart';

import '../fakes/fake_favorite_repository.dart';

void main() {
  // ----------------------------------------------------------
  // TEST : addFavorite()
  // ----------------------------------------------------------

  test(
    'addFavorite ajoute une recette aux favoris du Provider',
        () async {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      //
      // Nous préparons les objets nécessaires au test.
      //
      // Au lieu d'utiliser DatabaseService et SQLite,
      // nous utilisons notre faux repository.

      final fakeRepository =
      FakeFavoriteRepository();

      final provider = FavoriteProvider(
        repository: fakeRepository,
      );

      final favorite = FavoriteRecipe(
        userId: 1,
        mealId: '52771',
        title: 'Spicy Arrabiata Penne',
        category: 'Vegetarian',
        area: 'Italian',
        thumbnail:
        'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg',
        instructions:
        'Cook the pasta and prepare the spicy Arrabiata sauce.',
        createdAt: DateTime.now(),
      );

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      //
      // Nous exécutons l'action que nous voulons tester.

      await provider.addFavorite(favorite);

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      //
      // Nous vérifions le résultat attendu.
      //
      // Après addFavorite(), le Provider doit contenir
      // exactement une recette favorite.

      expect(provider.favorites.length, 1);

      // Nous vérifions également que la recette enregistrée
      // est bien celle que nous avons ajoutée.

      expect(
        provider.favorites.first.mealId,
        '52771',
      );

      expect(
        provider.favorites.first.title,
        'Spicy Arrabiata Penne',
      );
    },
  );


  // ----------------------------------------------------------
  // TEST : loadFavorites()
  // ----------------------------------------------------------

  test(
    'loadFavorites charge les favoris de l’utilisateur',
        () async {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      //
      // Nous créons notre faux repository.
      //
      // Il va nous permettre de préparer des données
      // comme si elles venaient de SQLite.

      final fakeRepository =
      FakeFavoriteRepository();

      // Nous préparons deux recettes favorites
      // appartenant à l'utilisateur 1.

      final favorite1 = FavoriteRecipe(
        userId: 1,
        mealId: '52771',
        title: 'Spicy Arrabiata Penne',
        category: 'Vegetarian',
        area: 'Italian',
        createdAt: DateTime.now(),
      );

      final favorite2 = FavoriteRecipe(
        userId: 1,
        mealId: '52772',
        title: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        createdAt: DateTime.now(),
      );

      // Nous plaçons les recettes dans le faux repository.
      //
      // À ce stade, elles ne sont PAS encore dans le Provider.

      await fakeRepository.insertFavorite(favorite1);
      await fakeRepository.insertFavorite(favorite2);

      // Nous créons ensuite le Provider en lui injectant
      // notre faux repository.

      final provider = FavoriteProvider(
        repository: fakeRepository,
      );

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      //
      // Nous demandons au Provider de charger
      // les favoris de l'utilisateur 1.

      await provider.loadFavorites(1);

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      //
      // Nous vérifions que les deux recettes ont bien
      // été chargées dans le Provider.

      expect(
        provider.favorites.length,
        2,
      );

      // Nous vérifions également les informations
      // des recettes récupérées.

      expect(
        provider.favorites[0].mealId,
        '52771',
      );

      expect(
        provider.favorites[0].title,
        'Spicy Arrabiata Penne',
      );

      expect(
        provider.favorites[1].mealId,
        '52772',
      );

      expect(
        provider.favorites[1].title,
        'Teriyaki Chicken Casserole',
      );
    },
  );

  // ----------------------------------------------------------
  // TEST : isFavorite()
  // ----------------------------------------------------------
  test(
    'isFavorite indique si une recette est dans les favoris',
        () async {
      // ------------------------------------------------------------
      // ARRANGE
      // ------------------------------------------------------------
      // On prépare un faux dépôt contenant une recette favorite.
      final repository = FakeFavoriteRepository();

      final favorite = FavoriteRecipe(
        userId: 1,
        mealId: '52771',
        title: 'Spicy Arrabiata Penne',
        category: 'Vegetarian',
        area: 'Italian',
        thumbnail: 'https://example.com/arrabiata.jpg',
        ingredients: const [],
        instructions: 'Faire cuire les pâtes.',
        createdAt: DateTime.now(),
      );

      await repository.insertFavorite(favorite);

      // Le Provider utilise notre faux Repository.
      final provider = FavoriteProvider(
        repository: repository,
      );

      // ------------------------------------------------------------
      // ACT
      // ------------------------------------------------------------
      // On demande au Provider si la recette 52771
      // appartient aux favoris de l'utilisateur 1.
      final result = await provider.isFavorite(1, '52771');

      // ------------------------------------------------------------
      // ASSERT
      // ------------------------------------------------------------
      // La recette existe bien dans les favoris.
      expect(result, isTrue);
    },
  );


  // ----------------------------------------------------------
  // TEST : removeFavorite()
  // ----------------------------------------------------------

  test(
    'removeFavorite supprime une recette des favoris',
        () async {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      //
      // Nous créons notre faux repository.

      final fakeRepository =
      FakeFavoriteRepository();

      // Nous préparons deux recettes appartenant
      // au même utilisateur.

      final favorite1 = FavoriteRecipe(
        userId: 1,
        mealId: '52771',
        title: 'Spicy Arrabiata Penne',
        category: 'Vegetarian',
        area: 'Italian',
        createdAt: DateTime.now(),
      );

      final favorite2 = FavoriteRecipe(
        userId: 1,
        mealId: '52772',
        title: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        createdAt: DateTime.now(),
      );

      // Nous enregistrons les deux recettes
      // dans notre faux repository.

      await fakeRepository.insertFavorite(favorite1);
      await fakeRepository.insertFavorite(favorite2);

      // Nous créons le Provider avec ce repository.

      final provider = FavoriteProvider(
        repository: fakeRepository,
      );

      // Nous chargeons les favoris de l'utilisateur 1.

      await provider.loadFavorites(1);

      // Vérification préalable :
      // nous devons bien avoir deux favoris.

      expect(
        provider.favorites.length,
        2,
      );

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      //
      // Nous supprimons maintenant la recette 52771.

      await provider.removeFavorite(
        1,
        '52771',
      );

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      //
      // Il doit maintenant rester une seule recette.

      expect(
        provider.favorites.length,
        1,
      );

      // La recette restante doit être 52772.

      expect(
        provider.favorites.first.mealId,
        '52772',
      );

      expect(
        provider.favorites.first.title,
        'Teriyaki Chicken Casserole',
      );

      // Enfin, nous vérifions que 52771
      // n'est plus présente dans le Provider.

      expect(
        provider.favorites.any(
              (favorite) =>
          favorite.mealId == '52771',
        ),
        false,
      );
    },
  );
}