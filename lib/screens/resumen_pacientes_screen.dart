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

  Map<String, int> edadSexo = {};
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
    'leptospirosis',
    'alcohol',
    'drogar',
    'its',
    'tb',
    'sedentarismo',
    'donantes',
    'social',
    'otro',
  ];

  final List<String> camposEnfermedades = [
    'hta',
    'dm',
    'hlp',
    'ab',
    'ecv',
    'sci',
    'cancer',
    'epoc',
    'sida',
    'fumador',
    'obeso',
    'alcoholico',
    'erc',
    'autismo',
    'cirrosis',
    'droga',
    'otra',
  ];

  final List<String> camposDiscapacidades = [
    'visual',
    'auditiva',
    'fisica',
    'sordociego',
    'lvh',
    'intelectual',
    'mixto',
    'sensitiva',
  ];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final edadSexoConteo = await dbHelper.contarPorEdadSexo();
    final colorPielConteo = await dbHelper.contarPorCampo('color_piel');
    final escolaridadConteo = await dbHelper.contarPorCampo('escolaridad');
    final ocupacionConteo = await dbHelper.contarPorCampo('ocupacion');
    final grupoDispConteo = await dbHelper.contarPorCampo('grupo_disp');
    final embarazadaConteo = await dbHelper.contarPorCampo('embarazada');
    final riesgoPreconcepcionalConteo =
        await dbHelper.contarPorCampo('riesgo_preconcepcional');
    final controlRpcConteo = await dbHelper.contarPorCampo('control_rpc');
    final riesgoConteo = await dbHelper.contarPorFlags(camposRiesgo);
    final enfermedadConteo = await dbHelper.contarPorFlags(camposEnfermedades);
    final discapacidadConteo =
        await dbHelper.contarPorFlags(camposDiscapacidades);

    setState(() {
      edadSexo = edadSexoConteo;
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

  Future<void> _exportarPDF() async {
    final pdf = pw.Document();

    pw.Widget buildSection(String titulo, Map<String, int> datos,
        {bool ocultarTotal = false}) {
      final datosFiltrados = ocultarTotal
          ? (Map<String, int>.from(datos)..remove('TOTAL'))
          : datos;
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          ...datosFiltrados.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
          pw.SizedBox(height: 12),
        ],
      );
    }

    pw.Widget buildSectionEdadSexo(String titulo, Map<String, int> datos) {
      final total = datos['TOTAL'] ?? 0;
      int totalM = 0;
      int totalF = 0;
      for (var entry in datos.entries) {
        if (entry.key.endsWith(' M')) totalM += entry.value;
        if (entry.key.endsWith(' F')) totalF += entry.value;
      }

      final grupos = [
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

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Edad', 'M', 'F', 'Total'],
            data: [
              ...grupos.map((g) {
                final m = datos['$g M'] ?? 0;
                final f = datos['$g F'] ?? 0;
                return [g, '$m', '$f', '${m + f}'];
              }),
              ['Total', '$totalM', '$totalF', '$total'],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center
            },
          ),
          pw.SizedBox(height: 12),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
              child: pw.Text('Resumen de Pacientes',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          buildSectionEdadSexo('Edad y sexo', edadSexo),
          buildSection('Color de piel', coloresPiel),
          buildSection('Escolaridad', escolaridades),
          buildSection('Ocupación', ocupaciones),
          buildSection('Grupo dispensarial', gruposDisp),
          buildSection('Embarazadas', embarazadas, ocultarTotal: true),
          buildSection('Factores de riesgo', factoresRiesgo,
              ocultarTotal: true),
          buildSection('Riesgo preconcepcional', riesgoPreconcepcionales,
              ocultarTotal: true),
          buildSection('Control RPC', controlesRpc, ocultarTotal: true),
          buildSection('Enfermedades', enfermedades, ocultarTotal: true),
          buildSection('Discapacidades', discapacidades, ocultarTotal: true),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Resumen_Pacientes.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)],
        text: 'Resumen de Pacientes en PDF');
  }

  Widget _buildSeccionEdadSexo(String titulo, Map<String, int> datos) {
    final total = datos['TOTAL'] ?? 0;

    int totalM = 0;
    int totalF = 0;
    for (var entry in datos.entries) {
      if (entry.key.endsWith(' M')) totalM += entry.value;
      if (entry.key.endsWith(' F')) totalF += entry.value;
    }

    final grupos = [
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Text('Edad', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('M',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    Text('F',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ],
                ),
                ...grupos.map((g) {
                  final m = datos['$g M'] ?? 0;
                  final f = datos['$g F'] ?? 0;
                  final totalGrupo = m + f;
                  return TableRow(
                    children: [
                      Text(g),
                      Text('$m', textAlign: TextAlign.center),
                      Text('$f', textAlign: TextAlign.center),
                      Text('$totalGrupo',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
                TableRow(
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$totalM',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('$totalF',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('$total',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, Map<String, int> datos,
      {bool ocultarTotal = false}) {
    final datosFiltrados =
        ocultarTotal ? (Map<String, int>.from(datos)..remove('TOTAL')) : datos;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  _buildSeccionEdadSexo('Edad y sexo', edadSexo),
                  _buildSeccion('Color de piel', coloresPiel),
                  _buildSeccion('Escolaridad', escolaridades),
                  _buildSeccion('Ocupación', ocupaciones),
                  _buildSeccion('Grupo dispensarial', gruposDisp),
                  _buildSeccion('Embarazadas', embarazadas, ocultarTotal: true),
                  _buildSeccion('Factores de riesgo', factoresRiesgo,
                      ocultarTotal: true),
                  _buildSeccion(
                      'Riesgo preconcepcional', riesgoPreconcepcionales,
                      ocultarTotal: true),
                  _buildSeccion('Control RPC', controlesRpc,
                      ocultarTotal: true),
                  _buildSeccion('Enfermedades', enfermedades,
                      ocultarTotal: true),
                  _buildSeccion('Discapacidades', discapacidades,
                      ocultarTotal: true),
                ],
              ),
            ),
    );
  }
}
