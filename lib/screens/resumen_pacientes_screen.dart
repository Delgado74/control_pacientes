import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';

class ResumenPacientesScreen extends StatefulWidget {
  const ResumenPacientesScreen({super.key});

  @override
  State<ResumenPacientesScreen> createState() => _ResumenPacientesScreenState();
}

class _ResumenPacientesScreenState extends State<ResumenPacientesScreen> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, int> edades = {};
  Map<String, int> sexos = {};
  Map<String, int> coloresPiel = {};
  Map<String, int> escolaridades = {};
  Map<String, int> ocupaciones = {};
  Map<String, int> gruposDisp = {};
  Map<String, int> embarazadas = {};
  Map<String, int> factoresRiesgo = {};
  Map<String, int> riesgoPreconcepcionales = {};
  Map<String, int> controlesRpc = {};
  Map<String, int> enfermedades = {};
  Map<String, int> discapacidades = {};

  final List<String> camposRiesgo = [
    'leptospirosis','alcohol','drogar','its','tb','sedentarismo','donantes','social','otro',
  ];

  final List<String> camposEnfermedades = [
    'hta','dm','hlp','ab','ecv','sci','cancer','epoc','sida','fumador','obeso','alcoholico','erc','autismo','cirrosis','droga','otra',
  ];

  final List<String> camposDiscapacidades = [
    'visual','auditiva','fisica','sordociego','lvh','intelectual','mixto','sensitiva',
  ];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final edadesConteo = await dbHelper.contarPorEdad();
    final sexosConteo = await dbHelper.contarPorCampo('sexo');
    final colorPielConteo = await dbHelper.contarPorCampo('color_piel');
    final escolaridadConteo = await dbHelper.contarPorCampo('escolaridad');
    final ocupacionConteo = await dbHelper.contarPorCampo('ocupacion');
    final grupoDispConteo = await dbHelper.contarPorCampo('grupo_disp');
    final embarazadaConteo = await dbHelper.contarPorCampo('embarazada');
    final riesgoPreconcepcionalConteo = await dbHelper.contarPorCampo('riesgo_preconcepcional');
    final controlRpcConteo = await dbHelper.contarPorCampo('control_rpc');
    final riesgoConteo = await dbHelper.contarPorFlags(camposRiesgo);
    final enfermedadConteo = await dbHelper.contarPorFlags(camposEnfermedades);
    final discapacidadConteo = await dbHelper.contarPorFlags(camposDiscapacidades);

    setState(() {
      edades = edadesConteo;
      sexos = sexosConteo;
      coloresPiel = colorPielConteo;
      escolaridades = escolaridadConteo;
      ocupaciones = ocupacionConteo;
      gruposDisp = grupoDispConteo;
      embarazadas = embarazadaConteo;
      factoresRiesgo = riesgoConteo;
      riesgoPreconcepcionales = riesgoPreconcepcionalConteo;
      controlesRpc = controlRpcConteo;
      enfermedades = enfermedadConteo;
      discapacidades = discapacidadConteo;
      cargando = false;
    });
  }

  /// 🧾 Genera PDF con resumen de pacientes y abre menú de compartir
  Future<void> _exportarPDF() async {
    final pdf = pw.Document();

    pw.Widget buildSection(String titulo, Map<String,int> datos) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...datos.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
          pw.SizedBox(height: 12),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(child: pw.Text('Resumen de Pacientes', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          buildSection('Edades', edades),
          buildSection('Sexo', sexos),
          buildSection('Color de piel', coloresPiel),
          buildSection('Escolaridad', escolaridades),
          buildSection('Ocupación', ocupaciones),
          buildSection('Grupo dispensarial', gruposDisp),
          buildSection('Embarazadas', embarazadas),
          buildSection('Factores de riesgo', factoresRiesgo),
          buildSection('Riesgo preconcepcional', riesgoPreconcepcionales),
          buildSection('Control RPC', controlesRpc),
          buildSection('Enfermedades', enfermedades),
          buildSection('Discapacidades', discapacidades),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Resumen_Pacientes.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Resumen de Pacientes en PDF');
  }

  Widget _buildSeccion(String titulo, Map<String,int> datos, {bool ocultarTotal = false}) {
    final datosFiltrados = ocultarTotal
        ? (Map<String,int>.from(datos)..remove('TOTAL'))
        : datos;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...datosFiltrados.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Pacientes'),
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
            _buildSeccion('Edades', edades),
            _buildSeccion('Sexo', sexos),
            _buildSeccion('Color de piel', coloresPiel),
            _buildSeccion('Escolaridad', escolaridades),
            _buildSeccion('Ocupación', ocupaciones),
            _buildSeccion('Grupo dispensarial', gruposDisp),
            _buildSeccion('Embarazadas', embarazadas, ocultarTotal: true),
            _buildSeccion('Factores de riesgo', factoresRiesgo, ocultarTotal: true),
            _buildSeccion('Riesgo preconcepcional', riesgoPreconcepcionales),
            _buildSeccion('Control RPC', controlesRpc, ocultarTotal: true),
            _buildSeccion('Enfermedades', enfermedades, ocultarTotal: true),
            _buildSeccion('Discapacidades', discapacidades, ocultarTotal: true),
          ],
        ),
      ),
    );
  }
}
