import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';


class ResumenFamiliasScreen extends StatefulWidget {
  const ResumenFamiliasScreen({super.key});

  @override
  State<ResumenFamiliasScreen> createState() => _ResumenFamiliasScreenState();
}

class _ResumenFamiliasScreenState extends State<ResumenFamiliasScreen> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, int> cdrs = {};
  Map<String, int> tiposFamilia = {};
  Map<String, int> funcionalidades = {};
  Map<String, int> integrantes = {};
  Map<String, int> habitaciones = {};
  Map<String, int> animalesDomesticos = {};
  Map<String, int> vectores = {};
  Map<String, int> techos = {};
  Map<String, int> paredes = {};
  Map<String, int> pisos = {};
  Map<String, int> equipamientos = {};
  Map<String, int> condicionesEconomicas = {};
  Map<String, int> condicionesHigienicas = {};
  Map<String, int> abastoAgua = {};
  Map<String, int> residualesLiquidos = {};
  Map<String, int> residualesSolidos = {};

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final cdrConteo = await dbHelper.contarFamiliasPorCampo('cdr');
    final tipoFamiliaConteo = await dbHelper.contarFamiliasPorCampo('tipo_familia');
    final funcionalidadConteo = await dbHelper.contarFamiliasPorCampo('funcionalidad');
    final integrantesConteo = await dbHelper.contarFamiliasPorCampo('integrantes');
    final habitacionesConteo = await dbHelper.contarFamiliasPorCampo('habitaciones');
    final animalesConteo = await dbHelper.contarFamiliasPorCampo('animales_domesticos');
    final vectoresConteo = await dbHelper.contarFamiliasPorCampo('vectores');
    final techoConteo = await dbHelper.contarFamiliasPorCampo('techo');
    final paredesConteo = await dbHelper.contarFamiliasPorCampo('paredes');
    final pisoConteo = await dbHelper.contarFamiliasPorCampo('piso');
    final equipamientoConteo = await dbHelper.contarFamiliasPorCampo('equipamiento');
    final condicionesEcoConteo = await dbHelper.contarFamiliasPorCampo('condiciones_economicas');
    final condicionesHigConteo = await dbHelper.contarFamiliasPorCampo('condiciones_higienicas');
    final abastoAguaConteo = await dbHelper.contarFamiliasPorCampo('abasto_agua');
    final residualesLiqConteo = await dbHelper.contarFamiliasPorCampo('residuales_liquidos');
    final residualesSolConteo = await dbHelper.contarFamiliasPorCampo('residuales_solidos');

    setState(() {
      cdrs = cdrConteo;
      tiposFamilia = tipoFamiliaConteo;
      funcionalidades = funcionalidadConteo;
      integrantes = integrantesConteo;
      habitaciones = habitacionesConteo;
      animalesDomesticos = animalesConteo;
      vectores = vectoresConteo;
      techos = techoConteo;
      paredes = paredesConteo;
      pisos = pisoConteo;
      equipamientos = equipamientoConteo;
      condicionesEconomicas = condicionesEcoConteo;
      condicionesHigienicas = condicionesHigConteo;
      abastoAgua = abastoAguaConteo;
      residualesLiquidos = residualesLiqConteo;
      residualesSolidos = residualesSolConteo;
      cargando = false;
    });
  }

  /// 🧾 Genera un PDF con el resumen actual y abre el menú de compartir
  Future<void> _exportarPDF() async {
    final pdf = pw.Document();

    pw.Widget buildPdfSection(String titulo, Map<String, int> datos) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...datos.entries.map((e) => pw.Text("${e.key}: ${e.value}")),
          pw.SizedBox(height: 12),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text('Resumen de Familias',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          buildPdfSection('CDR', cdrs),
          buildPdfSection('Tipo de familia', tiposFamilia),
          buildPdfSection('Funcionalidad', funcionalidades),
          buildPdfSection('Integrantes', integrantes),
          buildPdfSection('Habitaciones', habitaciones),
          buildPdfSection('Animales domésticos', animalesDomesticos),
          buildPdfSection('Vectores', vectores),
          buildPdfSection('Techo', techos),
          buildPdfSection('Paredes', paredes),
          buildPdfSection('Piso', pisos),
          buildPdfSection('Equipamiento', equipamientos),
          buildPdfSection('Condiciones económicas', condicionesEconomicas),
          buildPdfSection('Condiciones higiénicas', condicionesHigienicas),
          buildPdfSection('Abasto de agua', abastoAgua),
          buildPdfSection('Residuales líquidos', residualesLiquidos),
          buildPdfSection('Residuales sólidos', residualesSolidos),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Resumen_Familias.pdf');
    await file.writeAsBytes(await pdf.save());

    // 📤 Abre el menú de compartir
    await Share.shareXFiles([XFile(file.path)], text: 'Resumen de Familias en PDF');
  }

  Widget _buildSeccion(String titulo, Map<String,int> datos) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...datos.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Familias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: cargando ? null : _exportarPDF,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildSeccion('CDR', cdrs),
            _buildSeccion('Tipo de familia', tiposFamilia),
            _buildSeccion('Funcionalidad', funcionalidades),
            _buildSeccion('Integrantes', integrantes),
            _buildSeccion('Habitaciones', habitaciones),
            _buildSeccion('Animales domésticos', animalesDomesticos),
            _buildSeccion('Vectores', vectores),
            _buildSeccion('Techo', techos),
            _buildSeccion('Paredes', paredes),
            _buildSeccion('Piso', pisos),
            _buildSeccion('Equipamiento', equipamientos),
            _buildSeccion('Condiciones económicas', condicionesEconomicas),
            _buildSeccion('Condiciones higiénicas', condicionesHigienicas),
            _buildSeccion('Abasto de agua', abastoAgua),
            _buildSeccion('Residuales líquidos', residualesLiquidos),
            _buildSeccion('Residuales sólidos', residualesSolidos),
          ],
        ),
      ),
    );
  }
}
