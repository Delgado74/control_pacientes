import 'package:flutter/material.dart';
import 'localizacion_screen.dart';
import 'paciente_screen.dart';
import 'familia_screen.dart';
import 'resumen_pacientes_screen.dart';
import 'resumen_familias_screen.dart';
import 'acerca_de_screen.dart';
import '../db/database_helper.dart';
import '../utils/db_export_import.dart'; // Importar DBExportImport
import 'package:control_pacientes/utils/excel_export.dart';

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});

  @override
  State<MenuPrincipalScreen> createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  final List<Color> _buttonColors = const [
    Colors.blue,   // Localización
    Colors.green,  // Pacientes
    Colors.orange, // Familias
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú Principal")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Opciones",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text("Resumen de Pacientes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResumenPacientesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: const Text("Resumen de Familias"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResumenFamiliasScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Exportar a Excel"),
              onTap: () async {
                Navigator.pop(context);
                final pacientes = await DatabaseHelper.instance.obtenerPacientes();
                final familias = await DatabaseHelper.instance.obtenerFamilias();
                final localizaciones = await DatabaseHelper.instance.obtenerLocalizaciones();

                await generarYCompartirExcel(
                  pacientes: pacientes,
                  familias: familias,
                  localizaciones: localizaciones,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Exportar Base de Datos"),
              onTap: () async {
                Navigator.pop(context);
                await DBExportImport.exportarDB(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text("Importar Base de Datos"),
              onTap: () async {
                Navigator.pop(context);
                await DBExportImport.importarDB(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Acerca de"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AcercaDeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(
              label: "Localización",
              color: _buttonColors[0],
              icon: Icons.gps_fixed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocalizacionScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _menuButton(
              label: "Pacientes",
              color: _buttonColors[1],
              icon: Icons.monitor_heart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PacienteScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _menuButton(
              label: "Familias",
              color: _buttonColors[2],
              icon: Icons.home_filled,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamiliaScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(200), color.withAlpha(255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(128),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
