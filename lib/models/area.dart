/// Représente une zone géographique proposée par TheMealDB.
///
/// TheMealDB associe une appellation culinaire (strArea)
/// à un pays (strCountry).
///
/// Exemple de données reçues depuis l'API :
///
/// {
///   "strArea": "Beninese",
///   "strCountry": "Benin"
/// }
class Area {
  final String strArea;
  final String strCountry;

  const Area({
    required this.strArea,
    required this.strCountry,
  });

  /// Construit un objet Area à partir des données JSON
  /// retournées par TheMealDB.
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      strArea: json['strArea']?.toString() ?? '',
      strCountry: json['strCountry']?.toString() ?? '',
    );
  }
}