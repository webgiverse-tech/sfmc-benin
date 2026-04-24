// lib/main.dart — SFMC Bénin · BUG FIX #5a
// Correction : pré-chargement des fonts AVANT runApp() pour éviter
// les violations setTimeout liées au FOUT (Flash of Unstyled Text)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:sfmc_flutter/core/theme/app_theme.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/navigation/app_router.dart';
import 'package:sfmc_flutter/services/storage_service.dart';

void main() async {
  // Indispensable avant tout appel async dans main()
  WidgetsFlutterBinding.ensureInitialized();

  // ── BUG FIX #5a : Initialisation des services de base ──────────────────────
  // StorageService doit être initialisé avant runApp pour éviter
  // les appels async bloquants pendant le premier build()
  await StorageService.init();

  // ── BUG FIX #5b : Pré-chargement des polices Google Fonts ──────────────────
  // Sans ce pré-chargement, Flutter Web télécharge et applique les fonts
  // PENDANT le rendu → provoque les violations setTimeout de 900ms+
  // On ne le fait qu'en release/profile (en debug, google_fonts utilise
  // le cache local automatiquement)
  if (!kDebugMode) {
    await GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.poppins(fontWeight: FontWeight.w600),
      GoogleFonts.poppins(fontWeight: FontWeight.w700),
      GoogleFonts.roboto(),
      GoogleFonts.roboto(fontWeight: FontWeight.w500),
    ]);
  } else {
    // En mode debug : chargement silencieux sans attendre
    // pour conserver la vitesse de hot-reload
    GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.roboto(),
    ]).ignore();
  }

  runApp(const SFMCApp());
}

// ── Application principale ──────────────────────────────────────────────────
class SFMCApp extends StatelessWidget {
  const SFMCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'SFMC Bénin',
        debugShowCheckedModeBanner: false,

        // ── BUG FIX #5c : Thème avec textTheme pré-résolu ──────────────────
        // Ne PAS appeler GoogleFonts.poppinsTextTheme() ici directement :
        // cela crée un nouveau TextTheme à chaque rebuild du MaterialApp.
        // On utilise le thème défini dans AppTheme qui met le textTheme en cache.
        theme: AppTheme.lightTheme,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR')],
        locale: const Locale('fr', 'FR'),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
