import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recettescarnet/core/theme/app_colors.dart';
import 'package:recettescarnet/providers/meal_provider.dart';
import 'package:recettescarnet/screens/recipe_detail_page.dart';
import 'package:recettescarnet/widgets/recipe_card.dart';

/// Écran permettant à l'utilisateur de rechercher
/// des recettes par texte ou par catégorie.
class SearchPage extends StatefulWidget {
  /// Catégorie utilisée pour effectuer une recherche
  /// directement sur une catégorie donnée.
  ///
  /// Lorsque cette valeur est null, l'écran fonctionne
  /// comme une recherche classique par texte.
  final String? category;

  const SearchPage({
    super.key,
    this.category,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// État de l'écran de recherche.
class _SearchPageState extends State<SearchPage> {
  /// Contrôleur permettant de récupérer et de gérer
  /// le texte saisi dans le champ de recherche.
  final TextEditingController _searchController =
  TextEditingController();

  /// Initialise l'écran de recherche.
  ///
  /// Si une catégorie a été transmise à [SearchPage],
  /// cette méthode lance automatiquement la recherche
  /// correspondante.
  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _loadCategoryResults();
    }
  }

  /// Charge les recettes correspondant à la catégorie reçue
  /// lors de l'ouverture de l'écran.
  Future<void> _loadCategoryResults() async {
    final category = widget.category;

    if (category == null || category.trim().isEmpty) {
      return;
    }

    await context
        .read<MealProvider>()
        .searchMealsByCategory(category);
  }

  /// Libère les ressources utilisées par le contrôleur
  /// lorsque l'écran est détruit.
  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  /// Lance une recherche à partir du texte saisi
  /// par l'utilisateur.
  ///
  /// Le texte est transmis au MealProvider qui se charge
  /// ensuite d'appeler le service TheMealDB.
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    await context.read<MealProvider>().searchMeals(query);
  }

