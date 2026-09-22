import 'package:flutter/material.dart';

import '../providers/user_session.dart';
import 'home_page.dart';
import 'package:recettescarnet/services/database_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // PALETTE RECETTESCARNET
  // ============================================================

  static const Color primary = Color(0xFF115ADA);
  static const Color primaryDark = Color(0xFF0946DC);
  static const Color deepNavy = Color(0xFF17336E);

  static const Color blueGray = Color(0xFF4A689F);
  static const Color lightGray = Color(0xFFE4E6E8);
  static const Color gray = Color(0xFF818282);
  static const Color dark = Color(0xFF292C2C);

  // ============================================================
  // CONSTANTES UX
  // ============================================================

  /// Hauteur commune des champs et boutons.
  static const double controlHeight = 54;

  /// Rayon commun des champs et boutons.
  static const double controlRadius = 16;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  /// Contrôleur du nom d'utilisateur.
  final TextEditingController _usernameController =
  TextEditingController();

  /// Contrôleur du mot de passe.
  final TextEditingController _passwordController =
  TextEditingController();

  // ============================================================
  // ÉTAT LOCAL
  // ============================================================

  bool _obscurePassword = true;

  bool _rememberMe = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLargeScreen =
                constraints.maxWidth >= 800;

            if (isLargeScreen) {
              return _buildLargeScreenLayout();
            }

            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // LAYOUT MOBILE / TABLETTE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Illustration.
          _buildHeader(),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: _buildLoginForm(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT GRAND ÉCRAN / WEB
  // ============================================================

  Widget _buildLargeScreenLayout() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              // --------------------------------------------------
              // ILLUSTRATION
              // --------------------------------------------------

              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: _buildLargeHeader(),
                ),
              ),

              // --------------------------------------------------
              // FORMULAIRE
              // --------------------------------------------------

              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: _buildLoginForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ILLUSTRATION MOBILE
  // ============================================================

  Widget _buildHeader() {
    return AspectRatio(
      aspectRatio: 996 / 790,
      child: Image.asset(
        'assets/images/login_header_recettescarnet.png',
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 60,
              color: gray,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ILLUSTRATION GRAND ÉCRAN
  // ============================================================

  Widget _buildLargeHeader() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      child: Image.asset(
        'assets/images/login_header_recettescarnet.png',
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 80,
              color: gray,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FORMULAIRE
  // ============================================================

  Widget _buildLoginForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 700,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          // ------------------------------------------------------
          // TITRE
          // ------------------------------------------------------

          _buildTitle(),

          const SizedBox(height: 24),

          // ------------------------------------------------------
          // NOM D'UTILISATEUR
          // ------------------------------------------------------

          _buildUsernameField(),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // MOT DE PASSE
          // ------------------------------------------------------

          _buildPasswordField(),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // OPTIONS
          // ------------------------------------------------------

          _buildAccountOptions(),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // CONNEXION
          // ------------------------------------------------------

          _buildLoginButton(),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // SEPARATEUR
          // ------------------------------------------------------

          _buildOrDivider(),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // GOOGLE
          // ------------------------------------------------------

          _buildGoogleButton(),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // CREATION DE COMPTE
          // ------------------------------------------------------

          _buildRegisterLink(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============================================================
  // TITRE
  // ============================================================

  Widget _buildTitle() {
    return const Text(
      'Connectez-vous pour accéder à vos recettes',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: deepNavy,
        height: 1.2,
      ),
    );
  }

  // ============================================================
  // NOM D'UTILISATEUR
  // ============================================================

  Widget _buildUsernameField() {
    return SizedBox(
      height: controlHeight,
      child: TextField(
        controller: _usernameController,

        // Le nom d'utilisateur est du texte classique.
        keyboardType: TextInputType.text,

        textInputAction: TextInputAction.next,

        style: const TextStyle(
          fontSize: 16,
          color: dark,
        ),

        decoration: InputDecoration(
          hintText: 'Nom d’utilisateur',

          hintStyle: const TextStyle(
            color: gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.person_outline,
            size: 23,
            color: blueGray,
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
              color: lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOT DE PASSE
  // ============================================================

  Widget _buildPasswordField() {
    return SizedBox(
      height: controlHeight,
      child: TextField(
        controller: _passwordController,

        obscureText: _obscurePassword,

        textInputAction: TextInputAction.done,

        style: const TextStyle(
          fontSize: 16,
          color: dark,
        ),

        decoration: InputDecoration(
          hintText: 'Mot de passe',

          hintStyle: const TextStyle(
            color: gray,
            fontSize: 16,
          ),

          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 23,
            color: blueGray,
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
              color: blueGray,
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
              color: lightGray,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
            borderSide: const BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPTIONS DU COMPTE
  // ============================================================

  Widget _buildAccountOptions() {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildRememberMe(),
          ),
        ),

        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _buildForgotPassword(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SE SOUVENIR DE MOI
  // ============================================================

  Widget _buildRememberMe() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          _rememberMe = !_rememberMe;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: _rememberMe,
              activeColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  _rememberMe =
                      value ?? false;
                });
              },
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            'Se souvenir de moi',
            style: TextStyle(
              fontSize: 14,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOT DE PASSE OUBLIE
  // ============================================================

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: _forgotPassword,

      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        minimumSize: const Size(0, 32),
        tapTargetSize:
        MaterialTapTargetSize.padded,
      ),

      child: const Text(
        'Mot de passe oublié ?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }

  // ============================================================
  // BOUTON SE CONNECTER
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      height: controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              primaryDark,
              Color(0xFF42A5F5),
            ],
          ),

          borderRadius: BorderRadius.circular(
            controlRadius,
          ),

          boxShadow: [
            BoxShadow(
              color: primary.withValues(
                alpha: 0.20,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: ElevatedButton(
          onPressed: _login,

          style: ElevatedButton.styleFrom(
            backgroundColor:
            Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                controlRadius,
              ),
            ),

            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
            ),
          ),

          child: Row(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEPARATEUR OU
  // ============================================================

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: lightGray,
            thickness: 1,
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Text(
            'OU',
            style: TextStyle(
              color: gray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Expanded(
          child: Divider(
            color: lightGray,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOUTON GOOGLE
  // ============================================================

  Widget _buildGoogleButton() {
    return SizedBox(
      height: controlHeight,
      child: OutlinedButton(
        onPressed: _continueWithGoogle,

        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: dark,

          side: const BorderSide(
            color: lightGray,
            width: 1.2,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              controlRadius,
            ),
          ),

          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',

              width: 22,
              height: 22,

              fit: BoxFit.contain,

              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Icon(
                  Icons.account_circle_outlined,
                  size: 22,
                  color: blueGray,
                );
              },
            ),

            const SizedBox(width: 10),

            const Text(
              'Continuer avec Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREER UN COMPTE
  // ============================================================

  Widget _buildRegisterLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment:
      WrapCrossAlignment.center,
      children: [
        const Text(
          'Vous n’avez pas encore de compte ? ',
          style: TextStyle(
            fontSize: 14,
            color: gray,
          ),
        ),

        TextButton(
          onPressed: _createAccount,

          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
          ),

          child: const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION : CONNEXION
  // ============================================================

  Future<void> _login() async  {
    final String username =
    _usernameController.text.trim();

    final String password =
    _passwordController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (username.isEmpty ||
        password.isEmpty) {
      _showMessage(
        'Veuillez renseigner votre nom d’utilisateur et votre mot de passe.',
      );

      return;
    }

    // ----------------------------------------------------------
    // COMPTE DE DÉMONSTRATION LOCAL
    // ----------------------------------------------------------
    //
    // Pour le moment, Firebase n'est volontairement
    // pas utilisé.
    //
    // Le compte de démonstration est :
    //
    // Nom d'utilisateur : admin
    // Mot de passe       : admin123
    //
    // Cette partie sera remplacée plus tard par notre
    // authentification réelle.
    // ----------------------------------------------------------

    if (username == 'admin' &&
        password == 'admin123') {
      // Recherche de l'utilisateur dans SQLite.
      final userId =
      await DatabaseService.instance
          .getUserIdByUsername(username);
      if (!mounted) {
        return;
      }

      // Sécurité : l'utilisateur doit réellement
      // exister dans la base de données.
      if (userId == null) {
        _showMessage(
          'Utilisateur introuvable dans la base de données.',
        );
        return;
      }

      // On mémorise maintenant l'ID réel récupéré
      // depuis SQLite.
      // UserSession.instance.setUser(userId);
      UserSession.instance.setUser(
        userId: userId,
        username: username,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // IDENTIFIANTS INCORRECTS
    // ----------------------------------------------------------

    _showMessage(
      'Nom d’utilisateur ou mot de passe incorrect.',
    );
  }

  // ============================================================
  // ACTION : GOOGLE
  // ============================================================

  void _continueWithGoogle() {
    // Firebase Google Authentication sera branché
    // ultérieurement.
    _showMessage(
      'La connexion avec Google sera disponible prochainement.',
    );
  }

  // ============================================================
  // ACTION : MOT DE PASSE OUBLIE
  // ============================================================

  void _forgotPassword() {
    _showMessage(
      'La récupération du mot de passe sera disponible prochainement.',
    );
  }

  // ============================================================
  // ACTION : CREER UN COMPTE
  // ============================================================

  void _createAccount() {
    _showMessage(
      'La page de création de compte sera disponible prochainement.',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
      );
  }
}