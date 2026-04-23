import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/theme/app_theme.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/navigation/app_router.dart';
import 'package:sfmc_flutter/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const SFMCApp());
}

class SFMCApp extends StatelessWidget {
  const SFMCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Ajoutez ici les autres providers si nécessaire (ex: ThemeProvider)
      ],
      child: MaterialApp.router(
        title: 'SFMC Bénin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
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
