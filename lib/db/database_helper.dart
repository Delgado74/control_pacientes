import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const _dbName = 'pacientes.db';

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
      version: 3, // Incrementa la versión si modificas la tabla
      onCreate: _onCreate,
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

  Future<List<Map<String, dynamic>>> obtenerPacientesFiltrados(String where, List<dynamic> args) async {
    final db = await database;
    return await db.query('pacientes', where: where, whereArgs: args);
  }

  Future<int> actualizarPaciente(int id, Map<String, dynamic> paciente) async {
    final db = await database;
    return await db.update('pacientes', paciente, where: 'id = ?', whereArgs: [id]);
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
          WHEN edad BETWEEN 0 AND 4 THEN '0-4'
          WHEN edad BETWEEN 5 AND 9 THEN '5-9'
          WHEN edad BETWEEN 10 AND 14 THEN '10-14'
          WHEN edad BETWEEN 15 AND 19 THEN '15-19'
          WHEN edad BETWEEN 20 AND 24 THEN '20-24'
          WHEN edad BETWEEN 25 AND 29 THEN '25-29'
          WHEN edad BETWEEN 30 AND 34 THEN '30-34'
          WHEN edad BETWEEN 35 AND 39 THEN '35-39'
          WHEN edad BETWEEN 40 AND 44 THEN '40-44'
          WHEN edad BETWEEN 45 AND 49 THEN '45-49'
          WHEN edad BETWEEN 50 AND 54 THEN '50-54'
          WHEN edad BETWEEN 55 AND 59 THEN '55-59'
          WHEN edad BETWEEN 60 AND 64 THEN '60-64'
          WHEN edad BETWEEN 65 AND 69 THEN '65-69'
          WHEN edad BETWEEN 70 AND 74 THEN '70-74'
          WHEN edad BETWEEN 75 AND 79 THEN '75-79'
          WHEN edad BETWEEN 80 AND 84 THEN '80-84'
          ELSE '85+' 
        END as grupo_edad,
        COUNT(*) as total
      FROM pacientes
      GROUP BY grupo_edad
    ''');

    Map<String, int> conteo = {
      '0-4': 0, '5-9': 0, '10-14': 0, '15-19': 0, '20-24': 0,
      '25-29': 0, '30-34': 0, '35-39': 0, '40-44': 0, '45-49': 0,
      '50-54': 0, '55-59': 0, '60-64': 0, '65-69': 0, '70-74': 0,
      '75-79': 0, '80-84': 0, '85+': 0, 'TOTAL': 0,
    };

    for (var row in result) {
      final grupo = row['grupo_edad'] as String;
      final total = row['total'] as int;
      conteo[grupo] = total;
      conteo['TOTAL'] = conteo['TOTAL']! + total;
    }

    return conteo;
  }

  // Conteo general por campo
  Future<Map<String, int>> contarPorCampo(String campo) async {
    final db = await database;

    if (campo == 'embarazada') {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as total
        FROM pacientes
        WHERE embarazada = 'Sí'
      ''');
      int total = result.first['total'] as int? ?? 0;
      return {'SI': total};
    }

    if (campo == 'factor_riesgo' || campo == 'enfermedades' || campo == 'discapacidades') {
      final result = await db.rawQuery('''
        SELECT $campo as valor, COUNT(*) as total
        FROM pacientes
        GROUP BY $campo
      ''');

      Map<String, int> conteo = {};
      for (var row in result) {
        final valor = row['valor']?.toString() ?? 'N/A';
        final total = row['total'] as int;
        conteo[valor] = total;
      }
      return conteo;
    }

    final result = await db.rawQuery('''
      SELECT $campo as valor, COUNT(*) as total
      FROM pacientes
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

  // Conteo por flags (riesgo, enfermedad, discapacidad)
  Future<Map<String, int>> contarPorFlags(List<String> campos) async {
    final db = await database;
    Map<String, int> conteo = {'TOTAL': 0};

    for (var campo in campos) {
      final result = await db.rawQuery('SELECT SUM($campo) as total FROM pacientes');
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
    return await db.update('familias', familia, where: 'id = ?', whereArgs: [id]);
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

  Future<int> actualizarLocalizacion(int id, Map<String, dynamic> localizacion) async {
    final db = await database;
    return await db.update('localizaciones', localizacion, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> eliminarLocalizacion(int id) async {
    final db = await database;
    return await db.delete('localizaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== NUEVO ====================
  Future<String> get dbPath async {
    final dbDirectory = await getDatabasesPath();
    return join(dbDirectory, _dbName);
  }

  Future<void> closeDB() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
