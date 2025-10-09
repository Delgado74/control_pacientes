import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});

  // Función para abrir links
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("No se pudo abrir: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acerca de"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Acerca de la Aplicación",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "El objetivo fundamental de esta aplicación es facilitar el trabajo "
                  "en los consultorios de médicos de familia, permitiendo un mejor "
                  "control de la población. La aplicación es susceptible de ser mejorada "
                  "para ampliar sus funciones, haciendo más humano el trabajo del médico "
                  "familiar mediante el uso de la tecnología, y mejorando de esta manera "
                  "la calidad de atención a los pacientes, quienes al final son nuestra "
                  "razón de ser.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "Funciones:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Actuales: \n"
                  "- Registro de pacientes y familias.\n"
                  "- Generación de reportes y resúmenes útiles para realizar el ASIS.\n"
                  "- Exportación de datos a Excel. \n"
                  "- Exportar e Importar la Base de Datos.\n"
                  "- Exportar el Resumen de Familias y Pacientes en formato PDF.\n"
                  "- Programación de próximo control.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "Esta aplicación está diseñada para crecer y adaptarse a las necesidades "
                  "de los profesionales de la salud, siempre buscando mejorar la eficiencia "
                  "y la atención al paciente.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Versión: v1.0.0 alpha",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Contacto para sugerencias, mejoras o reporte de errores:",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),

            // Botón para Email
            InkWell(
              onTap: () => _launchURL("mailto:yuridelgadoamaran@gmail.com"),
              child: const Text(
                "📧 Email: yuridelgadoamaran@gmail.com",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botón para WhatsApp
            InkWell(
              onTap: () => _launchURL("https://wa.me/5351558093"),
              child: const Text(
                "💬 WhatsApp: (+53) 51558093",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
