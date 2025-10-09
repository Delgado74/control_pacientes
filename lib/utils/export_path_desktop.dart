import 'package:file_picker/file_picker.dart';

Future<String?> getExportPathDesktop() async {
  String? selectedDir = await FilePicker.platform.getDirectoryPath();
  if (selectedDir == null) return null; // Usuario canceló
  return '$selectedDir/ControlPacientesDB.db';
}
