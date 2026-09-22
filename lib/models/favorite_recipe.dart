import 'dart:convert';

import 'package:recettescarnet/models/ingredient.dart';
import 'package:recettescarnet/models/meal.dart';


/// Représente une recette enregistrée dans les favoris locaux.
///
/// Cette classe correspond à la table SQLite :
///
/// favorite_recipes
///
/// La recette favorite est associée à un utilisateur local
/// grâce au champ userId.
///
/// Relation :
///
/// users (1) ──────────── (N) favorite_recipes
///
/// Une recette provenant de TheMealDB sera donc transformée
/// en FavoriteRecipe avant d'être enregistrée localement.
class FavoriteRecipe {
  /// Identifiant SQLite de la recette favorite.
  ///
  /// Cette valeur est générée automatiquement par SQLite
  /// grâce à AUTOINCREMENT.
  ///
  /// Elle peut donc être null lorsqu'une recette n'est pas
  /// encore enregistrée dans la base.
  final int? id;

  /// Identifiant de l'utilisateur local propriétaire
  /// de cette recette favorite.
  ///
  /// Correspond à :
  ///
  /// favorite_recipes.user_id
  final int userId;

  /// Identifiant de la recette dans TheMealDB.
  ///
  /// Exemple :
  ///
  /// "52771"
  final String mealId;

  /// Nom de la recette.
  ///
  /// Exemple :
  ///
  /// "Spicy Arrabiata Penne"
  final String title;

  /// Catégorie de la recette.
  ///
  /// Exemple :
  ///
  /// "Vegetarian"
  final String? category;

  /// Origine géographique de la recette.
  ///
  /// Exemple :
  ///
  /// "Italian"
  final String? area;

  /// URL de l'image de la recette.
  final String? thumbnail;

  /// Liste des ingrédients de la recette.
  ///
  /// Contrairement à SQLite, Dart peut directement
  /// manipuler une `List<Ingredient>`.
  ///
  /// Lors de l'enregistrement dans SQLite, cette liste
  /// sera transformée en JSON.
  final List<Ingredient> ingredients;

  /// Instructions de préparation de la recette.
  final String? instructions;

  /// Date et heure auxquelles la recette a été enregistrée
  /// dans les favoris.
  final DateTime createdAt;

  /// Constructeur de FavoriteRecipe.
  const FavoriteRecipe({
    this.id,
    required this.userId,
    required this.mealId,
    required this.title,
    this.category,
    this.area,
    this.thumbnail,
    this.ingredients = const [],
    this.instructions,
    required this.createdAt,
  });

