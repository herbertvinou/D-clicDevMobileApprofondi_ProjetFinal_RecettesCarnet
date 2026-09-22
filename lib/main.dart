import 'package:flutter/material.dart';

import 'package:recettescarnet/core/theme/app_theme.dart';
import 'package:recettescarnet/providers/meal_provider.dart';
import 'package:recettescarnet/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:recettescarnet/providers/category_provider.dart';
import 'package:recettescarnet/providers/favorite_provider.dart';


import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise la base SQLite avant de lancer l'application.
  await DatabaseService.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MealProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ----------------------------------------------------------
      // THÈME GLOBAL DE RECETTESCARNET
      // ----------------------------------------------------------
      //
      // Tous les écrans de l'application vont maintenant
      // bénéficier automatiquement de notre thème centralisé.
      theme: AppTheme.lightTheme,

      home: const SplashScreen(),
    );
  }
}