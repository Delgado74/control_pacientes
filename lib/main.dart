import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'db/database_helper.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF26A69A);
  static const Color tertiary = Color(0xFFFF8F00);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color error = Color(0xFFE53935);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de SQLite según la plataforma
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicializar base de datos
  await DatabaseHelper().database;

  runApp(const MedicalFamilyCareApp());
}

class MedicalFamilyCareApp extends StatelessWidget {
  const MedicalFamilyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Family Care (MFC)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surface,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.tertiary,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const BienvenidaScreen(),
    );
  }
}
