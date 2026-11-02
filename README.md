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
- ✅ **Manejo automático de expiración de token JWT**
  - Detección de error 401 en todas las peticiones
  - Cierre de sesión automático
  - Redirección al login
  - Limpieza de credenciales almacenadas

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con tres capas:

```
lib/
├── core/                           # Núcleo de la aplicación
│   ├── config/                     # Configuraciones
│   ├── constants/                  # Constantes (API, etc.)
│   ├── providers/                  # Providers globales (Dio con interceptores)
│   ├── services/                   # Servicios
│   │   ├── credentials_storage_service.dart
│   │   └── navigation_service.dart  # Navegación global sin context
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

### Tema Oscuro Profesional (estilo Instagram)

La app utiliza un **tema oscuro elegante** con fondo negro que hace resaltar los colores vibrantes de los elementos importantes:

**Colores del tema:**
- **Fondo Principal**: `#000000` (Negro puro)
- **Superficies/Cards**: `#1a1a1a` (Gris muy oscuro)
- **Bordes**: `#363636` (Gris oscuro sutil)
- **Texto Principal**: `#FFFFFF` (Blanco)
- **Texto Secundario**: `#B0B0B0` (Gris claro)
- **Texto Terciario**: `#808080` (Gris medio)

**Colores vibrantes** (solo en cards y elementos de acción):
- **Primario**: `#0d6efd` (Azul) - Mesas
- **Éxito**: `#198754` (Verde) - Facturación
- **Advertencia**: `#ffc107` (Amarillo) - Cocina
- **Peligro**: `#dc3545` (Rojo) - Inventario
- **Info**: `#0dcaf0` (Cyan)

El contraste entre el fondo negro y los colores vibrantes crea una experiencia visual moderna y profesional, perfecta para destacar imágenes de productos y platos.

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
- `go_router` - Navegación declarativa
- `dio` - HTTP Client con interceptores
- `flutter_screenutil` - Diseño responsive
- `hive` - Base de datos local
- `flutter_secure_storage` - Almacenamiento seguro de tokens
- `local_auth` - Autenticación biométrica
- `fl_chart` - Gráficos y estadísticas

## 📱 Pantallas Implementadas

### 1. Login Screen (`/login`)
- Campos de email y contraseña
- Validaciones de formulario
- Toggle para mostrar/ocultar contraseña
- Estado de carga durante login
- Diseño responsive

### 2. Main Screen (`/main`)
- **Bottom Navigation Bar** con 5 secciones:
  - Mesas (índice 0)
  - Órdenes (índice 1)
  - Dashboard (índice 2 - centro con diseño especial)
  - Facturación (índice 3)
  - Inventario (índice 4)
- **Drawer lateral izquierdo** (menú hamburguesa)
  - Header con avatar y datos de usuario
  - Navegación principal
  - Cerrar sesión con confirmación
- **Drawer lateral derecho** (notificaciones)
  - Se abre al hacer clic en el icono de notificaciones
  - Tabs: Pendientes y Leídas
  - Indicadores de prioridad (Crítica, Alta, Media, Baja)
  - Acciones: Marcar como leída / Eliminar
- **IndexedStack** para preservar el estado de cada pantalla

### 3. Dashboard Screen
- Tarjetas de estadísticas (Mesas, Facturación, Cocina, Inventario)
- Actividad reciente
- Pull to refresh
- Saludo dinámico según hora del día

## 🔒 Seguridad y Autenticación

### Manejo de Token JWT

La aplicación implementa un sistema robusto de manejo de tokens JWT:

**Interceptor Global de Dio** (`core/providers/dio_provider.dart`):
- Detecta automáticamente errores 401 (Unauthorized)
- Limpia tokens almacenados en secure storage
- Redirige al login usando NavigationService
- Previene estados inconsistentes

**Flujo de Expiración:**
```
Usuario hace petición → Token expirado en servidor → 401 Response
    ↓
Interceptor detecta 401
    ↓
1. Limpia tokens del storage
2. Redirige a /login
    ↓
Usuario vuelve al login automáticamente
```

**Ventajas:**
- ✅ Automático en todas las peticiones HTTP
- ✅ No requiere código adicional en cada módulo
- ✅ Navegación sin BuildContext usando NavigationService
- ✅ Experiencia de usuario fluida

## 🎯 Estado del Proyecto

- ✅ Login funcional (UI completa con tema oscuro)
- ✅ Dashboard con estadísticas (UI completa con cards vibrantes)
- ✅ Navegación con Bottom Navigation Bar (5 secciones)
- ✅ Drawer lateral izquierdo con menú hamburguesa
- ✅ Drawer lateral derecho con notificaciones (Pendientes/Leídas)
- ✅ IndexedStack para preservar estado de pantallas
- ✅ **Tema oscuro profesional estilo Instagram**
  - Fondo negro (#000000)
  - Cards con colores vibrantes
  - Tipografía optimizada para contraste
  - Bordes sutiles y modernos
- ✅ **Seguridad JWT**
  - Manejo automático de token expirado
  - Almacenamiento seguro de credenciales
  - Interceptores HTTP globales
- ✅ Arquitectura Clean implementada
- ✅ Integración con API real
- ✅ Autenticación con JWT
- ✅ Módulos implementados: Dashboard, Ventas, Movimientos, Productos, Insumos, Reportes

## 🛠️ Servicios Core

### NavigationService
Servicio singleton para navegación global sin BuildContext:
- `navigateToLogin()` - Redirige al login
- `navigateToMain()` - Redirige al main
- `goBack()` - Retrocede en navegación

Usado principalmente por el interceptor de Dio para manejar 401.

### CredentialsStorageService
Almacenamiento seguro usando Flutter Secure Storage:
- Tokens JWT (access y refresh)
- Credenciales de usuario (con biometría)
- Métodos de limpieza automática

---

**Versión**: 1.0.0+1
**Última actualización**: Noviembre 2026
**Desarrollado por**: HIDRASOFT S.A.S.
