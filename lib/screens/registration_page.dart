import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/database_service.dart';
import '../services/password_service.dart';


// ============================================================
// PAGE D'INSCRIPTION
// ============================================================

/// Page permettant à l'utilisateur de créer un nouveau compte.
///
/// Les informations du compte sont enregistrées localement
/// dans SQLite.
///
/// Le mot de passe est transformé en hash avant son
/// enregistrement dans la base de données.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() =>
      _RegistrationPageState();
}


// ============================================================
// ETAT DE LA PAGE
// ============================================================

class _RegistrationPageState extends State<RegistrationPage> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  /// Contrôleur du champ nom d'utilisateur.
  final TextEditingController _usernameController =
  TextEditingController();

  /// Contrôleur du champ adresse e-mail.
  final TextEditingController _emailController =
  TextEditingController();

  /// Contrôleur du champ mot de passe.
  final TextEditingController _passwordController =
  TextEditingController();

  /// Contrôleur du champ confirmation du mot de passe.
  final TextEditingController _confirmPasswordController =
  TextEditingController();


  // ==========================================================
  // FORMULAIRE
  // ==========================================================

  /// Clé permettant de valider les différents champs
  /// du formulaire d'inscription.
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();


  // ==========================================================
  // ETAT DES MOTS DE PASSE
  // ==========================================================

  /// Indique si le mot de passe principal est masqué.
  bool _obscurePassword = true;

  /// Indique si la confirmation du mot de passe est masquée.
  bool _obscureConfirmPassword = true;


  // ==========================================================
  // ETAT DE CHARGEMENT
  // ==========================================================

  /// Indique si l'enregistrement du compte est en cours.
  ///
  /// Cette variable permet d'éviter plusieurs inscriptions
  /// déclenchées par plusieurs clics successifs.
  bool _isRegistering = false;


  // ==========================================================
  // DIMENSIONS DES CONTROLES
  // ==========================================================

  /// Hauteur commune des champs et contrôles de saisie.
  ///
  /// Cette valeur reprend le principe utilisé dans LoginPage
  /// avec la variable `controlHeight`.
  static const double controlHeight = 56;

  /// Rayon commun des champs et boutons.
  ///
  /// Cette valeur reprend le principe utilisé dans LoginPage
  /// avec la variable `controlRadius`.
  static const double controlRadius = 16;


  // ==========================================================
  // LIBERATION DES RESSOURCES
  // ==========================================================

  /// Libère les contrôleurs lorsque la page est détruite.
  ///
  /// Cela permet d'éviter de conserver inutilement les
  /// ressources associées aux champs de saisie.
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }


  // ==========================================================
  // INSCRIPTION
  // ==========================================================

  /// Valide les données saisies puis crée le compte
  /// dans la base de données SQLite.
  ///
  /// Le mot de passe est hashé avant d'être enregistré.
  ///
  /// Après une inscription réussie, l'utilisateur revient
  /// automatiquement à la page de connexion.
  Future<void> _register() async {
    // Vérifie que tous les champs sont valides.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Empêche un deuxième enregistrement pendant
    // qu'une inscription est déjà en cours.
    if (_isRegistering) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      // Récupère les valeurs saisies par l'utilisateur.
      final String username =
      _usernameController.text.trim();

      final String email =
      _emailController.text.trim();

      final String password =
          _passwordController.text;

      // Transforme le mot de passe en hash.
      //
      // Le mot de passe en clair n'est donc pas transmis
      // à la base de données.
      final String passwordHash =
      PasswordService.instance.hashPassword(password);

      // Enregistre le nouvel utilisateur dans SQLite.
      await DatabaseService.instance.insertUser(
        username: username,
        email: email,
        passwordHash: passwordHash,
      );

      // Vérifie que la page existe encore.
      if (!mounted) {
        return;
      }

      // Informe l'utilisateur que le compte a été créé.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Retourne à la page de connexion.
      Navigator.of(context).pop();
    } catch (e) {
      // Vérifie que la page existe toujours.
      if (!mounted) {
        return;
      }

      // Affiche un message simple et compréhensible.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de créer le compte. '
                'Vérifiez que cette adresse e-mail '
                'n’est pas déjà utilisée.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Arrête l'indicateur de chargement.
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }


  // ============================================================
  // NOM D'UTILISATEUR
  // ============================================================

  /// Construit le champ nom d'utilisateur.
  ///
  /// Le style est volontairement identique au champ
  /// nom d'utilisateur de LoginPage.
  Widget _buildUsernameField() {
    return SizedBox(
      height: controlHeight,
      child: TextFormField(
        controller: _usernameController,

        // Le nom d'utilisateur est du texte classique.
        keyboardType: TextInputType.text,

        textInputAction: TextInputAction.next,

        style: const TextStyle(
          fontSize: 16,
          color: AppColors.dark,
        ),

        decoration: InputDecoration(
          hintText: 'Nom d’utilisateur',

          hintStyle: const TextStyle(
            color: AppColors.gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.person_outline,
            size: 23,
            color: AppColors.blueGray,
          ),

          filled: true,

          // Même surface que LoginPage.
          fillColor: Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),

        validator: (value) {
          final String username =
              value?.trim() ?? '';

          if (username.isEmpty) {
            return "Veuillez saisir un nom d'utilisateur.";
          }

          if (username.length < 3) {
            return 'Minimum 3 caractères.';
          }

          return null;
        },
      ),
    );
  }


  // ============================================================
  // ADRESSE E-MAIL
  // ============================================================

  /// Construit le champ adresse e-mail.
  ///
  /// Le champ reprend exactement le même style visuel
  /// que le champ nom d'utilisateur de LoginPage.
  Widget _buildEmailField() {
    return SizedBox(
      height: controlHeight,
      child: TextFormField(
        controller: _emailController,

        keyboardType:
        TextInputType.emailAddress,

        textInputAction:
        TextInputAction.next,

        style: const TextStyle(
          fontSize: 16,
          color: AppColors.dark,
        ),

        decoration: InputDecoration(
          hintText: 'Adresse e-mail',

          hintStyle: const TextStyle(
            color: AppColors.gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.email_outlined,
            size: 23,
            color: AppColors.blueGray,
          ),

          filled: true,

          fillColor: Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),

        validator: (value) {
          final String email =
              value?.trim() ?? '';

          if (email.isEmpty) {
            return 'Veuillez saisir votre adresse e-mail.';
          }

          final bool isValidEmail = RegExp(
            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
          ).hasMatch(email);

          if (!isValidEmail) {
            return 'Veuillez saisir une adresse e-mail valide.';
          }

          return null;
        },
      ),
    );
  }


  // ============================================================
  // MOT DE PASSE
  // ============================================================

  /// Construit le champ mot de passe.
  ///
  /// Le champ reprend le même style que les champs
  /// de LoginPage et ajoute un bouton permettant
  /// d'afficher ou de masquer le mot de passe.
  Widget _buildPasswordField() {
    return SizedBox(
      height: controlHeight,
      child: TextFormField(
        controller: _passwordController,

        obscureText: _obscurePassword,

        textInputAction:
        TextInputAction.next,

        style: const TextStyle(
          fontSize: 16,
          color: AppColors.dark,
        ),

        decoration: InputDecoration(
          hintText: 'Mot de passe',

          hintStyle: const TextStyle(
            color: AppColors.gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 23,
            color: AppColors.blueGray,
          ),

          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Afficher le mot de passe'
                : 'Masquer le mot de passe',

            onPressed: () {
              setState(() {
                _obscurePassword =
                !_obscurePassword;
              });
            },

            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 23,
              color: AppColors.blueGray,
            ),
          ),

          filled: true,

          fillColor: Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),

        validator: (value) {
          final String password =
              value ?? '';

          if (password.isEmpty) {
            return 'Veuillez saisir un mot de passe.';
          }

          if (password.length < 6) {
            return 'Minimum 6 caractères.';
          }

          return null;
        },
      ),
    );
  }


  // ============================================================
  // CONFIRMATION DU MOT DE PASSE
  // ============================================================

  /// Construit le champ de confirmation du mot de passe.
  ///
  /// Le champ utilise exactement le même style visuel
  /// que le champ mot de passe.
  Widget _buildConfirmPasswordField() {
    return SizedBox(
      height: controlHeight,
      child: TextFormField(
        controller: _confirmPasswordController,

        obscureText:
        _obscureConfirmPassword,

        textInputAction:
        TextInputAction.done,

        onFieldSubmitted: (_) {
          _register();
        },

        style: const TextStyle(
          fontSize: 16,
          color: AppColors.dark,
        ),

        decoration: InputDecoration(
          hintText:
          'Confirmer le mot de passe',

          hintStyle: const TextStyle(
            color: AppColors.gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 23,
            color: AppColors.blueGray,
          ),

          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword
                ? 'Afficher le mot de passe'
                : 'Masquer le mot de passe',

            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                !_obscureConfirmPassword;
              });
            },

            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 23,
              color: AppColors.blueGray,
            ),
          ),

          filled: true,

          fillColor: Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),

        validator: (value) {
          final String confirmPassword =
              value ?? '';

          if (confirmPassword.isEmpty) {
            return 'Veuillez confirmer votre mot de passe.';
          }

          if (confirmPassword !=
              _passwordController.text) {
            return 'Les mots de passe ne correspondent pas.';
          }

          return null;
        },
      ),
    );
  }


  // ============================================================
  // BOUTON D'INSCRIPTION
  // ============================================================

  /// Construit le bouton principal d'inscription.
  ///
  /// La couleur Primary #115ADA respecte la charte
  /// graphique RecettesCarnet.
  ///
  /// Le rayon utilise controlRadius afin de conserver
  /// la même géométrie que les contrôles de LoginPage.
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: controlHeight,

      child: FilledButton.icon(
        onPressed:
        _isRegistering ? null : _register,

        style: FilledButton.styleFrom(
          backgroundColor:
          AppColors.primary,

          foregroundColor:
          AppColors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
          ),
        ),

        icon: _isRegistering
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        )
            : const Icon(
          Icons.person_add_alt_1,
        ),

        label: Text(
          _isRegistering
              ? 'Inscription...'
              : "S'inscrire",

          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // BOUTON RETOUR
  // ============================================================

  /// Construit le bouton permettant de revenir
  /// à la page de connexion.
  ///
  /// Le bouton reprend le style secondaire de l'application :
  /// surface claire, bordure Primary et texte Primary.
  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      height: controlHeight,

      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },

        style: OutlinedButton.styleFrom(
          // La surface est laissée au thème.
          backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,

          foregroundColor:
          AppColors.primary,

          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
          ),
        ),

        child: const Text(
          'Retour',

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // INTERFACE
  // ============================================================

  /// Construit l'interface complète de la page d'inscription.
  ///
  /// La page est défilable afin de rester utilisable lorsque
  /// le clavier virtuel est affiché sur un petit écran.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aucun backgroundColor n'est imposé ici.
      //
      // Le Scaffold utilise donc la couleur définie
      // par le thème courant de l'application.

      appBar: AppBar(
        title: const Text(
          'Inscription',

          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),

        centerTitle: false,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },

          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.deepNavy,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),

            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 520,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [

                    // ==================================================
                    // ILLUSTRATION
                    // ==================================================

                    Image.asset(
                      'assets/images/splash_recettescarnet.png',

                      height: 300,

                      fit: BoxFit.contain,

                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const SizedBox(
                          height: 300,

                          child: Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color:
                              AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),


                    // ==================================================
                    // NOM D'UTILISATEUR
                    // ==================================================

                    _buildUsernameField(),

                    const SizedBox(
                      height: 16,
                    ),


                    // ==================================================
                    // ADRESSE E-MAIL
                    // ==================================================

                    _buildEmailField(),

                    const SizedBox(
                      height: 16,
                    ),


                    // ==================================================
                    // MOT DE PASSE
                    // ==================================================

                    _buildPasswordField(),

                    const SizedBox(
                      height: 16,
                    ),


                    // ==================================================
                    // CONFIRMATION DU MOT DE PASSE
                    // ==================================================

                    _buildConfirmPasswordField(),

                    const SizedBox(
                      height: 28,
                    ),


                    // ==================================================
                    // INSCRIPTION
                    // ==================================================

                    _buildRegisterButton(),

                    const SizedBox(
                      height: 16,
                    ),


                    // ==================================================
                    // RETOUR
                    // ==================================================

                    _buildBackButton(),

                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}