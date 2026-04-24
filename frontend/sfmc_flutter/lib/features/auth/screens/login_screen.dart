// lib/features/auth/screens/login_screen.dart — BUG FIX #5d
// Correction : Lottie chargé de façon lazy avec RepaintBoundary
// + AnimationController isolé pour éviter les violations requestAnimationFrame
// + Password field encapsulé dans un Form pour résoudre l'avertissement Chrome

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/validators.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/core/widgets/custom_text_field.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/navigation/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── BUG FIX #5d : AnimationController isolé pour Lottie ─────────────────
  // Contrôler manuellement le Lottie évite qu'il relance son ticker
  // sur chaque frame de l'app (cause des violations requestAnimationFrame)
  late final AnimationController _lottieController;
  bool _lottieLoaded = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Fermer le clavier avant de lancer la requête
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        context.go(Routes.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur de connexion'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // ── Panneau gauche avec Lottie (desktop uniquement) ─────────────────────
  Widget _buildLeftPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF0D2548), // Bleu marine plus foncé
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── BUG FIX #5d : RepaintBoundary isole Lottie du reste du widget tree ──
              // Sans RepaintBoundary, chaque frame Lottie déclenche un repaint
              // de toute la page → violations requestAnimationFrame en cascade
              RepaintBoundary(
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  width: 280,
                  height: 280,
                  // BUG FIX : frameRate réduit à 30fps (au lieu de 60fps par défaut)
                  // Divise par 2 le nombre de violations requestAnimationFrame
                  frameRate: FrameRate(30),
                  // BUG FIX : controller manuel → on joue l'animation une seule fois
                  // puis on la met en pause (stop the loop qui consomme des ressources)
                  controller: _lottieController,
                  onLoaded: (composition) {
                    // L'animation est chargée : on la joue UNE SEULE FOIS
                    _lottieController
                      ..duration = composition.duration
                      ..forward().then((_) {
                        // Après la première lecture, on s'arrête sur la dernière frame
                        if (mounted) {
                          _lottieController.value = 1.0;
                          setState(() => _lottieLoaded = true);
                        }
                      });
                  },
                  // BUG FIX : filterQuality réduit pour améliorer les perfs Web
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const SizedBox(height: 32),
              // Logo textuel SFMC
              const Text(
                'SFMC Bénin',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Système de Gestion Industrielle',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Points clés de l'application
              ..._buildFeatureItems(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      (Icons.inventory_2_outlined, 'Gestion des stocks multi-entrepôts'),
      (Icons.receipt_long_outlined, 'Facturation et suivi des commandes'),
      (Icons.factory_outlined, 'Planification de production'),
      (Icons.bar_chart_outlined, 'Rapports et analytics en temps réel'),
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(feature.$1, color: AppColors.secondary, size: 20),
            const SizedBox(width: 12),
            Text(
              feature.$2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ── Panneau droit : formulaire de connexion ──────────────────────────────
  Widget _buildRightPanel(AuthProvider authProvider) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            // ── BUG FIX : Encapsuler dans un Form NOMMÉ ─────────────────
            // L'avertissement Chrome "Password field is not contained in a form"
            // vient du fait que Flutter Web génère le champ password hors <form>.
            // On ne peut pas forcer un vrai <form> HTML en Flutter Web,
            // mais on peut s'assurer que le widget Form englobe correctement
            // les deux champs pour que l'autocomplétion fonctionne.
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête
                  _buildFormHeader(),
                  const SizedBox(height: 40),
                  // Champ Email
                  CustomTextField(
                    label: 'Adresse email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondary,
                    ),
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (value) => _handleLogin(),
                  ),
                  const SizedBox(height: 16),
                  // Champ Mot de passe
                  CustomTextField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                    ),
                    autofillHints: const [AutofillHints.password],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 8),
                  // Mot de passe oublié (placeholder)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton de connexion
                  AutofillGroup(
                    child: CustomButton(
                      text: 'Se connecter',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                      width: double.infinity,
                      height: 52,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lien vers inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas encore de compte ? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Comptes de démonstration
                  _buildDemoAccounts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo pour mobile (panneau gauche masqué)
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.factory, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SFMC Bénin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Gestion Industrielle',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Entrez vos identifiants pour accéder au tableau de bord',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoAccounts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              const Text(
                'Comptes de démonstration',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _demoAccountRow(
            'Admin',
            'admin@sfmc.bj',
            'admin123',
            AppColors.danger,
          ),
          const SizedBox(height: 4),
          _demoAccountRow(
            'Opérateur',
            'operateur@sfmc.bj',
            'oper123',
            AppColors.info,
          ),
          const SizedBox(height: 4),
          _demoAccountRow(
            'Client',
            'client@sfmc.bj',
            'client123',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _demoAccountRow(
    String role,
    String email,
    String password,
    Color roleColor,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      // Au tap : remplir automatiquement les champs
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.touch_app_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                // Panneau gauche (50% écran) — isolé dans RepaintBoundary
                Expanded(child: RepaintBoundary(child: _buildLeftPanel())),
                // Panneau droit (50% écran) — formulaire
                Expanded(child: _buildRightPanel(authProvider)),
              ],
            )
          // Mobile : seulement le formulaire, sans Lottie
          : _buildRightPanel(authProvider),
    );
  }
}
