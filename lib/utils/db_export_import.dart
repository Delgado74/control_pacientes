import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../db/database_helper.dart';
import 'export_path_desktop.dart'; // tu helper de escritorio

class DBExportImport {
  static Future<void> exportarDB(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final dbPath = await DatabaseHelper.instance.dbPath;
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        messenger.showSnackBar(
          const SnackBar(content: Text("No se encontró la base de datos")),
        );
        return;
      }

      String? exportPath;

      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        exportPath = join(dir.path, 'ControlPacientesDB.db');
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        exportPath = await getExportPathDesktop();
      }

      if (exportPath == null) return; // Usuario canceló

      await dbFile.copy(exportPath);

      messenger.showSnackBar(
        SnackBar(content: Text("Base de datos exportada en: $exportPath")),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Error al exportar DB: $e")),
      );
    }
  }

  static Future<void> importarDB(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) return;

      final selectedFile = File(result.files.single.path!);
      final dbPath = await DatabaseHelper.instance.dbPath;

      await DatabaseHelper.instance.closeDB();
      await selectedFile.copy(dbPath);

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Base de datos importada correctamente")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("Error al importar DB: $e")),
        );
      }
    }
  }
}
