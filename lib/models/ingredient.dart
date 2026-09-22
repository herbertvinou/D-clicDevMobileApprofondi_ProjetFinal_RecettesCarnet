/// Représente un ingrédient utilisé dans une recette.
///
/// TheMealDB fournit séparément :
///
/// - le nom de l'ingrédient ;
/// - la quantité / mesure.
///
/// Exemple provenant de TheMealDB :
///
/// strIngredient1 = "Chicken"
/// strMeasure1    = "500g"
///
/// Notre modèle regroupera ces deux informations :
///
/// Ingredient
/// ├── name
/// └── measure
class Ingredient {
  /// Nom de l'ingrédient.
  ///
  /// Exemple :
  /// "Chicken"
  final String name;

  /// Quantité ou mesure de l'ingrédient.
  ///
  /// Exemple :
  /// "500g"
  ///
  /// La valeur peut être absente dans les données de l'API.
  final String? measure;

  /// Constructeur du modèle Ingredient.
  const Ingredient({
    required this.name,
    this.measure,
  });

  /// Construit un objet Ingredient à partir d'un objet JSON.
  ///
  /// Exemple de JSON :
  ///
  /// {
  ///   "name": "Chicken",
  ///   "measure": "500g"
  /// }
  ///
  /// Cette méthode sera notamment utilisée lorsque nous
  /// récupérerons une recette favorite depuis SQLite.
  factory Ingredient.fromJson(
      Map<String, dynamic> json,
      ) {
    return Ingredient(
      // Récupère le nom de l'ingrédient.
      //
      // toString() permet de convertir la valeur reçue
      // en String.
      name: json['name']?.toString() ?? '',

      // La mesure peut être absente.
      //
      // Dans ce cas, nous conservons null.
      measure: json['measure']?.toString(),
    );
  }

  /// Transforme un objet Ingredient en objet JSON.
  ///
  /// Exemple :
  ///
  /// Ingredient(
  ///   name: 'Chicken',
  ///   measure: '500g',
  /// )
  ///
  /// devient :
  ///
  /// {
  ///   "name": "Chicken",
  ///   "measure": "500g"
  /// }
  ///
  /// Cette méthode sera notamment utilisée avant
  /// d'enregistrer une recette favorite dans SQLite.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'measure': measure,
    };
  }
}