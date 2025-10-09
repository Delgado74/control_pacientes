import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'db/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el soporte de FFI solo si es escritorio
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  // Inicializar base de datos
  await DatabaseHelper().database;

  runApp(ControlPacientesApp());
}

class ControlPacientesApp extends StatelessWidget {
  const ControlPacientesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Pacientes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BienvenidaScreen(), // Ojo: se llama BienvenidaScreen
    );
  }
}
