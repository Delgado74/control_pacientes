import 'package:flutter/material.dart';
import 'menu_principal.dart'; // Aquí importas la pantalla del menú principal

class BienvenidaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade300, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo o imagen
            Image.asset(
              'assets/logo.png', // coloca tu logo en assets
              width: 150,
              height: 150,
            ),
            SizedBox(height: 30),
            // Texto de bienvenida
            Text(
              "Bienvenido a la APK de Medicina Familiar",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Esta aplicación te permitirá registrar, filtrar y analizar la información de pacientes y familias, generar informes ASIS y mucho más.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 40),
            // Botón de inicio
            ElevatedButton(
              onPressed: () {
                // Navegar al menú principal
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPrincipalScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Iniciar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}