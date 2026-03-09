import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class PacienteScreen extends StatefulWidget {
  const PacienteScreen({super.key});

  @override
  State<PacienteScreen> createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores básicos (alta)
  final TextEditingController _cdrController = TextEditingController();
  final TextEditingController _numeroCasaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _carnetIdentidadController =
      TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  // Controladores para enfermedades y discapacidades (alta)
  final Map<String, TextEditingController> enfermedades = {};
  final Map<String, TextEditingController> discapacidades = {};

  // Valores seleccionados (alta)
  String? _sexoSeleccionado;
  String? _colorPielSeleccionado;
  String? _escolaridadSeleccionada;
  String? _ocupacionSeleccionada;
  String? _embarazadaSeleccionado;
  String? _grupoDispensarialSeleccionado;
  String? _controlSeleccionado;
  String? _riesgoPreconcepcionalSeleccionado;
  String? _controlRpcSeleccionado;

  // Factores de riesgo (alta)
  Map<String, bool> factoresRiesgo = {
    "Leptospirosis": false,
    "Alcohol": false,
    "Droga": false,
    "ITS": false,
    "TB": false,
    "Sedentarismo": false,
    "Donantes": false,
    "Social": false,
    "Otro": false,
  };

  final List<String> listaEnfermedades = [
    "HTA",
    "DM",
    "HLP",
    "AB",
    "ECV",
    "SCI",
    "CANCER",
    "EPOC",
    "SIDA",
    "Fumador",
    "Obeso",
    "Alcoholico",
    "ERC",
    "Autismo",
    "Cirrosis",
    "Droga",
    "Otra"
  ];

  final List<String> listaDiscapacidades = [
    "Visual",
    "Auditiva",
    "Fisica",
    "Sordociego",
    "LVH",
    "Intelectual",
    "Mixto",
    "Sensitiva"
  ];

  // Opciones
  final List<String> sexos = ["Masculino", "Femenino"];
  final List<String> coloresPiel = ["Blanca", "Negra", "Mestiza"];
  final List<String> escolaridades = ["SE", "PST", "PT", "ST", "TM/PU", "U"];
  final List<String> ocupaciones = [
    "C Infantil",
    "NAHO",
    "Estudia",
    "Trabaja",
    "Ama de casa",
    "SMG",
    "Jubilado",
    "Recluso",
    "Desocupado"
  ];
  final List<String> siNo = ["Sí", "No"];
  final List<String> gruposDispensariales = ["I", "II", "III", "IV"];
  final List<String> controles = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  final List<String> riesgoPreconcepcionales = [
    "Ninguno",
    "Biologico",
    "Psicologico",
    "Ambiental",
    "Social",
    "Masculino"
  ];
  final List<String> controlesRpc = [
    "Ninguno",
    "Tabletas",
    "Inyecciones",
    "Implantes",
    "DIU",
    "Condon"
  ];

  // Lista de pacientes
  List<Map<String, dynamic>> _pacientes = [];

  // ======== BUSQUEDA RAPIDA ========
  String _busquedaRapida = ""; // texto de búsqueda

  List<Map<String, dynamic>> get _pacientesFiltrados {
    if (_busquedaRapida.isEmpty) return _pacientes;
    return _pacientes.where((p) {
      final nombre = (p['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(_busquedaRapida.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
    for (var e in listaEnfermedades) {
      enfermedades[e] = TextEditingController();
    }
    for (var d in listaDiscapacidades) {
      discapacidades[d] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _cdrController.dispose();
    _numeroCasaController.dispose();
    _nombreController.dispose();
    _carnetIdentidadController.dispose();
    _fechaNacimientoController.dispose();
    _edadController.dispose();
    for (var c in enfermedades.values) {
      c.dispose();
    }
    for (var c in discapacidades.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarPacientes() async {
    final pacientes = await DatabaseHelper.instance.obtenerPacientes();
    if (!mounted) return;
    setState(() {
      _pacientes = pacientes;
    });
  }

  Future<void> _guardarPaciente() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> paciente = {
        'cdr': _cdrController.text.trim(),
        'numeroCasa': _numeroCasaController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'carnet_identidad': _carnetIdentidadController.text.trim(),
        'fecha_nac': _fechaNacimientoController.text.trim(),
        'edad': int.tryParse(_edadController.text) ?? 0,
        'sexo': _sexoSeleccionado,
        'color_piel': _colorPielSeleccionado,
        'escolaridad': _escolaridadSeleccionada,
        'ocupacion': _ocupacionSeleccionada,
        'embarazada': _embarazadaSeleccionado,
        'grupo_disp': _grupoDispensarialSeleccionado,
        'control': _controlSeleccionado,
        'riesgo_preconcepcional': _riesgoPreconcepcionalSeleccionado,
        'control_rpc': _controlRpcSeleccionado,
      };

      // flags binarios (factores)
      for (var entry in factoresRiesgo.entries) {
        paciente[entry.key.toLowerCase()] = entry.value ? 1 : 0;
      }

      // enfermedades y discapacidades flags 1/0 y textos combinados
      for (var e in listaEnfermedades) {
        paciente[e.toLowerCase()] =
            (enfermedades[e]!.text.trim().isNotEmpty) ? 1 : 0;
      }
      for (var d in listaDiscapacidades) {
        paciente[d.toLowerCase()] =
            (discapacidades[d]!.text.trim().isNotEmpty) ? 1 : 0;
      }

      paciente['factor_riesgo'] = factoresRiesgo.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');
      paciente['enfermedades'] = enfermedades.entries
          .where((e) => e.value.text.isNotEmpty)
          .map((e) => "${e.key}: ${e.value.text.trim()}")
          .join(', ');
      paciente['discapacidades'] = discapacidades.entries
          .where((e) => e.value.text.isNotEmpty)
          .map((e) => "${e.key}: ${e.value.text.trim()}")
          .join(', ');

      await DatabaseHelper.instance.insertarPaciente(paciente);

      _resetFormulario();
      await _cargarPacientes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paciente guardado correctamente")));
    }
  }

  void _resetFormulario() {
    _formKey.currentState?.reset();
    _nombreController.clear();
    _carnetIdentidadController.clear();
    _fechaNacimientoController.clear();
    _edadController.clear();
    _sexoSeleccionado = null;
    _colorPielSeleccionado = null;
    _escolaridadSeleccionada = null;
    _ocupacionSeleccionada = null;
    _embarazadaSeleccionado = null;
    _grupoDispensarialSeleccionado = null;
    _controlSeleccionado = null;
    _riesgoPreconcepcionalSeleccionado = null;
    _controlRpcSeleccionado = null;

    factoresRiesgo.updateAll((key, value) => false);
    for (var c in enfermedades.values) {
      c.clear();
    }
    for (var c in discapacidades.values) {
      c.clear();
    }
    setState(() {});
  }

  Future<void> _eliminarPaciente(int id) async {
    await DatabaseHelper.instance.eliminarPaciente(id);
    await _cargarPacientes();
  }

  // Navegar a pantalla de edición (pantalla completa)
  Future<void> _abrirEditarPantalla(Map<String, dynamic> paciente) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPacienteScreen(paciente: paciente),
      ),
    );

    if (actualizado == true) {
      await _cargarPacientes();
    }
  }

  // ================= FILTRO DINÁMICO =================
  Future<void> _abrirDialogoFiltro() async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => FiltroPacientesDialog(
        sexos: sexos,
        coloresPiel: coloresPiel,
        escolaridades: escolaridades,
        ocupaciones: ocupaciones,
        gruposDispensariales: gruposDispensariales,
        controles: controles,
        riesgoPreconcepcionales: riesgoPreconcepcionales,
        controlesRpc: controlesRpc,
        factoresRiesgo: factoresRiesgo,
        listaEnfermedades: listaEnfermedades,
        listaDiscapacidades: listaDiscapacidades,
        limpiarCallback: _cargarPacientes,
      ),
    );

    if (resultado != null) {
      String where = "";
      List<dynamic> args = [];

      // --- Filtro por rango de edad ---
      if (resultado['edadMin'] != null && resultado['edadMax'] != null) {
        where += "edad BETWEEN ? AND ?";
        args.addAll([resultado['edadMin'], resultado['edadMax']]);
      }

      // --- Filtros básicos ---
      for (var key in [
        'sexo',
        'color_piel',
        'escolaridad',
        'ocupacion',
        'grupo_disp',
        'embarazada',
        'control',
        'riesgo_preconcepcional',
        'control_rpc'
      ]) {
        if (resultado[key] != null) {
          if (where.isNotEmpty) where += " AND ";
          where += "$key = ?";
          args.add(resultado[key]);
        }
      }

      // --- Filtro por CDR ---
      if (resultado['cdr'] != null && resultado['cdr'].toString().isNotEmpty) {
        if (where.isNotEmpty) where += " AND ";
        where += "cdr = ?";
        args.add(resultado['cdr']);
      }

      // --- Filtro por número de casa ---
      if (resultado['numeroCasa'] != null &&
          resultado['numeroCasa'].toString().isNotEmpty) {
        if (where.isNotEmpty) where += " AND ";
        where += "numeroCasa = ?";
        args.add(resultado['numeroCasa']);
      }

      // --- Filtro por control (mes) ---
      if (resultado['control'] != null &&
          resultado['control'].toString().isNotEmpty) {
        if (where.isNotEmpty) where += " AND ";
        where += "control = ?";
        args.add(resultado['control']);
      }

      // --- Filtros por factores de riesgo ---
      for (var key in factoresRiesgo.keys) {
        if (resultado[key] == true) {
          if (where.isNotEmpty) where += " AND ";
          where += "${key.toLowerCase()} = 1";
        }
      }

      // --- Filtros por enfermedades ---
      for (var key in listaEnfermedades) {
        if (resultado[key] == true) {
          if (where.isNotEmpty) where += " AND ";
          where += "${key.toLowerCase()} = 1";
        }
      }

      // --- Filtros por discapacidades ---
      for (var key in listaDiscapacidades) {
        if (resultado[key] == true) {
          if (where.isNotEmpty) where += " AND ";
          where += "${key.toLowerCase()} = 1";
        }
      }

      // --- Consultar BD con filtros ---
      final pacientesFiltrados = where.isNotEmpty
          ? await DatabaseHelper.instance.obtenerPacientesFiltrados(where, args)
          : await DatabaseHelper.instance.obtenerPacientes();

      setState(() {
        _pacientes = pacientesFiltrados;
      });
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Pacientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // FORMULARIO DE ALTA
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //CDR
                      TextFormField(
                        controller: _cdrController,
                        decoration: const InputDecoration(
                          labelText: "CDR o zona",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // NUMERO DE CASA
                      TextFormField(
                        controller: _numeroCasaController,
                        decoration: const InputDecoration(
                          labelText: "Número de casa",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                            labelText: "Nombre", border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty
                            ? "Ingrese el nombre"
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Carnet de identidad
                      TextFormField(
                        controller: _carnetIdentidadController,
                        decoration: const InputDecoration(
                            labelText: "Carnet de identidad",
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),

                      // Fecha nacimiento y edad
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          DateTime initialDate = DateTime.tryParse(
                                  _fechaNacimientoController.text) ??
                              now; // intenta usar la fecha actual del campo
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(1900),
                            lastDate: now,
                          );
                          if (picked != null) {
                            setState(() {
                              _fechaNacimientoController.text =
                                  DateFormat('dd-MM-yyyy').format(picked);

                              // Calculamos la edad automáticamente
                              int edad = now.year - picked.year;
                              if (now.month < picked.month ||
                                  (now.month == picked.month &&
                                      now.day < picked.day)) {
                                edad--;
                              }
                              _edadController.text = edad.toString();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _fechaNacimientoController.text.isEmpty
                                ? "Seleccionar fecha de nacimiento"
                                : _fechaNacimientoController.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _edadController,
                        decoration: const InputDecoration(
                            labelText: "Edad", border: OutlineInputBorder()),
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),

                      // Sexo
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Sexo", border: OutlineInputBorder()),
                        initialValue: _sexoSeleccionado,
                        items: sexos
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _sexoSeleccionado = val;
                            if (_sexoSeleccionado != "Femenino") {
                              _embarazadaSeleccionado =
                                  null; // resetear si no es femenino
                            }
                          });
                        },
                        validator: (val) =>
                            val == null ? "Seleccione un sexo" : null,
                      ),
                      const SizedBox(height: 12),

                      // Embarazada (solo femenino)
                      if (_sexoSeleccionado == "Femenino")
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: "Embarazada",
                              border: OutlineInputBorder()),
                          initialValue: _embarazadaSeleccionado,
                          items: siNo
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _embarazadaSeleccionado = val),
                        ),
                      if (_sexoSeleccionado == "Femenino")
                        const SizedBox(height: 12),

                      // Color piel
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Color de piel",
                            border: OutlineInputBorder()),
                        initialValue: _colorPielSeleccionado,
                        items: coloresPiel
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _colorPielSeleccionado = val),
                        validator: (val) =>
                            val == null ? "Seleccione color de piel" : null,
                      ),
                      const SizedBox(height: 12),

                      // Escolaridad
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Escolaridad",
                            border: OutlineInputBorder()),
                        initialValue: _escolaridadSeleccionada,
                        items: escolaridades
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _escolaridadSeleccionada = val),
                        validator: (val) =>
                            val == null ? "Seleccione escolaridad" : null,
                      ),
                      const SizedBox(height: 12),

                      // Ocupación
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Ocupación",
                            border: OutlineInputBorder()),
                        initialValue: _ocupacionSeleccionada,
                        items: ocupaciones
                            .map((o) =>
                                DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _ocupacionSeleccionada = val),
                        validator: (val) =>
                            val == null ? "Seleccione ocupación" : null,
                      ),
                      const SizedBox(height: 12),

                      // Grupo dispensarial
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Grupo Dispensarial",
                            border: OutlineInputBorder()),
                        initialValue: _grupoDispensarialSeleccionado,
                        items: gruposDispensariales
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) => setState(
                            () => _grupoDispensarialSeleccionado = val),
                        validator: (val) => val == null
                            ? "Seleccione grupo dispensarial"
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Próximo control (mes)
                      DropdownButtonFormField<String>(
                        initialValue: _controlSeleccionado,
                        decoration: const InputDecoration(
                          labelText: "Próximo control (mes)",
                          border: OutlineInputBorder(),
                        ),
                        items: controles.map((mes) {
                          return DropdownMenuItem(
                            value: mes,
                            child: Text(mes),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            _controlSeleccionado = valor;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione un mes';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Factores de riesgo (alta)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text("Factores de riesgo",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Column(
                        children: factoresRiesgo.keys
                            .map((k) => CheckboxListTile(
                                  title: Text(k),
                                  value: factoresRiesgo[k],
                                  onChanged: (val) => setState(
                                      () => factoresRiesgo[k] = val ?? false),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),

                      // Riesgo Preconcepcional
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Riesgo Preconcepcional",
                            border: OutlineInputBorder()),
                        initialValue: _riesgoPreconcepcionalSeleccionado,
                        items: riesgoPreconcepcionales
                            .map((o) =>
                                DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (val) => setState(
                            () => _riesgoPreconcepcionalSeleccionado = val),
                      ),
                      const SizedBox(height: 12),

                      // Control de RPC
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Control RPC",
                            border: OutlineInputBorder()),
                        initialValue: _controlRpcSeleccionado,
                        items: controlesRpc
                            .map((o) =>
                                DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _controlRpcSeleccionado = val),
                      ),
                      const SizedBox(height: 12),

                      // Enfermedades (alta)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text(
                              "Enfermedades (indique clasificación si aplica)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Column(
                        children: listaEnfermedades
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: TextFormField(
                                    controller: enfermedades[e],
                                    decoration: InputDecoration(
                                        labelText: e,
                                        border: const OutlineInputBorder()),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),

                      // Discapacidades (alta)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text(
                              "Discapacidades (indique ENFERMEDAD o ACCIDENTE)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Column(
                        children: listaDiscapacidades
                            .map((d) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: TextFormField(
                                    controller: discapacidades[d],
                                    decoration: InputDecoration(
                                        labelText: d,
                                        border: const OutlineInputBorder()),
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 12),

                      // BOTONES GUARDAR / FILTRAR
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _guardarPaciente,
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _abrirDialogoFiltro,
                              icon: const Icon(Icons.filter_alt),
                              label: const Text("Filtrar"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 16),

            // ===== BUSQUEDA RAPIDA =====
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _busquedaRapida = val),
            ),
            const SizedBox(height: 8),

            // LISTADO DE PACIENTES
            Expanded(
              flex: 3,
              child: _pacientesFiltrados.isEmpty
                  ? const Center(child: Text("No hay pacientes registrados"))
                  : ListView.builder(
                      itemCount: _pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = _pacientesFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: ListTile(
                            title: Text(
                                "CDR ${paciente['cdr'] ?? ''} - Casa ${paciente['numeroCasa'] ?? ''}\n"
                                "${paciente['nombre'] ?? ''} (${paciente['edad'] ?? ''} años)"),
                            subtitle: Text(
                              "Carnet de identidad: ${paciente['carnet_identidad'] ?? 'N/A'}\n"
                              "Sexo: ${paciente['sexo'] ?? 'N/A'} - Color piel: ${paciente['color_piel'] ?? 'N/A'}\n"
                              "Escolaridad: ${paciente['escolaridad'] ?? 'N/A'} - Ocupación: ${paciente['ocupacion'] ?? 'N/A'}\n"
                              "Embarazada: ${paciente['embarazada'] ?? 'N/A'}\n"
                              "Grupo Dispensarial: ${paciente['grupo_disp'] ?? 'N/A'}\n"
                              "Factores: ${paciente['factor_riesgo'] ?? ''}\n"
                              "Riesgo Preconcepcional: ${paciente['riesgo_preconcepcional'] ?? ''}\n"
                              "Control RPC: ${paciente['control_rpc'] ?? ''}\n"
                              "Enfermedades: ${paciente['enfermedades'] ?? ''}\n"
                              "Discapacidades: ${paciente['discapacidades'] ?? ''}\n"
                              "Próximo control: ${paciente['control'] ?? 'N/A'}",
                            ),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _abrirEditarPantalla(paciente),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _eliminarPaciente(paciente['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= Pantalla completa de edición =================
class EditarPacienteScreen extends StatefulWidget {
  final Map<String, dynamic> paciente;
  const EditarPacienteScreen({super.key, required this.paciente});

  @override
  State<EditarPacienteScreen> createState() => _EditarPacienteScreenState();
}

class _EditarPacienteScreenState extends State<EditarPacienteScreen> {
  final db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController cdrController;
  late TextEditingController numeroCasaController;
  late TextEditingController nombreController;
  late TextEditingController carnetIdentidadController;
  late TextEditingController fechaNacController;
  late TextEditingController edadController;

  late Map<String, bool> factoresLocal;
  late Map<String, TextEditingController> enfermedadesLocal;
  late Map<String, TextEditingController> discapacidadesLocal;

  String? sexo;
  String? colorPiel;
  String? escolaridad;
  String? ocupacion;
  String? embarazada;
  String? grupoDisp;
  String? control;
  String? riesgoPreconcepcional;
  String? controlRpc;

  final List<String> listaEnfermedades = [
    "HTA",
    "DM",
    "HLP",
    "AB",
    "ECV",
    "SCI",
    "CANCER",
    "EPOC",
    "SIDA",
    "Fumador",
    "Obeso",
    "Alcoholico",
    "ERC",
    "Autismo",
    "Cirrosis",
    "Droga",
    "Otra"
  ];

  final List<String> listaDiscapacidades = [
    "Visual",
    "Auditiva",
    "Fisica",
    "Sordociego",
    "LVH",
    "Intelectual",
    "Mixto",
    "Sensitiva"
  ];

  final Map<String, bool> factoresBase = {
    "Leptospirosis": false,
    "Alcohol": false,
    "Droga": false,
    "ITS": false,
    "TB": false,
    "Sedentarismo": false,
    "Donantes": false,
    "Social": false,
    "Otro": false,
  };

  @override
  void initState() {
    super.initState();

    final p = widget.paciente;

    cdrController = TextEditingController(text: widget.paciente['cdr']);
    numeroCasaController =
        TextEditingController(text: widget.paciente['numeroCasa']);
    nombreController =
        TextEditingController(text: p['nombre']?.toString() ?? '');
    carnetIdentidadController =
        TextEditingController(text: p['carnet_identidad']?.toString() ?? '');
    fechaNacController =
        TextEditingController(text: p['fecha_nac']?.toString() ?? '');
    edadController = TextEditingController(text: (p['edad'] ?? '').toString());

    factoresLocal = {};
    for (var k in factoresBase.keys) {
      final val = p[k.toLowerCase()];
      factoresLocal[k] = (val == 1 || val == '1' || val == true);
    }

    enfermedadesLocal = {};
    String combinedEnf = p['enfermedades']?.toString() ?? '';
    for (var e in listaEnfermedades) {
      enfermedadesLocal[e] =
          TextEditingController(text: _extractFieldValue(combinedEnf, e));
    }

    discapacidadesLocal = {};
    String combinedDisc = p['discapacidades']?.toString() ?? '';
    for (var d in listaDiscapacidades) {
      discapacidadesLocal[d] =
          TextEditingController(text: _extractFieldValue(combinedDisc, d));
    }

    sexo = p['sexo']?.toString();
    colorPiel = p['color_piel']?.toString();
    escolaridad = p['escolaridad']?.toString();
    ocupacion = p['ocupacion']?.toString();
    embarazada = p['embarazada']?.toString();
    grupoDisp = p['grupo_disp']?.toString();
    control = p['control']?.toString();
    riesgoPreconcepcional = p['riesgo_preconcepcional'];
    controlRpc = p['control_rpc'];
  }

  String _extractFieldValue(String combined, String key) {
    if (combined.isEmpty) return '';
    final pattern =
        RegExp(RegExp.escape(key) + r'\s*:\s*([^,]+)', caseSensitive: false);
    final m = pattern.firstMatch(combined);
    if (m != null && m.groupCount >= 1) {
      return m.group(1)!.trim();
    }
    return '';
  }

  @override
  void dispose() {
    cdrController.dispose();
    numeroCasaController.dispose();
    nombreController.dispose();
    carnetIdentidadController.dispose();
    fechaNacController.dispose();
    edadController.dispose();
    for (var c in enfermedadesLocal.values) {
      c.dispose();
    }
    for (var c in discapacidadesLocal.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardarEdicion() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.paciente['id'];
    Map<String, dynamic> pacienteMap = {
      'cdr': cdrController.text.trim(),
      'numeroCasa': numeroCasaController.text.trim(),
      'nombre': nombreController.text.trim(),
      'carnet_identidad': carnetIdentidadController.text.trim(),
      'fecha_nac': fechaNacController.text.trim(),
      'edad': int.tryParse(edadController.text) ?? 0,
      'sexo': sexo,
      'color_piel': colorPiel,
      'escolaridad': escolaridad,
      'ocupacion': ocupacion,
      'embarazada': embarazada,
      'grupo_disp': grupoDisp,
      'control': control,
      'riesgo_preconcepcional': riesgoPreconcepcional,
      'control_rpc': controlRpc,
    };

    for (var entry in factoresLocal.entries) {
      pacienteMap[entry.key.toLowerCase()] = entry.value ? 1 : 0;
    }

    for (var e in listaEnfermedades) {
      pacienteMap[e.toLowerCase()] =
          (enfermedadesLocal[e]!.text.trim().isNotEmpty) ? 1 : 0;
    }
    pacienteMap['enfermedades'] = enfermedadesLocal.entries
        .where((e) => e.value.text.trim().isNotEmpty)
        .map((e) => "${e.key}: ${e.value.text.trim()}")
        .join(', ');

    for (var d in listaDiscapacidades) {
      pacienteMap[d.toLowerCase()] =
          (discapacidadesLocal[d]!.text.trim().isNotEmpty) ? 1 : 0;
    }
    pacienteMap['discapacidades'] = discapacidadesLocal.entries
        .where((e) => e.value.text.trim().isNotEmpty)
        .map((e) => "${e.key}: ${e.value.text.trim()}")
        .join(', ');

    pacienteMap['factor_riesgo'] = factoresLocal.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');

    await db.actualizarPaciente(id, pacienteMap);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: cdrController,
                decoration: const InputDecoration(
                  labelText: "CDR o zona",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numeroCasaController,
                decoration: const InputDecoration(
                  labelText: "Número de casa",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                      labelText: "Nombre", border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(
                  controller: carnetIdentidadController,
                  decoration: const InputDecoration(
                      labelText: "Carnet de identidad",
                      border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(
                controller: fechaNacController,
                decoration: const InputDecoration(
                    labelText: "Fecha de nacimiento (dd-MM-yyyy)",
                    border: OutlineInputBorder()),
                onChanged: (v) {
                  try {
                    DateTime fecha = DateFormat('dd-MM-yyyy').parse(v);
                    DateTime hoy = DateTime.now();
                    int edad = hoy.year - fecha.year;
                    if (hoy.month < fecha.month ||
                        (hoy.month == fecha.month && hoy.day < fecha.day)) {
                      edad--;
                    }
                    edadController.text = edad.toString();
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: edadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Edad", border: OutlineInputBorder())),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Sexo", border: OutlineInputBorder()),
                initialValue: sexo,
                items: ['Masculino', 'Femenino']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() {
                  sexo = v;
                  if (sexo != "Femenino") {
                    embarazada = null;
                  }
                }),
                validator: (val) => val == null ? "Seleccione un sexo" : null,
              ),
              const SizedBox(height: 8),
              if (sexo == "Femenino")
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: "Embarazada", border: OutlineInputBorder()),
                  initialValue: embarazada,
                  items: ['Sí', 'No']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => embarazada = v),
                ),
              if (sexo == "Femenino") const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Color de piel", border: OutlineInputBorder()),
                initialValue: colorPiel,
                items: ['Blanca', 'Negra', 'Mestiza']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => colorPiel = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Escolaridad", border: OutlineInputBorder()),
                initialValue: escolaridad,
                items: ['SE', 'PST', 'PT', 'ST', 'TM/PU', 'U']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => escolaridad = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Ocupación", border: OutlineInputBorder()),
                initialValue: ocupacion,
                items: [
                  'C Infantil',
                  'NAHO',
                  'Estudia',
                  'Trabaja',
                  'Ama de casa',
                  'SMG',
                  'Jubilado',
                  'Recluso',
                  'Desocupado'
                ]
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => ocupacion = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Grupo Dispensarial",
                    border: OutlineInputBorder()),
                initialValue: grupoDisp,
                items: ['I', 'II', 'III', 'IV']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => grupoDisp = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Control", border: OutlineInputBorder()),
                initialValue: control,
                items: [
                  'Enero',
                  'Febrero',
                  'Marzo',
                  'Abril',
                  'Mayo',
                  'Junio',
                  'Julio',
                  'Agosto',
                  'Septiembre',
                  'Octubre',
                  'Noviembre',
                  'Diciembre'
                ]
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => control = v),
              ),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Factores de riesgo",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Column(
                children: factoresLocal.keys
                    .map((k) => CheckboxListTile(
                          title: Text(k),
                          value: factoresLocal[k],
                          onChanged: (val) =>
                              setState(() => factoresLocal[k] = val ?? false),
                        ))
                    .toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Riesgo Preconcepcional",
                    border: OutlineInputBorder()),
                initialValue: riesgoPreconcepcional,
                items: [
                  'Ninguno',
                  'Biologico',
                  'Psicologico',
                  'Ambiental',
                  'Social',
                  'Masculino'
                ]
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => riesgoPreconcepcional = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Control de RPC", border: OutlineInputBorder()),
                initialValue: controlRpc,
                items: [
                  'Ninguno',
                  'Tabletas',
                  'Inyecciones',
                  'Implantes',
                  'DIU',
                  'Condon'
                ]
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => controlRpc = v),
              ),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Enfermedades (indique clasificación si aplica)",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Column(
                children: listaEnfermedades
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TextField(
                              controller: enfermedadesLocal[e],
                              decoration: InputDecoration(
                                  labelText: e,
                                  border: const OutlineInputBorder())),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Discapacidades (indique causa)",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Column(
                children: listaDiscapacidades
                    .map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TextField(
                              controller: discapacidadesLocal[d],
                              decoration: InputDecoration(
                                  labelText: d,
                                  border: const OutlineInputBorder())),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _guardarEdicion,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= DIALOGO FILTRO =================
class FiltroPacientesDialog extends StatefulWidget {
  final List<String> sexos;
  final List<String> coloresPiel;
  final List<String> escolaridades;
  final List<String> ocupaciones;
  final List<String> gruposDispensariales;
  final List<String> controles;
  final List<String> riesgoPreconcepcionales;
  final List<String> controlesRpc;
  final Map<String, bool> factoresRiesgo;
  final List<String> listaEnfermedades;
  final List<String> listaDiscapacidades;
  final VoidCallback limpiarCallback;

  const FiltroPacientesDialog({
    super.key,
    required this.sexos,
    required this.coloresPiel,
    required this.escolaridades,
    required this.ocupaciones,
    required this.gruposDispensariales,
    required this.factoresRiesgo,
    required this.riesgoPreconcepcionales,
    required this.controlesRpc,
    required this.listaEnfermedades,
    required this.listaDiscapacidades,
    required this.controles,
    required this.limpiarCallback,
  });

  @override
  State<FiltroPacientesDialog> createState() => _FiltroPacientesDialogState();
}

class _FiltroPacientesDialogState extends State<FiltroPacientesDialog> {
  String? sexo;
  String? colorPiel;
  String? escolaridad;
  String? ocupacion;
  String? grupoDisp;
  String? control;
  String? riesgoPreconcepcional;
  String? controlRpc;
  final List<String> controles = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  String? embarazada;
  int? edadMin;
  int? edadMax;

  // --- Controllers nuevos ---
  TextEditingController cdrController = TextEditingController();
  TextEditingController numeroCasaController = TextEditingController();

  Map<String, bool> factores = {};
  Map<String, bool> enfermedades = {};
  Map<String, bool> discapacidades = {};

  @override
  void initState() {
    super.initState();
    factores = Map.from(widget.factoresRiesgo);
    for (var e in widget.listaEnfermedades) {
      enfermedades[e] = false;
    }
    for (var d in widget.listaDiscapacidades) {
      discapacidades[d] = false;
    }
  }

  @override
  void dispose() {
    cdrController.dispose();
    numeroCasaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filtrar pacientes"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // --- NUEVOS TEXTFIELDS para CDR y Número de casa ---
            TextField(
              controller: cdrController,
              decoration: const InputDecoration(labelText: "CDR"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numeroCasaController,
              decoration: const InputDecoration(labelText: "Número de casa"),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: "Edad mínima"),
              keyboardType: TextInputType.number,
              onChanged: (val) => edadMin = int.tryParse(val),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Edad máxima"),
              keyboardType: TextInputType.number,
              onChanged: (val) => edadMax = int.tryParse(val),
            ),
            const SizedBox(height: 8),

            // --- Dropdowns existentes ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Sexo"),
              initialValue: sexo,
              items: widget.sexos
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => sexo = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Embarazada"),
              initialValue: embarazada,
              items: ["Sí", "No"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => embarazada = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Color de piel"),
              initialValue: colorPiel,
              items: widget.coloresPiel
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => colorPiel = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Escolaridad"),
              initialValue: escolaridad,
              items: widget.escolaridades
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => escolaridad = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Ocupación"),
              initialValue: ocupacion,
              items: widget.ocupaciones
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) => setState(() => ocupacion = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: "Grupo Dispensarial"),
              initialValue: grupoDisp,
              items: widget.gruposDispensariales
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => grupoDisp = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Próximo Control"),
              initialValue: control,
              items: widget.controles
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) => setState(() => control = val),
            ),
            const SizedBox(height: 12),

            // --- Factores, enfermedades, discapacidades ---
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Factores de riesgo")),
            Column(
              children: factores.keys
                  .map((k) => CheckboxListTile(
                        title: Text(k),
                        value: factores[k],
                        onChanged: (val) =>
                            setState(() => factores[k] = val ?? false),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: "Riesgo Preconcepcional"),
              initialValue: riesgoPreconcepcional,
              items: widget.riesgoPreconcepcionales
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) => setState(() => riesgoPreconcepcional = val),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Control RPC"),
              initialValue: controlRpc,
              items: widget.controlesRpc
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) => setState(() => controlRpc = val),
            ),
            const SizedBox(height: 8),

            const Align(
                alignment: Alignment.centerLeft, child: Text("Enfermedades")),
            Column(
              children: enfermedades.keys
                  .map((k) => CheckboxListTile(
                        title: Text(k),
                        value: enfermedades[k],
                        onChanged: (val) =>
                            setState(() => enfermedades[k] = val ?? false),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            const Align(
                alignment: Alignment.centerLeft, child: Text("Discapacidades")),
            Column(
              children: discapacidades.keys
                  .map((k) => CheckboxListTile(
                        title: Text(k),
                        value: discapacidades[k],
                        onChanged: (val) =>
                            setState(() => discapacidades[k] = val ?? false),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.limpiarCallback();
            Navigator.pop(context, null);
          },
          child: const Text("Limpiar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'sexo': sexo,
              'color_piel': colorPiel,
              'escolaridad': escolaridad,
              'ocupacion': ocupacion,
              'grupo_disp': grupoDisp,
              'embarazada': embarazada,
              'edadMin': edadMin,
              'edadMax': edadMax,
              'control': control,
              'cdr': cdrController.text,
              'numeroCasa': numeroCasaController.text,
              'riesgo_preconcepcional': riesgoPreconcepcional,
              'control_rpc': controlRpc,
              ...factores,
              ...enfermedades,
              ...discapacidades,
            });
          },
          child: const Text("Aplicar"),
        ),
      ],
    );
  }
}
