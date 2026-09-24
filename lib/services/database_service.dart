import 'package:flutter/foundation.dart';
import 'package:recettescarnet/services/password_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:recettescarnet/models/favorite_recipe.dart';
import 'package:recettescarnet/services/favorite_repository.dart';

/// Service responsable de la gestion de la base de données SQLite.
///
/// Cette classe centralise toutes les opérations liées
/// à la base de données locale de RecettesCarnet.
///
/// Les écrans et les contrôleurs ne manipulent donc pas
/// directement SQLite.
///
/// Architecture :
///
/// UI
///  ↓
/// Controller / Provider
///  ↓
/// DatabaseService
///  ↓
/// SQLite
class DatabaseService implements FavoriteRepository {
  /// Constructeur privé.
  ///
  /// Il empêche les autres classes de créer plusieurs
  /// instances de DatabaseService.
  DatabaseService._privateConstructor();

  /// Instance unique de DatabaseService.
  ///
  /// On utilisera :
  ///
  /// DatabaseService.instance
  static final DatabaseService instance =
  DatabaseService._privateConstructor();

  /// Instance de la base SQLite.
  ///
  /// Tant que la base n'est pas ouverte, cette valeur est null.
  Database? _database;

  /// Retourne l'instance de la base de données.
  ///
  /// Si la base est déjà ouverte, nous la réutilisons.
  ///
  /// Sinon, nous procédons à son initialisation.
  Future<Database> get database async {
    // La base est-elle déjà ouverte ?
    if (_database != null) {
      return _database!;
    }

    // La base n'est pas encore ouverte.
    //
    // Nous procédons donc à son initialisation.
    _database = await _initDatabase();

    return _database!;
  }

  /// Initialise et ouvre la base SQLite.
  ///
  /// Cette méthode fonctionne sur :
  ///
  /// - Android grâce à sqflite ;
  /// - Web grâce à sqflite_common_ffi_web.
  Future<Database> _initDatabase() async {
    // =========================================================
    // CAS WEB
    // =========================================================

    if (kIsWeb) {
      // Sur Web, nous utilisons la factory fournie
      // par sqflite_common_ffi_web.
      //
      // Cette implémentation permet d'utiliser SQLite
      // dans le navigateur.
      databaseFactory = databaseFactoryFfiWeb;

      // Sur Web, le nom de la base suffit.
      //
      // Nous n'utilisons pas getDatabasesPath()
      // dans ce cas.
      const path = 'recettescarnet.db';

      return await openDatabase(
        path,

        // -----------------------------------------------------
        // VERSION DU SCHÉMA
        // -----------------------------------------------------
        //
        // Nous sommes maintenant en version 2.
        //
        // La version 2 introduit la table favorite_recipes.
        version: 2,

        // -----------------------------------------------------
        // CRÉATION D'UNE NOUVELLE BASE
        // -----------------------------------------------------
        //
        // Cette méthode est appelée uniquement lorsque
        // la base n'existe pas encore.
        onCreate: (Database db, int version) async {
          await _createDatabase(db);
        },

        // -----------------------------------------------------
        // MIGRATION D'UNE BASE EXISTANTE
        // -----------------------------------------------------
        //
        // Cette méthode est appelée lorsqu'une base existante
        // possède une version inférieure à la version demandée.
        onUpgrade: (
            Database db,
            int oldVersion,
            int newVersion,
            ) async {
          // Une base en version 1 possède déjà la table users.
          //
          // La version 2 ajoute favorite_recipes.
          if (oldVersion < 2) {
            await _createFavoriteRecipesTable(db);
          }
        },
      );
    }

    // =========================================================
    // CAS ANDROID / MOBILE
    // =========================================================

    // Récupère le dossier utilisé par SQLite sur Android.
    final databasePath = await getDatabasesPath();

    // Construit le chemin complet de la base.
    final path = '$databasePath/recettescarnet.db';

    return await openDatabase(
      path,

      // -----------------------------------------------------
      // VERSION DU SCHÉMA
      // -----------------------------------------------------
      //
      // Nous passons de la version 1 à la version 2.
      version: 2,

      // -----------------------------------------------------
      // CRÉATION D'UNE NOUVELLE BASE
      // -----------------------------------------------------
      //
      // Si la base n'existe pas, nous créons directement
      // toutes les tables correspondant à la version 2.
      onCreate: (Database db, int version) async {
        await _createDatabase(db);
      },

      // -----------------------------------------------------
      // MIGRATION D'UNE BASE EXISTANTE
      // -----------------------------------------------------
      //
      // Si une ancienne base possède une version 1,
      // cette méthode permet de la faire évoluer
      // vers la version 2.
      onUpgrade: (
          Database db,
          int oldVersion,
          int newVersion,
          ) async {
        // La version 2 ajoute favorite_recipes.
        if (oldVersion < 2) {
          await _createFavoriteRecipesTable(db);
        }
      },
    );
  }

