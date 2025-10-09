import 'package:flutter/material.dart';
import 'menu_screen.dart'; // Aquí importas la pantalla del menú principal

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade300, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo o imagen
            Image.asset(
              'assets/images/logo.png', // coloca tu logo en assets
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            // Texto de bienvenida
            const Text(
              "Bienvenido a MedFamCare (MFC)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Párrafo introductorio breve
            const Text(
              "Gestión de Medicina Familiar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            // Botón de inicio
            ElevatedButton(
              onPressed: () {
                // Navegar al menú principal
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MenuPrincipalScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Iniciar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            // Pie con slogan y autor
            Column(
              children: const [
                Text(
                  "Una APK para los médicos, hecha por un médico",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "DEV: Yuri Delgado Amarán © 2025",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
