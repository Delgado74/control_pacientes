import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class LocalizacionScreen extends StatefulWidget {
  const LocalizacionScreen({super.key});

  @override
  State<LocalizacionScreen> createState() => _LocalizacionScreenState();
}

class _LocalizacionScreenState extends State<LocalizacionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? provincia;
  String municipio = '';
  String policlinico = '';
  String consultorio = '';

  final List<String> provincias = [
    'PRI',
    'ART',
    'MYB',
    'LHB',
    'IJV',
    'MTZ',
    'CFG',
    'VCL',
    'SSP',
    'CAV',
    'CMG',
    'LTU',
    'HOL',
    'SCU',
    'GRM',
    'GMT'
  ];

  Future<void> _guardarLocalizacion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final datosLocalizacion = {
        'provincia': provincia,
        'municipio': municipio,
        'policlinico': policlinico,
        'consultorio': consultorio,
      };

      // Guardar en SQLite
      await DatabaseHelper.instance.insertarLocalizacion(datosLocalizacion);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados correctamente')),
      );

      // Limpiar formulario
      _formKey.currentState!.reset();
      setState(() {
        provincia = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Localización'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Provincia
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Provincia',
                  border: OutlineInputBorder(),
                ),
                initialValue: provincia, // ⚡ Ajuste moderno
                items: provincias
                    .map((prov) => DropdownMenuItem(
                          value: prov,
                          child: Text(prov),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => provincia = val),
                validator: (value) => value == null || value.isEmpty
                    ? 'Seleccione una provincia'
                    : null,
              ),
              const SizedBox(height: 16),

              // Municipio
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => municipio = val ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese el municipio'
                    : null,
              ),
              const SizedBox(height: 16),

              // Policlínico
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Policlínico',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => policlinico = val ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese el policlínico'
                    : null,
              ),
              const SizedBox(height: 16),

              // Consultorio médico
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Consultorio médico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => consultorio = val ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese el número de consultorio'
                    : null,
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              ElevatedButton(
                onPressed: _guardarLocalizacion,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blue.shade700,
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