  /// Crée toutes les tables nécessaires à une nouvelle base.
  ///
  /// Cette méthode est utilisée lors de la création initiale
  /// de la base.
  ///
  /// À partir de la version 2, une nouvelle base doit donc
  /// contenir :
  ///
  /// users
  /// favorite_recipes
  Future<void> _createDatabase(Database db) async {
    // =========================================================
    // 1. TABLE users
    // =========================================================

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================================================
    // 2. COMPTE DE DÉMONSTRATION
    // =========================================================

    // Mot de passe utilisé pour le compte de démonstration.
    //
    // IMPORTANT :
    // Nous ne stockons pas directement ce mot de passe
    // dans SQLite.
    const demoPassword = 'admin123';

    // Transformation du mot de passe en hash.
    final passwordHash =
    PasswordService.instance.hashPassword(demoPassword);

    // Création du compte de démonstration.
    await db.insert(
      'users',
      {
        'username': 'admin',
        'email': 'admin@recettescarnet.local',
        'password_hash': passwordHash,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // =========================================================
    // 3. TABLE favorite_recipes
    // =========================================================

    // Pour une nouvelle base, nous créons directement
    // la table des recettes favorites.
    await _createFavoriteRecipesTable(db);
  }

  /// Crée la table favorite_recipes.
  ///
  /// Structure :
  ///
  /// users (1) ──────────── (N) favorite_recipes
  ///
  /// Chaque recette favorite appartient à un utilisateur local.
  Future<void> _createFavoriteRecipesTable(Database db) async {
    await db.execute('''
      CREATE TABLE favorite_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        meal_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT,
        area TEXT,
        thumbnail TEXT,
        ingredients TEXT,
        instructions TEXT,
        created_at TEXT NOT NULL,

        -- Un utilisateur ne peut pas enregistrer
        -- deux fois la même recette.
        UNIQUE(user_id, meal_id),

        -- Relation avec la table users.
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  /// Enregistre une recette favorite dans la base SQLite.
  ///
  /// La recette est fournie sous la forme d'un objet [FavoriteRecipe].
  ///
  /// La méthode :
  ///
  /// 1. récupère la connexion à la base ;
  /// 2. transforme [FavoriteRecipe] en Map grâce à [toMap()] ;
  /// 3. insère les données dans la table `favorite_recipes`.
  ///
  /// La table possède une contrainte :
  ///
  /// UNIQUE(user_id, meal_id)
  ///
  /// Cela signifie qu'un même utilisateur ne peut pas
  /// enregistrer deux fois la même recette.
  ///
  /// Avec [ConflictAlgorithm.ignore], si la recette existe déjà,
  /// SQLite ignore simplement l'insertion.
  ///
  /// La méthode retourne :
  ///
  /// - l'identifiant SQLite de la nouvelle ligne si l'insertion réussit ;
  /// - `0` si l'insertion est ignorée car la recette existe déjà.

  @override
  Future<int> insertFavorite(
      FavoriteRecipe favorite,
      ) async {
    // Récupère la connexion SQLite.
    final db = await database;

    // Transforme l'objet FavoriteRecipe en données
    // compatibles avec les colonnes de la table SQLite.
    final values = favorite.toMap();

    // Insère la recette dans la table favorite_recipes.
    return await db.insert(
      'favorite_recipes',
      values,

      // Si (user_id, meal_id) existe déjà,
      // SQLite ignore l'insertion au lieu de provoquer une erreur.
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Récupère toutes les recettes favorites d'un utilisateur.
  ///
  /// [userId] correspond à l'utilisateur propriétaire
  /// des recettes favorites.
  ///
  /// SQLite retourne initialement une liste de Map.
  /// Nous transformons ensuite chaque ligne en objet
  /// [FavoriteRecipe] grâce à [FavoriteRecipe.fromMap()].
  ///
  /// Les recettes sont triées de la plus récente
  /// à la plus ancienne.

  @override
  Future<List<FavoriteRecipe>> getFavoritesByUser(
      int userId,
      ) async {
    // Récupère la connexion à la base SQLite.
    final db = await database;

    // Recherche uniquement les recettes appartenant
    // à l'utilisateur demandé.
    final rows = await db.query(
      'favorite_recipes',

      // Le ? sera remplacé par la valeur de userId.
      where: 'user_id = ?',

      // Valeur utilisée pour remplacer le ?.
      whereArgs: [userId],

      // Les favoris les plus récents apparaissent en premier.
      orderBy: 'created_at DESC',
    );

    // Transforme chaque ligne SQLite en objet FavoriteRecipe.
    return rows
        .map(
          (row) => FavoriteRecipe.fromMap(row),
    )
        .toList();
  }

  /// Supprime une recette des favoris d'un utilisateur.
  ///
  /// [userId] identifie l'utilisateur propriétaire du favori.
  ///
  /// [mealId] identifie la recette TheMealDB.
  ///
  /// Nous utilisons les deux valeurs dans la clause WHERE
  /// afin de supprimer uniquement le favori correspondant
  /// à cet utilisateur et à cette recette.
  ///
  /// La méthode retourne le nombre de lignes supprimées.
  ///
  /// Exemple :
  ///
  /// - `1` → une recette a bien été supprimée ;
  /// - `0` → aucune recette correspondante n'a été trouvée.

  @override
  Future<int> deleteFavorite(
      int userId,
      String mealId,
      ) async {
    // Récupère la connexion à SQLite.
    final db = await database;

    // Supprime uniquement la ligne correspondant
    // à l'utilisateur ET à la recette.
    return await db.delete(
      'favorite_recipes',

      // Les deux conditions doivent être respectées.
      where: 'user_id = ? AND meal_id = ?',

      // Valeurs utilisées pour remplacer les deux ?.
      whereArgs: [
        userId,
        mealId,
      ],
    );
  }


  /// Vérifie si une recette est déjà enregistrée
  /// dans les favoris d'un utilisateur.
  ///
  /// Retourne :
  /// - true  → la recette existe dans les favoris.
  /// - false → la recette n'existe pas dans les favoris.

  @override
  Future<bool> isFavorite(
      int userId,
      String mealId,
      ) async {
    // Ouvre ou récupère la connexion vers SQLite.
    final db = await database;

    // Recherche une recette correspondant
    // à l'utilisateur et à l'identifiant TheMealDB.
    final rows = await db.query(
      'favorite_recipes',

      // Les deux conditions doivent être respectées :
      // 1. le favori appartient à cet utilisateur ;
      // 2. le meal_id correspond à la recette recherchée.
      where: 'user_id = ? AND meal_id = ?',

      // Les valeurs remplacent les deux ? dans la requête.
      whereArgs: [
        userId,
        mealId,
      ],

      // Nous n'avons besoin que d'une seule ligne
      // pour savoir si le favori existe.
      limit: 1,
    );

    // Si SQLite a trouvé au moins une ligne,
    // la recette est un favori.
    return rows.isNotEmpty;
  }

  /// Recherche l'identifiant d'un utilisateur à partir de son nom d'utilisateur.
  ///
  /// Retourne :
  /// - l'ID de l'utilisateur si le username existe.
  /// - null si aucun utilisateur ne correspond.
  Future<int?> getUserIdByUsername(String username) async {
    final db = await database;

    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    // Aucun utilisateur trouvé.
    if (rows.isEmpty) {
      return null;
    }

    // L'utilisateur existe : on retourne son ID.
    return rows.first['id'] as int;
  }

  /// Enregistre un nouvel utilisateur dans la base SQLite.
  ///
  /// Cette méthode reçoit les informations nécessaires à la création
  /// d'un compte puis les enregistre dans la table `users`.
  ///
  /// Le mot de passe doit déjà être transformé en hash avant
  /// d'arriver dans cette méthode.
  ///
  /// Retourne l'identifiant SQLite du nouvel utilisateur.
  Future<int> insertUser({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    // Récupère la connexion à la base SQLite.
    final db = await database;

    // Prépare les données correspondant aux colonnes
    // de la table `users`.
    final values = {
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Insère le nouvel utilisateur dans SQLite.
    //
    // La méthode retourne automatiquement l'identifiant
    // généré par SQLite grâce à AUTOINCREMENT.
    return await db.insert(
      'users',
      values,
    );
  }

  /// Recherche un utilisateur à partir de son nom d'utilisateur.
  ///
  /// Cette méthode récupère les informations nécessaires
  /// pour vérifier les identifiants lors de la connexion.
  ///
  /// Retourne :
  /// - une Map contenant les données de l'utilisateur si celui-ci existe ;
  /// - null si aucun utilisateur ne correspond.
  Future<Map<String, dynamic>?> getUserByUsername(
      String username,
      ) async {
    // Récupère la connexion à la base SQLite.
    final db = await database;

    // Recherche l'utilisateur correspondant au username.
    final rows = await db.query(
      'users',

      // Nous récupérons uniquement les données
      // nécessaires à l'authentification.
      columns: [
        'id',
        'username',
        'email',
        'password_hash',
      ],

      // Le ? sera remplacé par le username.
      where: 'username = ?',

      // Valeur utilisée pour remplacer le ?.
      whereArgs: [username],

      // Un username correspond à un seul utilisateur.
      limit: 1,
    );

    // Aucun utilisateur trouvé.
    if (rows.isEmpty) {
      return null;
    }

    // Retourne les données du premier utilisateur trouvé.
    return rows.first;
  }
}