  /// Ouvre le détail d'une recette provenant
  /// d'une recherche par catégorie.
  ///
  /// Une recherche par catégorie retourne un MealPreview.
  /// Nous utilisons donc son identifiant pour récupérer
  /// ensuite le Meal complet auprès de TheMealDB.
  Future<void> _openCategoryMeal(
      BuildContext context,
      String? mealId,
      ) async {
    /// Vérifie que l'identifiant de la recette
    /// existe réellement.
    if (mealId == null || mealId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Identifiant de recette introuvable.',
          ),
        ),
      );

      return;
    }

    /// Récupère la recette complète à partir
    /// de son identifiant.
    final meal = await context
        .read<MealProvider>()
        .getMealById(mealId);

    /// Vérifie que la page existe encore
    /// après le chargement asynchrone.
    if (!context.mounted) {
      return;
    }

    /// Vérifie que la recette complète
    /// a bien été récupérée.
    if (meal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de charger cette recette.',
          ),
        ),
      );

      return;
    }

    /// Ouvre la page de détail avec
    /// la recette complète.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          meal: meal,
        ),
      ),
    );
  }

  /// Construit l'interface graphique de l'écran de recherche.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? 'Rechercher une recette'
              : 'Recettes : ${widget.category}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Affiche le champ de recherche uniquement
            /// lorsque l'écran fonctionne en mode recherche texte.
            if (widget.category == null) ...[
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,

                /// Lance la recherche lorsque l'utilisateur
                /// appuie sur la touche "Rechercher" du clavier.
                onSubmitted: (_) {
                  _performSearch();
                },

                decoration: InputDecoration(
                  hintText: 'Rechercher une recette...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Effacer',
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            /// Observe les changements du MealProvider
            /// afin d'actualiser automatiquement l'interface.
            Expanded(
              child: Consumer<MealProvider>(
                builder: (
                    context,
                    mealProvider,
                    child,
                    ) {
                  /// Affiche un indicateur pendant
                  /// l'exécution de la recherche.
                  if (mealProvider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  /// Affiche le message d'erreur retourné
                  /// par le Provider lorsqu'une recherche échoue.
                  if (mealProvider.searchError != null) {
                    return Center(
                      child: Text(
                        mealProvider.searchError!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    );
                  }

                  // =========================================================
                  // RECHERCHE PAR CATÉGORIE
                  // =========================================================

                  /// Affiche les recettes retournées lorsqu'une catégorie
                  /// a été sélectionnée depuis la page d'accueil.
                  ///
                  /// La recherche par catégorie retourne des MealPreview.
                  /// Chaque MealPreview contient notamment l'identifiant,
                  /// le nom et l'image de la recette.
                  if (widget.category != null &&
                      mealProvider.categoryResults.isNotEmpty) {
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        /// Affiche le nombre de recettes
                        /// trouvées dans la catégorie.
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 16,
                          ),
                          child: Text(
                            mealProvider.categoryResults.length ==
                                1
                                ? '1 recette trouvée'
                                : '${mealProvider.categoryResults.length} recettes trouvées',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// Affiche la liste des recettes
                        /// de la catégorie sélectionnée.
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                            ),
                            itemCount:
                            mealProvider.categoryResults.length,
                            itemBuilder: (
                                context,
                                index,
                                ) {
                              final preview =
                              mealProvider.categoryResults[
                              index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: Card(
                                  clipBehavior:
                                  Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding:
                                    const EdgeInsets.all(
                                      12,
                                    ),
                                    /// Affiche l'image de la recette lorsque
                                    /// TheMealDB fournit une URL valide.
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: preview.strMealThumb != null &&
                                          preview.strMealThumb!.isNotEmpty
                                          ? Image.network(
                                        preview.strMealThumb!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,

                                        /// Affiche une icône de remplacement
                                        /// si l'image ne peut pas être chargée.
                                        errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                            ) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.lightGray,
                                            child: const Icon(
                                              Icons.restaurant,
                                              color: AppColors.gray,
                                            ),
                                          );
                                        },
                                      )
                                          : Container(
                                        width: 80,
                                        height: 80,
                                        color: AppColors.lightGray,
                                        child: const Icon(
                                          Icons.restaurant,
                                          color: AppColors.gray,
                                        ),
                                      ),
                                    ),

                                    /// Affiche le nom de la recette.
                                    title: Text(
                                      preview.strMeal,
                                      maxLines: 2,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color:
                                        AppColors.deepNavy,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    /// Indique que la recette
                                    /// peut être ouverte.
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color:
                                      AppColors.primary,
                                    ),

                                    /// Ouvre la page de détail
                                    /// de la recette sélectionnée.
                                    onTap: () {
                                      _openCategoryMeal(
                                        context,
                                        preview.idMeal,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // =========================================================
                  // RECHERCHE PAR TEXTE
                  // =========================================================

                  /// Affiche le nombre de recettes trouvées ainsi que
                  /// la liste des résultats de recherche.
                  if (mealProvider.searchResults.isNotEmpty) {
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        /// Affiche le nombre total de recettes
                        /// retournées par TheMealDB.
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 16,
                          ),
                          child: Text(
                            mealProvider.searchResults.length ==
                                1
                                ? '1 recette trouvée'
                                : '${mealProvider.searchResults.length} recettes trouvées',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// Affiche les recettes sous forme
                        /// de cartes réutilisables.
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                            ),
                            itemCount:
                            mealProvider.searchResults.length,
                            itemBuilder: (
                                context,
                                index,
                                ) {
                              final meal =
                              mealProvider.searchResults[
                              index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: RecipeCard(
                                  meal: meal,

                                  /// Ouvre la page de détail
                                  /// lorsque l'utilisateur
                                  /// sélectionne une recette.
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailPage(
                                              meal: meal,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // =========================================================
                  // ÉTAT INITIAL / AUCUN RÉSULTAT
                  // =========================================================

                  /// Message affiché lorsqu'aucun résultat
                  /// n'est actuellement disponible.
                  return Center(
                    child: Text(
                      widget.category != null
                          ? 'Aucune recette trouvée dans cette catégorie.'
                          : 'Saisissez le nom d’une recette '
                          'pour commencer la recherche.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recettescarnet/core/theme/app_colors.dart';
import 'package:recettescarnet/providers/meal_provider.dart';

import 'package:recettescarnet/screens/recipe_detail_page.dart';
import 'package:recettescarnet/widgets/recipe_card.dart';


/// Écran permettant à l'utilisateur de rechercher
/// des recettes par texte ou par catégorie.
class SearchPage extends StatefulWidget {
  /// Catégorie utilisée pour effectuer une recherche
  /// directement sur une catégorie donnée.
  ///
  /// Lorsque cette valeur est null, l'écran fonctionne
  /// comme une recherche classique par texte.
  final String? category;

  const SearchPage({
    super.key,
    this.category,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// État de l'écran de recherche.
class _SearchPageState extends State<SearchPage> {
  /// Contrôleur permettant de récupérer et de gérer
  /// le texte saisi dans le champ de recherche.
  final TextEditingController _searchController =
  TextEditingController();

  /// Initialise l'écran de recherche.
  ///
  /// Si une catégorie a été transmise à [SearchPage],
  /// cette méthode lance automatiquement la recherche
  /// correspondante.
  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _loadCategoryResults();
    }
  }

  /// Charge les recettes correspondant à la catégorie reçue
  /// lors de l'ouverture de l'écran.
  Future<void> _loadCategoryResults() async {
    final category = widget.category;

    if (category == null || category.trim().isEmpty) {
      return;
    }

    await context
        .read<MealProvider>()
        .searchMealsByCategory(category);
  }

  /// Libère les ressources utilisées par le contrôleur
  /// lorsque l'écran est détruit.
  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  /// Lance une recherche à partir du texte saisi
  /// par l'utilisateur.
  ///
  /// Le texte est transmis au MealProvider qui se charge
  /// ensuite d'appeler le service TheMealDB.
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    await context.read<MealProvider>().searchMeals(query);
  }

  /// Construit l'interface graphique de l'écran de recherche.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? 'Rechercher une recette'
              : 'Recettes : ${widget.category}',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /*
            /// Champ permettant à l'utilisateur
            /// de saisir le nom d'une recette.
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,

              /// Lance la recherche lorsque l'utilisateur
              /// appuie sur la touche "Rechercher" du clavier.
              onSubmitted: (_) {
                _performSearch();
              },

              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer',
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
            */
            /// Champ permettant à l'utilisateur
            /// de saisir le nom d'une recette.
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,

              /// Lance la recherche lorsque l'utilisateur
              /// appuie sur la touche "Rechercher" du clavier.
              onSubmitted: (_) {
                _performSearch();
              },

              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer',
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Observe les changements du MealProvider
            /// afin d'actualiser automatiquement l'interface.
            Expanded(
              child: Consumer<MealProvider>(
                builder: (
                    context,
                    mealProvider,
                    child,
                    ) {
                  /// Affiche un indicateur pendant
                  /// l'exécution de la recherche.
                  if (mealProvider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  /// Affiche le message d'erreur retourné
                  /// par le Provider lorsqu'une recherche échoue.
                  if (mealProvider.searchError != null) {
                    return Center(
                      child: Text(
                        mealProvider.searchError!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    );
                  }

                  /// Affiche les recettes retournées lorsqu'une catégorie
                  /// a été sélectionnée depuis la page d'accueil.
                  ///
                  /// La recherche par catégorie retourne des MealPreview.
                  /// Pour afficher le détail complet d'une recette, nous
                  /// récupérons ensuite le Meal complet grâce à son identifiant.
                  if (widget.category != null &&
                      mealProvider.categoryResults.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: mealProvider.categoryResults.length,
                      itemBuilder: (context, index) {
                        final preview =
                        mealProvider.categoryResults[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),

                              /// Image de la recette retournée par TheMealDB.
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  preview.strMealThumb,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,

                                  /// Image de remplacement si l'image
                                  /// ne peut pas être chargée.
                                  errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColors.lightGray,
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: AppColors.gray,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              /// Nom de la recette.
                              title: Text(
                                preview.strMeal,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.deepNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /// Indique que l'utilisateur peut ouvrir
                              /// le détail de la recette.
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: AppColors.primary,
                              ),

                              /// Ouvre le détail de la recette.
                              onTap: () async {
                                /// Récupère le Meal complet à partir
                                /// de l'identifiant retourné par TheMealDB.
                                final meal = await context
                                    .read<MealProvider>()
                                    .getMealById(preview.idMeal);

                                /// Vérifie que la page existe encore
                                /// après le chargement asynchrone.
                                if (!context.mounted) {
                                  return;
                                }

                                /// Si la recette n'a pas pu être récupérée,
                                /// informe l'utilisateur.
                                if (meal == null) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Impossible de charger cette recette.',
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                /// Ouvre la page de détail avec
                                /// la recette complète.
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailPage(
                                          meal: meal,
                                        ),
                                  ),
                                );
                              },


                            ),
                          ),
                        );
                      },
                    );
                  }

                  /// Affiche le nombre de recettes trouvées ainsi que
                  /// la liste des résultats de recherche.
                  if (mealProvider.searchResults.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Affiche le nombre total de recettes retournées
                        /// par TheMealDB pour la recherche actuelle.
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 16,
                          ),
                          child: Text(
                            mealProvider.searchResults.length == 1
                                ? '1 recette trouvée'
                                : '${mealProvider.searchResults.length} recettes trouvées',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// Affiche les recettes sous forme de cartes
                        /// réutilisant le widget RecipeCard.
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                            ),
                            itemCount: mealProvider.searchResults.length,
                            itemBuilder: (context, index) {
                              final meal =
                              mealProvider.searchResults[index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                child: RecipeCard(
                                  meal: meal,

                                  /// Ouvre la page de détail lorsque
                                  /// l'utilisateur sélectionne une recette.
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailPage(
                                              meal: meal,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  /// Message affiché avant qu'une recherche
                  /// ne soit effectuée.
                  return Center(
                    child: Text(
                      'Saisissez le nom d’une recette '
                          'pour commencer la recherche.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 */