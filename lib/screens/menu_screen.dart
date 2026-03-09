import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import 'localizacion_screen.dart';
import 'paciente_screen.dart';
import 'familia_screen.dart';
import 'resumen_pacientes_screen.dart';
import 'resumen_familias_screen.dart';
import 'acerca_de_screen.dart';
import '../db/database_helper.dart';
import '../utils/excel_export.dart';

class MenuOption {
  final String label;
  final String subtitle;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;

  const MenuOption({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.gradientColors,
    required this.icon,
  });
}

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});

  @override
  State<MenuPrincipalScreen> createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  final List<MenuOption> _menuOptions = const [
    MenuOption(
      label: "Localización",
      subtitle: "Configura tu área de trabajo",
      color: Color(0xFF1565C0),
      gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
      icon: Icons.location_on,
    ),
    MenuOption(
      label: "Pacientes",
      subtitle: "Registra y gestiona tus pacientes",
      color: Color(0xFF43A047),
      gradientColors: [Color(0xFF43A047), Color(0xFF66BB6A)],
      icon: Icons.people,
    ),
    MenuOption(
      label: "Familias",
      subtitle: "Control familiar integral",
      color: Color(0xFFFF8F00),
      gradientColors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
      icon: Icons.home,
    ),
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

        downloadsDir ??= Directory(
            path.join(Platform.environment['HOME'] ?? '.', 'Downloads'));

        if (!await downloadsDir.exists())
          await downloadsDir.create(recursive: true);

        final newFile = await file
            .copy(path.join(downloadsDir.path, path.basename(file.path)));
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
          content: const Text(
              'Esto reemplazará la base de datos actual. ¿Desea continuar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
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
      appBar: AppBar(
        title: const Text("Menú Principal"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Medical Family Care",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Gestión de Medicina Familiar",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people, color: AppColors.primary),
              ),
              title: const Text("Resumen de Pacientes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ResumenPacientesScreen()),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home, color: AppColors.secondary),
              ),
              title: const Text("Resumen de Familias"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ResumenFamiliasScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.file_download, color: AppColors.success),
              ),
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
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_file, color: AppColors.warning),
              ),
              title: const Text("Exportar Base de Datos"),
              onTap: () async {
                Navigator.pop(context);
                await _exportDatabase();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download, color: AppColors.tertiary),
              ),
              title: const Text("Importar Base de Datos"),
              onTap: () async {
                Navigator.pop(context);
                await _importDatabase();
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Colors.grey),
              ),
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
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Menú Principal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Selecciona una opción para continuar",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              _buildMenuCard(
                option: _menuOptions[0],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocalizacionScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuCard(
                option: _menuOptions[1],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PacienteScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuCard(
                option: _menuOptions[2],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamiliaScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required MenuOption option,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option.color.withAlpha(102),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withAlpha(178),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
