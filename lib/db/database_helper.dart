import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const _dbName = 'pacientes.db';
  static const _dbVersion = 4;

  static const List<String> gruposEdad = [
    '0-4',
    '5-9',
    '10-14',
    '15-19',
    '20-24',
    '25-29',
    '30-34',
    '35-39',
    '40-44',
    '45-49',
    '50-54',
    '55-59',
    '60-64',
    '65-69',
    '70-74',
    '75-79',
    '80-84',
    '85+'
  ];

  static String _generarCaseEdad() {
    final cases = <String>[];
    for (var i = 0; i < gruposEdad.length - 1; i++) {
      final parts = gruposEdad[i].split('-');
      cases.add(
          "WHEN edad BETWEEN ${parts[0]} AND ${parts[1]} THEN '${gruposEdad[i]}'");
    }
    cases.add("ELSE '${gruposEdad.last}'");
    return cases.join('\n');
  }

  static Map<String, int> _inicializarConteoEdad() {
    final map = <String, int>{};
    for (var g in gruposEdad) {
      map[g] = 0;
    }
    map['TOTAL'] = 0;
    return map;
  }

  static Map<String, int> _inicializarConteoEdadSexo() {
    final map = <String, int>{};
    for (var g in gruposEdad) {
      map['$g M'] = 0;
      map['$g F'] = 0;
    }
    map['TOTAL'] = 0;
    return map;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pacientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provincia TEXT,
        municipio TEXT,
        policlinico TEXT,
        consultorio TEXT,
        cdr TEXT,
        numeroCasa TEXT,
        nombre TEXT,
        carnet_identidad TEXT,
        sexo TEXT,
        fecha_nac TEXT,
        edad INTEGER,
        grupo_disp TEXT,
        escolaridad TEXT,
        ocupacion TEXT,
        color_piel TEXT,
        factor_riesgo TEXT,
        riesgo_preconcepcional TEXT,
        control_rpc TEXT,
        embarazada TEXT,
        enfermedades TEXT,
        discapacidades TEXT,
        control TEXT,
        leptospirosis INTEGER,
        alcohol INTEGER,
        drogar INTEGER,
        its INTEGER,
        tb INTEGER,
        sedentarismo INTEGER,
        donantes INTEGER,
        social INTEGER,
        otro INTEGER,
        hta INTEGER,
        dm INTEGER,
        hlp INTEGER,
        ab INTEGER,
        ecv INTEGER,
        sci INTEGER,
        cancer INTEGER,
        epoc INTEGER,
        sida INTEGER,
        fumador INTEGER,
        obeso INTEGER,
        alcoholico INTEGER,
        erc INTEGER,
        autismo INTEGER,
        cirrosis INTEGER,
        droga INTEGER,
        otra INTEGER,
        visual INTEGER,
        auditiva INTEGER,
        fisica INTEGER,
        sordociego INTEGER,
        lvh INTEGER,
        intelectual INTEGER,
        mixto INTEGER,
        sensitiva INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE familias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provincia TEXT,
        municipio TEXT,
        policlinico TEXT,
        consultorio TEXT,
        cdr TEXT,
        calle TEXT,
        numeroCasa TEXT,
        tipo_familia TEXT,
        funcionalidad TEXT,
        integrantes TEXT,
        habitaciones TEXT,
        animales_domesticos TEXT,
        vectores TEXT,
        techo TEXT,
        paredes TEXT,
        piso TEXT,
        equipamiento TEXT,
        condiciones_economicas TEXT,
        condiciones_higienicas TEXT,
        abasto_agua TEXT,
        residuales_liquidos TEXT,
        residuales_solidos TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE localizaciones(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provincia TEXT,
        municipio TEXT,
        policlinico TEXT,
        consultorio TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db
          .execute('ALTER TABLE pacientes ADD COLUMN carnet_identidad TEXT');
    }
  }

  // ================= PACIENTES =================
  Future<int> insertarPaciente(Map<String, dynamic> paciente) async {
    final db = await database;
    final locs = await db.query('localizaciones', orderBy: 'id DESC', limit: 1);
    if (locs.isNotEmpty) {
      paciente['provincia'] = locs.first['provincia'];
      paciente['municipio'] = locs.first['municipio'];
      paciente['policlinico'] = locs.first['policlinico'];
      paciente['consultorio'] = locs.first['consultorio'];
    }
    return await db.insert('pacientes', paciente);
  }

  Future<int> insertarPacienteDirecto(Map<String, dynamic> paciente) async {
    final db = await database;
    return await db.insert('pacientes', paciente);
  }

  Future<List<Map<String, dynamic>>> obtenerPacientes() async {
    final db = await database;
    return await db.query('pacientes');
  }

  Future<List<Map<String, dynamic>>> obtenerPacientesFiltrados(
      String where, List<dynamic> args) async {
    final db = await database;
    return await db.query('pacientes', where: where, whereArgs: args);
  }

  Future<int> actualizarPaciente(int id, Map<String, dynamic> paciente) async {
    final db = await database;
    return await db
        .update('pacientes', paciente, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> eliminarPaciente(int id) async {
    final db = await database;
    return await db.delete('pacientes', where: 'id = ?', whereArgs: [id]);
  }

  // ================= RESUMEN PACIENTES =================
  Future<Map<String, int>> contarPorEdad() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        CASE
          ${_generarCaseEdad()}
        END as grupo_edad,
        COUNT(*) as total
      FROM pacientes
      GROUP BY grupo_edad
    ''');

    Map<String, int> conteo = _inicializarConteoEdad();

    for (var row in result) {
      final grupo = row['grupo_edad'] as String;
      final total = row['total'] as int;
      conteo[grupo] = total;
      conteo['TOTAL'] = conteo['TOTAL']! + total;
    }

    return conteo;
  }

  Future<Map<String, int>> contarPorEdadSexo() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        CASE
          ${_generarCaseEdad()}
        END as grupo_edad,
        sexo,
        COUNT(*) as total
      FROM pacientes
      GROUP BY grupo_edad, sexo
    ''');

    Map<String, int> conteo = _inicializarConteoEdadSexo();

    for (var row in result) {
      final grupo = row['grupo_edad'] as String;
      final sexo = row['sexo'] as String? ?? '';
      final total = row['total'] as int;
      final key = '$grupo ${sexo == 'Masculino' ? 'M' : 'F'}';
      if (conteo.containsKey(key)) {
        conteo[key] = total;
      }
      conteo['TOTAL'] = conteo['TOTAL']! + total;
    }

    return conteo;
  }

  Future<Map<String, int>> contarPorCampo(String campo) async {
    final db = await database;

    if (campo == 'embarazada') {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as total
        FROM pacientes
        WHERE embarazada = 'Sí'
      ''');
      int total = result.first['total'] as int? ?? 0;
      return {'Embarazada': total};
    }

    final result = await db.rawQuery('''
      SELECT $campo as valor, COUNT(*) as total
      FROM pacientes
      GROUP BY $campo
    ''');

    Map<String, int> conteo = {'TOTAL': 0};
    for (var row in result) {
      String valor = row['valor']?.toString() ?? 'N/A';
      if (valor.isEmpty || valor == 'N/A') continue;

      int total = row['total'] as int;

      if (campo == 'riesgo_preconcepcional') {
        if (valor == 'Ninguno') continue;
        conteo[valor] = total;
        conteo['TOTAL'] = conteo['TOTAL']! + total;
      } else if (campo == 'control_rpc') {
        if (valor == 'Ninguno') continue;
        conteo[valor] = total;
        conteo['TOTAL'] = conteo['TOTAL']! + total;
      } else {
        conteo[valor] = total;
        conteo['TOTAL'] = conteo['TOTAL']! + total;
      }
    }
    return conteo;
  }

  Future<Map<String, int>> contarPorFlags(List<String> campos) async {
    final db = await database;
    Map<String, int> conteo = {'TOTAL': 0};

    for (var campo in campos) {
      final result =
          await db.rawQuery('SELECT SUM($campo) as total FROM pacientes');
      final total = result.first['total'] as int? ?? 0;
      conteo[campo] = total;
      conteo['TOTAL'] = conteo['TOTAL']! + total;
    }
    return conteo;
  }

  // ================= FAMILIAS =================
  Future<int> insertarFamilia(Map<String, dynamic> familia) async {
    final db = await database;
    final locs = await db.query('localizaciones', orderBy: 'id DESC', limit: 1);
    if (locs.isNotEmpty) {
      familia['provincia'] = locs.first['provincia'];
      familia['municipio'] = locs.first['municipio'];
      familia['policlinico'] = locs.first['policlinico'];
      familia['consultorio'] = locs.first['consultorio'];
    }
    return await db.insert('familias', familia);
  }

  Future<int> insertarFamiliaDirecto(Map<String, dynamic> familia) async {
    final db = await database;
    return await db.insert('familias', familia);
  }

  Future<List<Map<String, dynamic>>> obtenerFamilias() async {
    final db = await database;
    return await db.query('familias');
  }

  Future<int> actualizarFamilia(int id, Map<String, dynamic> familia) async {
    final db = await database;
    return await db
        .update('familias', familia, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> eliminarFamilia(int id) async {
    final db = await database;
    return await db.delete('familias', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> contarFamiliasPorCampo(String campo) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT $campo as valor, COUNT(*) as total
      FROM familias
      GROUP BY $campo
    ''');

    Map<String, int> conteo = {'TOTAL': 0};
    for (var row in result) {
      final valor = row['valor']?.toString() ?? 'N/A';
      final total = row['total'] as int;
      conteo[valor] = total;
      conteo['TOTAL'] = conteo['TOTAL']! + total;
    }
    return conteo;
  }

  // ================= LOCALIZACIONES =================
  Future<int> insertarLocalizacion(Map<String, dynamic> localizacion) async {
    final db = await database;
    return await db.insert('localizaciones', localizacion);
  }

  Future<List<Map<String, dynamic>>> obtenerLocalizaciones() async {
    final db = await database;
    return await db.query('localizaciones');
  }

  Future<int> actualizarLocalizacion(
      int id, Map<String, dynamic> localizacion) async {
    final db = await database;
    return await db.update('localizaciones', localizacion,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> eliminarLocalizacion(int id) async {
    final db = await database;
    return await db.delete('localizaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ================= EXPORT / IMPORT =================
  Future<String> get dbPath async {
    final dbDirectory = await getDatabasesPath();
    return join(dbDirectory, _dbName);
  }

  Future<File?> exportDatabase() async {
    try {
      final path = await dbPath;
      final file = File(path);

      if (!await file.exists()) return null;

      final exportDir = Platform.isAndroid || Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory.current;

      final exportPath = join(exportDir.path, 'exported_$_dbName');
      final exportedFile = await file.copy(exportPath);

      return exportedFile;
    } catch (e) {
      return null;
    }
  }

  Future<bool> importDatabase(File file) async {
    try {
      if (!await file.exists()) return false;

      final path = await dbPath;
      await file.copy(path);
      _database = await _initDb();

      return true;
    } catch (e) {
      return false;
    }
  }

  // ================= CERRAR DB =================
  Future<void> closeDB() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
