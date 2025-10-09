import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';

final dbHelper = DatabaseHelper.instance;

/// Columnas fijas
final columnasLocalizacion = ['provincia', 'municipio', 'policlinico', 'consultorio'];
final columnasPacientes = [
  ...columnasLocalizacion,
  'id','nombre','sexo','fecha_nac','edad','grupo_disp','escolaridad','ocupacion','color_piel',
  'factor_riesgo','riesgo_preconcepcional','embarazada','enfermedades','discapacidades','leptospirosis',
  'alcohol','droga','its','preconcepcional','social','otro','hta','dm','ab','ecv','sci','cancer','epoc',
  'sida','fumador','obeso','alcoholico','erc','otra','visual','auditiva','fisica','intelectual'
];
final columnasFamilias = [
  ...columnasLocalizacion,
  'id','cdr','calle','numero_casa','tipo_familia','funcionalidad','integrantes','habitaciones',
  'animales_domesticos','vectores','techo','paredes','piso','equipamiento','condiciones_economicas',
  'condiciones_higienicas','abasto_agua','residuales_liquidos','residuales_solidos'
];

/// ---------------- EXPORTAR ----------------
Future<String?> exportarExcel() async {
  final excel = Excel.createExcel();

  // Localizaciones
  final sheetLoc = excel['Localizaciones'];
  final localizaciones = await dbHelper.obtenerLocalizaciones();
  sheetLoc.appendRow(columnasLocalizacion);
  for (var loc in localizaciones) {
    sheetLoc.appendRow(columnasLocalizacion.map((c) => loc[c] ?? '').toList());
  }

  // Pacientes
  final sheetPac = excel['Pacientes'];
  final pacientes = await dbHelper.obtenerPacientes();
  sheetPac.appendRow(columnasPacientes);
  for (var p in pacientes) {
    sheetPac.appendRow(columnasPacientes.map((c) => p[c] ?? '').toList());
  }

  // Familias
  final sheetFam = excel['Familias'];
  final familias = await dbHelper.obtenerFamilias();
  sheetFam.appendRow(columnasFamilias);
  for (var f in familias) {
    sheetFam.appendRow(columnasFamilias.map((c) => f[c] ?? '').toList());
  }

  // Guardar
  final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  final path = "${directory.path}/Exportacion_ASIS.xlsx";

  final fileBytes = excel.encode();
  if (fileBytes != null) {
    final file = File(path);
    if (await file.exists()) await file.delete(); // sobrescribir siempre
    await file.writeAsBytes(fileBytes);
    return path;
  }

  return null;
}
