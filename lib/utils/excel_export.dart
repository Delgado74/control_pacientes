import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Genera un archivo Excel con las tablas de pacientes, familias y localizaciones
/// y abre el menú de compartir (WhatsApp, email, etc.)
Future<void> generarYCompartirExcel({
  required List<Map<String, dynamic>> pacientes,
  required List<Map<String, dynamic>> familias,
  required List<Map<String, dynamic>> localizaciones,
}) async {
  final excel = Excel.createExcel();

  // --- Localizaciones ---
  final Sheet sheetLoc = excel['Localizaciones'];
  if (localizaciones.isNotEmpty) {
    sheetLoc.appendRow(localizaciones.first.keys.toList());
    for (var loc in localizaciones) {
      sheetLoc.appendRow(loc.values.toList());
    }
  }

  // --- Pacientes ---
  final Sheet sheetPac = excel['Pacientes'];
  if (pacientes.isNotEmpty) {
    sheetPac.appendRow(pacientes.first.keys.toList());
    for (var p in pacientes) {
      sheetPac.appendRow(p.values.toList());
    }
  }

  // --- Familias ---
  final Sheet sheetFam = excel['Familias'];
  if (familias.isNotEmpty) {
    sheetFam.appendRow(familias.first.keys.toList());
    for (var f in familias) {
      sheetFam.appendRow(f.values.toList());
    }
  }

  // --- Guardar archivo ---
  final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  final path = "${directory.path}/Exportacion_ASIS.xlsx";
  final fileBytes = excel.encode();

  if (fileBytes != null) {
    final file = File(path);
    await file.writeAsBytes(fileBytes);

    // Abrir menú de compartir
    await Share.shareXFiles([XFile(file.path)], text: 'Exportación ASIS en Excel');
  }
}