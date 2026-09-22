import 'dart:async';

import 'package:http/http.dart' as http;

/// Faux client HTTP utilisé uniquement pour les tests.
///
/// Son objectif est de remplacer le véritable client HTTP.
///
/// Au lieu d'aller sur Internet, le test pourra lui fournir
/// directement une réponse HTTP simulée.
///
/// Cela permet de tester MealApiService même :
///
/// - sans connexion Internet ;
/// - sans dépendre de TheMealDB ;
/// - sans attendre une vraie réponse réseau.
class FakeHttpClient extends http.BaseClient {
  /// Réponse HTTP que notre faux client doit retourner.
  final http.Response response;

  /// Constructeur du faux client.
  ///
  /// Le test fournit la réponse qu'il souhaite simuler.
  FakeHttpClient({
    required this.response,
  });

  /// Méthode appelée automatiquement par `http.Client`.
  ///
  /// Dans notre cas, nous ne faisons aucune requête réseau.
  ///
  /// Nous retournons simplement la réponse préparée
  /// par le test.
  @override
  Future<http.StreamedResponse> send(
      http.BaseRequest request,
      ) async {
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}