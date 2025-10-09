import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class FamiliaScreen extends StatefulWidget {
  const FamiliaScreen({super.key});

  @override
  State<FamiliaScreen> createState() => _FamiliaScreenState();
}

class _FamiliaScreenState extends State<FamiliaScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _editingId; // <-- Para saber si estamos editando

  // ---------------- CAMPOS ----------------
  String? _cdr;
  String? _calle;
  String? _numeroCasa;
  String? _tipoFamilia;
  String? _funcionalidad;
  String? _integrantes;
  String? _habitaciones;
  String? _animales;
  String? _vectores;
  String? _techo;
  String? _paredes;
  String? _piso;
  String? _equipamiento;
  String? _condicionesEconomicas;
  String? _condicionesHigienicas;
  String? _abastoAgua;
  String? _residualesLiquidos;
  String? _residualesSolidos;

  // ---------------- OPCIONES ----------------
  final List<String> tiposFamilia = [
    "Nuclear sin hijos",
    "Nuclear con hijos",
    "Nuclear incompleta",
    "Extensa",
    "Ampliada"
  ];
  final List<String> funcionalidades = [
    "Funcional",
    "Riesgo de disfunción",
    "Disfuncional"
  ];
  final List<String> integrantes = ["1-3", "4-6", "+7"];
  final List<String> habitaciones = ["1", "2", "3", "4", "5"];
  final List<String> siNo = ["Sí", "No"];
  final List<String> techos = ["Placa", "Fibrocemento", "Zinc", "Madera", "Otro"];
  final List<String> paredes = ["Mampostería", "Madera", "Otro"];
  final List<String> pisos = ["Mosaico", "Cemento", "Tierra"];
  final List<String> estados = ["Buena", "Regular", "Mala"];
  final List<String> abastoAgua = ["Acueducto", "Pozo", "Pipa", "Otro"];
  final List<String> residualesLiquidos = ["Alcantarillado", "Fosa", "Otro"];
  final List<String> residualesSolidos = ["Recogida", "Vertedero", "Quema", "Otro"];

  List<Map<String, dynamic>> _familias = [];

  @override
  void initState() {
    super.initState();
    _cargarFamilias();
  }

  // ---------------- CARGAR DATOS ----------------
  Future<void> _cargarFamilias({Map<String, dynamic>? filtros}) async {
    final db = DatabaseHelper.instance;
    List<Map<String, dynamic>> familias;

    if (filtros == null || filtros.isEmpty) {
      familias = await db.obtenerFamilias();
    } else {
      String where = '';
      List<dynamic> args = [];
      filtros.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (where.isNotEmpty) where += ' AND ';
          where += '$key = ?';
          args.add(value);
        }
      });
      familias = await db.database.then((db) => db.query('familias', where: where, whereArgs: args));
    }

    if (!mounted) return;
    setState(() {
      _familias = familias;
    });

    if (_familias.isEmpty && filtros != null && filtros.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No hay coincidencias"),
          content: const Text("No se encontraron familias con los criterios seleccionados."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        ),
      );
    }
  }

  // ---------------- GUARDAR / ACTUALIZAR ----------------
  Future<void> _guardarFamilia() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> familia = {
        'cdr': _cdr,
        'calle': _calle,
        'numeroCasa': _numeroCasa,
        'tipo_familia': _tipoFamilia,
        'funcionalidad': _funcionalidad,
        'integrantes': _integrantes,
        'habitaciones': _habitaciones,
        'animales_domesticos': _animales,
        'vectores': _vectores,
        'techo': _techo,
        'paredes': _paredes,
        'piso': _piso,
        'equipamiento': _equipamiento,
        'condiciones_economicas': _condicionesEconomicas,
        'condiciones_higienicas': _condicionesHigienicas,
        'abasto_agua': _abastoAgua,
        'residuales_liquidos': _residualesLiquidos,
        'residuales_solidos': _residualesSolidos,
      };

      if (_editingId != null) {
        await DatabaseHelper.instance.actualizarFamilia(_editingId!, familia);
        _editingId = null;
        _resetFormulario();
        _cargarFamilias();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Familia actualizada correctamente")),
        );
      } else {
        await DatabaseHelper.instance.insertarFamilia(familia);
        _resetFormulario();
        _cargarFamilias();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Familia guardada correctamente")),
        );
      }
    }
  }

  void _resetFormulario() {
    _formKey.currentState?.reset();
    _editingId = null;
    _cdr = null;
    _calle = null;
    _numeroCasa = null;
    _tipoFamilia = null;
    _funcionalidad = null;
    _integrantes = null;
    _habitaciones = null;
    _animales = null;
    _vectores = null;
    _techo = null;
    _paredes = null;
    _piso = null;
    _equipamiento = null;
    _condicionesEconomicas = null;
    _condicionesHigienicas = null;
    _abastoAgua = null;
    _residualesLiquidos = null;
    _residualesSolidos = null;
    setState(() {});
  }

  Future<void> _eliminarFamilia(int id) async {
    await DatabaseHelper.instance.eliminarFamilia(id);
    _cargarFamilias();
  }

  void _editarFamilia(Map<String, dynamic> familia) {
    _editingId = familia['id'];
    _cdr = familia['cdr'];
    _calle = familia['calle'];
    _numeroCasa = familia['numeroCasa'];
    _tipoFamilia = familia['tipo_familia'];
    _funcionalidad = familia['funcionalidad'];
    _integrantes = familia['integrantes'];
    _habitaciones = familia['habitaciones'];
    _animales = familia['animales_domesticos'];
    _vectores = familia['vectores'];
    _techo = familia['techo'];
    _paredes = familia['paredes'];
    _piso = familia['piso'];
    _equipamiento = familia['equipamiento'];
    _condicionesEconomicas = familia['condiciones_economicas'];
    _condicionesHigienicas = familia['condiciones_higienicas'];
    _abastoAgua = familia['abasto_agua'];
    _residualesLiquidos = familia['residuales_liquidos'];
    _residualesSolidos = familia['residuales_solidos'];
    setState(() {});
  }

  // ---------------- WIDGETS ----------------
  Widget _buildDropdown(String label, String? value, List<String> opciones, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      initialValue: value,
      items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (_) => null,
    );
  }

  Widget _buildTextField(String label, String? value, Function(String?) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      initialValue: value,
      onChanged: onChanged,
    );
  }

  // ---------------- POPUP FILTROS ----------------
  void _abrirPopupFiltros() {
    String? tmpCdr = _cdr;
    String? tmpCalle = _calle;
    String? tmpNumeroCasa = _numeroCasa;
    String? tmpTipoFamilia = _tipoFamilia;
    String? tmpFuncionalidad = _funcionalidad;
    String? tmpIntegrantes = _integrantes;
    String? tmpHabitaciones = _habitaciones;
    String? tmpAnimales = _animales;
    String? tmpVectores = _vectores;
    String? tmpTecho = _techo;
    String? tmpParedes = _paredes;
    String? tmpPiso = _piso;
    String? tmpEquipamiento = _equipamiento;
    String? tmpCondicionesEconomicas = _condicionesEconomicas;
    String? tmpCondicionesHigienicas = _condicionesHigienicas;
    String? tmpAbastoAgua = _abastoAgua;
    String? tmpResidualesLiquidos = _residualesLiquidos;
    String? tmpResidualesSolidos = _residualesSolidos;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filtrar familias"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("CDR", tmpCdr, (val) => tmpCdr = val),
              const SizedBox(height: 8),
              _buildTextField("Calle", tmpCalle, (val) => tmpCalle = val),
              const SizedBox(height: 8),
              _buildTextField("Número de Casa", tmpNumeroCasa, (val) => tmpNumeroCasa = val),
              const SizedBox(height: 8),
              _buildDropdown("Tipo de familia", tmpTipoFamilia, tiposFamilia, (val) => tmpTipoFamilia = val),
              const SizedBox(height: 8),
              _buildDropdown("Funcionalidad", tmpFuncionalidad, funcionalidades, (val) => tmpFuncionalidad = val),
              const SizedBox(height: 8),
              _buildDropdown("Integrantes", tmpIntegrantes, integrantes, (val) => tmpIntegrantes = val),
              const SizedBox(height: 8),
              _buildDropdown("Habitaciones", tmpHabitaciones, habitaciones, (val) => tmpHabitaciones = val),
              const SizedBox(height: 8),
              _buildDropdown("Animales domésticos", tmpAnimales, siNo, (val) => tmpAnimales = val),
              const SizedBox(height: 8),
              _buildDropdown("Vectores", tmpVectores, siNo, (val) => tmpVectores = val),
              const SizedBox(height: 8),
              _buildDropdown("Techo", tmpTecho, techos, (val) => tmpTecho = val),
              const SizedBox(height: 8),
              _buildDropdown("Paredes", tmpParedes, paredes, (val) => tmpParedes = val),
              const SizedBox(height: 8),
              _buildDropdown("Piso", tmpPiso, pisos, (val) => tmpPiso = val),
              const SizedBox(height: 8),
              _buildDropdown("Equipamiento", tmpEquipamiento, estados, (val) => tmpEquipamiento = val),
              const SizedBox(height: 8),
              _buildDropdown("Condiciones económicas", tmpCondicionesEconomicas, estados, (val) => tmpCondicionesEconomicas = val),
              const SizedBox(height: 8),
              _buildDropdown("Condiciones higiénicas", tmpCondicionesHigienicas, estados, (val) => tmpCondicionesHigienicas = val),
              const SizedBox(height: 8),
              _buildDropdown("Abasto de agua", tmpAbastoAgua, abastoAgua, (val) => tmpAbastoAgua = val),
              const SizedBox(height: 8),
              _buildDropdown("Residuales líquidos", tmpResidualesLiquidos, residualesLiquidos, (val) => tmpResidualesLiquidos = val),
              const SizedBox(height: 8),
              _buildDropdown("Residuales sólidos", tmpResidualesSolidos, residualesSolidos, (val) => tmpResidualesSolidos = val),
            ],
          ),
        ),
        actions: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cargarFamilias();
                },
                child: const Text("Limpiar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _cdr = tmpCdr;
                    _calle = tmpCalle;
                    _numeroCasa = tmpNumeroCasa;
                    _tipoFamilia = tmpTipoFamilia;
                    _funcionalidad = tmpFuncionalidad;
                    _integrantes = tmpIntegrantes;
                    _habitaciones = tmpHabitaciones;
                    _animales = tmpAnimales;
                    _vectores = tmpVectores;
                    _techo = tmpTecho;
                    _paredes = tmpParedes;
                    _piso = tmpPiso;
                    _equipamiento = tmpEquipamiento;
                    _condicionesEconomicas = tmpCondicionesEconomicas;
                    _condicionesHigienicas = tmpCondicionesHigienicas;
                    _abastoAgua = tmpAbastoAgua;
                    _residualesLiquidos = tmpResidualesLiquidos;
                    _residualesSolidos = tmpResidualesSolidos;
                  });
                  _cargarFamilias(filtros: {
                    'cdr': _cdr,
                    'calle': _calle,
                    'numeroCasa': _numeroCasa,
                    'tipo_familia': _tipoFamilia,
                    'funcionalidad': _funcionalidad,
                    'integrantes': _integrantes,
                    'habitaciones': _habitaciones,
                    'animales_domesticos': _animales,
                    'vectores': _vectores,
                    'techo': _techo,
                    'paredes': _paredes,
                    'piso': _piso,
                    'equipamiento': _equipamiento,
                    'condiciones_economicas': _condicionesEconomicas,
                    'condiciones_higienicas': _condicionesHigienicas,
                    'abasto_agua': _abastoAgua,
                    'residuales_liquidos': _residualesLiquidos,
                    'residuales_solidos': _residualesSolidos,
                  });
                },
                child: const Text("Aplicar"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Familias")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField("CDR", _cdr, (val) => setState(() => _cdr = val)),
                      const SizedBox(height: 12),
                      _buildTextField("Calle", _calle, (val) => setState(() => _calle = val)),
                      const SizedBox(height: 12),
                      _buildTextField("Número de Casa", _numeroCasa, (val) => setState(() => _numeroCasa = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Tipo de familia", _tipoFamilia, tiposFamilia, (val) => setState(() => _tipoFamilia = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Funcionalidad", _funcionalidad, funcionalidades, (val) => setState(() => _funcionalidad = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Integrantes", _integrantes, integrantes, (val) => setState(() => _integrantes = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Habitaciones", _habitaciones, habitaciones, (val) => setState(() => _habitaciones = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Animales domésticos", _animales, siNo, (val) => setState(() => _animales = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Vectores", _vectores, siNo, (val) => setState(() => _vectores = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Techo", _techo, techos, (val) => setState(() => _techo = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Paredes", _paredes, paredes, (val) => setState(() => _paredes = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Piso", _piso, pisos, (val) => setState(() => _piso = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Equipamiento", _equipamiento, estados, (val) => setState(() => _equipamiento = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Condiciones económicas", _condicionesEconomicas, estados, (val) => setState(() => _condicionesEconomicas = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Condiciones higiénicas", _condicionesHigienicas, estados, (val) => setState(() => _condicionesHigienicas = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Abasto de agua", _abastoAgua, abastoAgua, (val) => setState(() => _abastoAgua = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Residuales líquidos", _residualesLiquidos, residualesLiquidos, (val) => setState(() => _residualesLiquidos = val)),
                      const SizedBox(height: 12),
                      _buildDropdown("Residuales sólidos", _residualesSolidos, residualesSolidos, (val) => setState(() => _residualesSolidos = val)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _guardarFamilia,
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _abrirPopupFiltros,
                              icon: const Icon(Icons.filter_alt),
                              label: const Text("Filtrar"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: _familias.isEmpty
                  ? const Center(child: Text("No hay familias registradas"))
                  : ListView.builder(
                itemCount: _familias.length,
                itemBuilder: (context, index) {
                  final f = _familias[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ubicación", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("CDR: ${f['cdr']} | Calle: ${f['calle']} | Nº Casa: ${f['numeroCasa']}"),
                          const Divider(),
                          Text("Datos de la familia", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                              "Familia: ${f['tipo_familia']} - ${f['integrantes']} integrantes\n"
                                  "Habitaciones: ${f['habitaciones']} | Techo: ${f['techo']} | Piso: ${f['piso']}\n"
                                  "Funcionalidad: ${f['funcionalidad']} | Económicas: ${f['condiciones_economicas']} | Higiénicas: ${f['condiciones_higienicas']}\n"
                                  "Agua: ${f['abasto_agua']} | Residuos: ${f['residuales_solidos']}\n"
                                  "Animales: ${f['animales_domesticos']} | Vectores: ${f['vectores']} | Equipamiento: ${f['equipamiento']}"
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarFamilia(f),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarFamilia(f['id']),
                              ),
                            ],
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
