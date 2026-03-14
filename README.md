# Medical Family Care (MFC)

Aplicación de gestión integral para consultorios de Medicina Familiar. Controla pacientes, familias y áreas de trabajo de forma eficiente.

## Características

### Gestión de Pacientes
- Registro completo de pacientes con datos demográficos
- Historial médico y seguimiento
- Clasificación por riesgo y condiciones de salud
- Búsqueda y filtrado avanzado

### Control Familiar
- Registro de familias y núcleos hogar
- Seguimiento integral por grupo familiar
- Identificación de factores de riesgo familiares

### Localización
- Configuración de áreas de trabajo (consultorios, clínicas)
- Organización por zonas geográficas

### Exportación e Importación
- Exportación a Excel (.xlsx)
- Exportación e importación de base de datos SQLite
- Compartir datos fácilmente

## Tecnologías

- **Framework**: Flutter 3.x
- **Base de datos**: SQLite (sqflite)
- **Exportación**: Excel, PDF
- **Plataformas**: Android, iOS, Web, Desktop (Windows, macOS, Linux)

## Requisitos

- Flutter SDK 3.0+
- Dart 3.0+

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/Delgado74/control_pacientes.git

# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run
```

## Estructura del Proyecto

```
lib/
├── db/              # Base de datos SQLite
├── helpers/         # Utilidades para Excel
├── screens/         # Pantallas de la aplicación
├── theme/           # Colores y temas
└── utils/           # Funciones auxiliares
```

## Licencia

MIT License
