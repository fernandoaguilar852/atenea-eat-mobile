# ATENEA EAT - Mobile App

Aplicación móvil Flutter para gestión de restaurantes - Sistema POS.

## 📱 Descripción

ATENEA EAT es una aplicación móvil multiplataforma (iOS y Android) diseñada para la gestión integral de restaurantes, siguiendo los principios de Clean Architecture.

## ✨ Características Implementadas

- ✅ Pantalla de Login con diseño responsive
- ✅ Dashboard con estadísticas en tiempo real
  - Mesas ocupadas/totales
  - Facturación del día
  - Comandas de cocina
  - Inventario
- ✅ Navegación con drawer (menú lateral)
- ✅ Tema de colores consistente con la versión web
- ✅ Arquitectura Clean (Domain, Data, Presentation)
- ✅ State Management con Riverpod
- ✅ Diseño responsive con ScreenUtil

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con tres capas:

```
lib/
├── core/                           # Núcleo de la aplicación
│   ├── config/                     # Configuraciones
│   ├── constants/                  # Constantes (API, etc.)
│   ├── providers/                  # Providers globales
│   ├── services/                   # Servicios (Storage, Auth, etc.)
│   ├── theme/                      # Tema de la app
│   └── utils/                      # Utilidades
│
├── features/                       # Módulos de funcionalidades
│   ├── auth/                       # Autenticación
│   │   ├── data/
│   │   │   ├── datasources/       # API calls
│   │   │   ├── models/            # DTOs
│   │   │   ├── mappers/           # DTO → Entity
│   │   │   └── repositories/      # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/          # Entidades de negocio
│   │   │   └── repositories/      # Repository interfaces
│   │   └── presentation/
│   │       ├── providers/         # State management
│   │       ├── screens/           # Pantallas
│   │       └── widgets/           # Widgets reutilizables
│   │
│   └── dashboard/                 # Dashboard principal
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── shared/                        # Componentes compartidos
    └── widgets/                   # Widgets globales
```

## 🎨 Diseño

Los colores y diseño están basados en la versión web de ATENEA POS:

- **Primario**: `#0d6efd` (Azul)
- **Éxito**: `#198754` (Verde)
- **Peligro**: `#dc3545` (Rojo)
- **Advertencia**: `#ffc107` (Amarillo)
- **Info**: `#0dcaf0` (Cyan)

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK 3.7.2 o superior
- Dart 3.7.2 o superior
- Xcode (para iOS)
- Android Studio (para Android)

### Pasos

1. **Instalar dependencias**
   ```bash
   cd atenea-eat-mobile
   flutter pub get
   ```

2. **Ejecutar la app**

   Para iOS:
   ```bash
   flutter run -d ios
   ```

   Para Android:
   ```bash
   flutter run -d android
   ```

## 📦 Dependencias Principales

- `flutter_riverpod` - State Management
- `go_router` - Navegación
- `dio` - HTTP Client
- `flutter_screenutil` - Diseño responsive
- `hive` - Base de datos local
- `flutter_secure_storage` - Almacenamiento seguro
- `local_auth` - Autenticación biométrica
- `fl_chart` - Gráficos y estadísticas

## 📱 Pantallas Implementadas

### 1. Login Screen (`/login`)
- Campos de email y contraseña
- Validaciones de formulario
- Toggle para mostrar/ocultar contraseña
- Estado de carga durante login
- Diseño responsive

### 2. Dashboard Screen (`/dashboard`)
- Tarjetas de estadísticas
- Actividad reciente
- Menú lateral (drawer) con navegación
- Pull to refresh

## 🎯 Estado del Proyecto

- ✅ Login funcional (UI completa)
- ✅ Dashboard con estadísticas (UI completa)
- ✅ Navegación configurada
- ✅ Tema de colores aplicado
- ⏳ Integración con API (pendiente)
- ⏳ Autenticación real (pendiente)
- ⏳ Módulos adicionales (pendiente)

---

**Versión**: 1.0.0+1
**Última actualización**: Octubre 2026
**Desarrollado por**: HIDRASOFT S.A.S.