  /// Construit une FavoriteRecipe à partir d'une ligne SQLite.
  ///
  /// SQLite nous retourne une `Map<String, dynamic>`.
  ///
  /// Exemple :
  ///
  /// {
  ///   "id": 1,
  ///   "user_id": 1,
  ///   "meal_id": "52771",
  ///   "title": "Spicy Arrabiata Penne",
  ///   "category": "Vegetarian",
  ///   "area": "Italian",
  ///   "thumbnail": "https://...",
  ///   "ingredients": "[...]",
  ///   "instructions": "...",
  ///   "created_at": "2026-09-19T10:00:00.000"
  /// }
  factory FavoriteRecipe.fromMap(
      Map<String, dynamic> map,
      ) {
    // La colonne ingredients de SQLite est stockée
    // sous forme de texte JSON.
    //
    // Nous devons donc :
    //
    // String JSON
    //     ↓
    // jsonDecode()
    //     ↓
    // List<dynamic>
    //     ↓
    // List<Ingredient>
    final ingredientsJson = map['ingredients'] as String?;

    final List<Ingredient> ingredients;

    if (ingredientsJson == null || ingredientsJson.isEmpty) {
      // Si aucun ingrédient n'est enregistré,
      // nous utilisons simplement une liste vide.
      ingredients = [];
    } else {
      // Transforme le texte JSON en objet Dart.
      final decoded = jsonDecode(ingredientsJson) as List;

      // Transforme chaque élément JSON en Ingredient.
      ingredients = decoded
          .map(
            (json) => Ingredient.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    return FavoriteRecipe(
      // L'identifiant SQLite peut être null dans certains cas.
      id: map['id'] as int?,

      // Correspond à la colonne SQLite user_id.
      userId: map['user_id'] as int,

      // Correspond à meal_id.
      mealId: map['meal_id'].toString(),

      // Correspond à title.
      title: map['title'].toString(),

      // Les colonnes optionnelles peuvent être null.
      category: map['category']?.toString(),
      area: map['area']?.toString(),
      thumbnail: map['thumbnail']?.toString(),

      // Liste des ingrédients reconstruite ci-dessus.
      ingredients: ingredients,

      // Instructions facultatives.
      instructions: map['instructions']?.toString(),

      // SQLite stocke la date sous forme de texte.
      //
      // DateTime.parse() permet de reconstruire
      // l'objet DateTime.
      createdAt: DateTime.parse(
        map['created_at'].toString(),
      ),
    );
  }

  /// Transforme FavoriteRecipe en Map compatible avec SQLite.
  ///
  /// Le processus est inverse de fromMap().
  ///
  /// FavoriteRecipe
  ///       ↓
  ///     toMap()
  ///       ↓
  /// `Map<String, dynamic>`
  ///       ↓
  ///     SQLite
  Map<String, dynamic> toMap() {
    // Transforme chaque Ingredient en objet JSON.
    final ingredientsJson = ingredients
        .map(
          (ingredient) => ingredient.toJson(),
    )
        .toList();

    return {
      // Nous ne mettons id que lorsqu'il existe.
      //
      // Lors de l'insertion d'une nouvelle recette,
      // SQLite pourra générer automatiquement cet identifiant.
      if (id != null) 'id': id,

      // Nom de la colonne SQLite : user_id.
      'user_id': userId,

      // Nom de la colonne SQLite : meal_id.
      'meal_id': mealId,

      // Nom de la colonne SQLite : title.
      'title': title,

      // Colonnes facultatives.
      'category': category,
      'area': area,
      'thumbnail': thumbnail,

      // La liste Dart est transformée en texte JSON
      // avant d'être enregistrée dans SQLite.
      'ingredients': jsonEncode(ingredientsJson),

      // Instructions de préparation.
      'instructions': instructions,

      // SQLite reçoit la date sous forme de texte ISO 8601.
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Construit une recette favorite à partir d'un objet Meal.
  ///
  /// Cette méthode réalise la conversion entre :
  ///
  /// `Meal`
  ///     ↓
  /// `FavoriteRecipe`
  ///
  /// Les informations provenant de TheMealDB sont copiées
  /// vers le modèle utilisé pour le stockage local.
  ///
  /// Le `userId` est fourni par notre application car cette
  /// information n'existe pas dans TheMealDB.
  ///
  /// De même, `createdAt` correspond à la date à laquelle
  /// l'utilisateur enregistre la recette dans ses favoris.
  factory FavoriteRecipe.fromMeal({
    required Meal meal,
    required int userId,
  }) {
    return FavoriteRecipe(
      // Une nouvelle recette favorite n'a pas encore
      // d'identifiant SQLite.
      //
      // SQLite le générera automatiquement lors de l'insertion.
      id: null,

      // Identifie l'utilisateur local qui enregistre
      // cette recette dans ses favoris.
      userId: userId,

      // Identifiant fourni par TheMealDB.
      mealId: meal.idMeal,

      // Nom fourni par TheMealDB.
      title: meal.strMeal,

      // Catégorie provenant de TheMealDB.
      category: meal.strCategory,

      // Origine géographique provenant de TheMealDB.
      area: meal.strArea,

      // URL de l'image provenant de TheMealDB.
      thumbnail: meal.strMealThumb,

      // Nous conservons directement la liste des ingrédients.
      //
      // Elle sera transformée en JSON uniquement au moment
      // de la sauvegarde dans SQLite grâce à toMap().
      ingredients: meal.ingredients,

      // Instructions provenant de TheMealDB.
      instructions: meal.strInstructions,

      // Date d'enregistrement du favori.
      createdAt: DateTime.now(),
    );
  }
}