import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'localizacion_screen.dart';
import 'paciente_screen.dart';
import 'familia_screen.dart';
import 'resumen_pacientes_screen.dart';
import 'resumen_familias_screen.dart';
import 'acerca_de_screen.dart';
import '../db/database_helper.dart';
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

  final dbHelper = DatabaseHelper.instance;

  // ============================================================
  // 📥 IMPORTAR Y 💾 EXPORTAR BASE DE DATOS
  // ============================================================
  Future<void> _exportDatabase() async {
    try {
      final file = await dbHelper.exportDatabase();
      if (!mounted || file == null || file.path.isEmpty) return;

      String exportPath = file.path;

      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        Directory? downloadsDir;

        try {
          downloadsDir = await getDownloadsDirectory();
        } catch (_) {
          downloadsDir = null;
        }

        downloadsDir ??= Directory(path.join(Platform.environment['HOME'] ?? '.', 'Downloads'));

        if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);

        final newFile = await file.copy(path.join(downloadsDir.path, path.basename(file.path)));
        exportPath = newFile.path;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Base de datos exportada a: $exportPath')),
        );
      } else {
        await Share.shareXFiles([XFile(exportPath)],
            text: 'Base de datos de la aplicación');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar base de datos: $e')),
      );
    }
  }

  Future<void> _importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;

      final selectedFile = File(result.files.single.path!);

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar importación'),
          content: const Text('Esto reemplazará la base de datos actual. ¿Desea continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await dbHelper.importDatabase(selectedFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base de datos importada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar base de datos: $e')),
      );
    }
  }

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
                final pacientes = await dbHelper.obtenerPacientes();
                final familias = await dbHelper.obtenerFamilias();
                final localizaciones = await dbHelper.obtenerLocalizaciones();

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
                await _exportDatabase(); // 🔹 Aquí llamamos al método integrado
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text("Importar Base de Datos"),
              onTap: () async {
                Navigator.pop(context);
                await _importDatabase(); // 🔹 Aquí llamamos al método integrado
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
