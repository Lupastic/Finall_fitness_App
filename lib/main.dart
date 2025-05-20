// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Firebase ───────────────────────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ─── Локализация ────────────────────────────────────────────────────────────────
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ─── SharedPreferences ─────────────────────────────────────────────────────────
import 'package:shared_preferences/shared_preferences.dart';

// ─── Hive ───────────────────────────────────────────────────────────────────────
import 'package:hive_flutter/hive_flutter.dart';
import 'models/daily_summary.dart';

// ─── Ваши провайдеры ────────────────────────────────────────────────────────────
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/google_sign_in_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/summary_provider.dart';

// ─── Сервисы / репозитории ─────────────────────────────────────────────────────
import 'services/settings_repository.dart';
import 'services/local_repository.dart';
import 'services/sync_service.dart';

// ─── Экраны ─────────────────────────────────────────────────────────────────────
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Hive (локальное хранилище)
  await Hive.initFlutter();
  Hive.registerAdapter(DailySummaryAdapter());

  // 3. Репозиторий локальных данных
  final localRepo = LocalRepository();
  await localRepo.init();

  // 4. Сервис синхронизации (Firebase ⇄ Hive)
  final syncService = SyncService(localRepo);

  // 5. SharedPreferences для настроек
  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);

  // 6. Запуск приложения с провайдерами
  runApp(
    MultiProvider(
      providers: [
        // UI‑слой
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        // Аутентификация / настройки
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsRepo)),

        // Сеть
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(syncService),
        ),


        // Данные дня
        ChangeNotifierProvider(create: (_) => SummaryProvider(localRepo)),

        // Сервис синхронизации — обычный Provider
        Provider<SyncService>.value(value: syncService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider  = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App UI',

      // темы
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1F1F1F),
        primaryColor: Colors.tealAccent,
      ),

      // локализация
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // стартовый экран
      home: const AuthGate(),
    );
  }
}
