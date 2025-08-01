# Kybers Flutter IPTV

Una aplicación Flutter para Android que permite ver canales IPTV mediante streams HLS/M3U8, con integración de Xtream Codes API, gestión de múltiples perfiles de usuario y sistema de cache inteligente.

## 📱 Características

- **Gestión de perfiles**: Soporte para múltiples cuentas IPTV con credenciales independientes
- **Autenticación inteligente**: Sistema de login automático con perfiles guardados
- **Cache persistente**: Almacenamiento local de canales y categorías para acceso offline/parcial
- **Reproductor IPTV**: Soporte completo para streams HLS/M3U8
- **Orientación vertical**: Diseñado específicamente para Android en modo portrait
- **Integración con Xtream Codes**: Acceso a categorías y canales
- **Integración con TMDB**: Información enriquecida de programas y películas
- **Diseño Material Dark**: Interfaz moderna y atractiva
- **Búsqueda de canales**: Encuentra canales rápidamente
- **Cache de imágenes**: Optimización de carga de carátulas
- **Pruebas automáticas**: Suite de tests unitarios y de widgets

## 🛠️ Tecnologías

- **Flutter** >=3.0.0
- **Dart** >=3.0.0
- **video_player**: Reproducción de streams HLS
- **http**: Consumo de APIs REST
- **flutter_dotenv**: Gestión de variables de entorno (compatibilidad con configuración legacy)
- **shared_preferences**: Almacenamiento persistente de perfiles y cache
- **cached_network_image**: Cache de imágenes de red

## 🚀 Instalación

1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/Luis-Segura-web/kybers.flutter.git
   cd kybers.flutter
   ```

2. **Instala Flutter** (si no está instalado):
   - Sigue las instrucciones en [flutter.dev](https://flutter.dev/docs/get-started/install)

3. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

4. **Configura las variables de entorno** (opcional para compatibilidad):
   
   Si deseas usar configuración legacy, puedes editar el archivo `.env` en la raíz del proyecto:
   ```env
   XTREAM_HOST=http://tu-servidor-iptv.com:8080
   XTREAM_USER=tu_usuario
   XTREAM_PASS=tu_contraseña
   TMDB_API_KEY=tu_clave_tmdb
   ```
   
   **Nota**: Con el nuevo sistema de perfiles, puedes agregar múltiples configuraciones IPTV directamente desde la aplicación.

5. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

## 🔧 Configuración

### Gestión de Perfiles IPTV

La aplicación ahora utiliza un **sistema de gestión de perfiles** que permite:

- **Múltiples cuentas IPTV**: Agrega y gestiona varios proveedores de servicio
- **Almacenamiento seguro**: Las credenciales se guardan localmente de forma segura
- **Cambio rápido**: Alterna entre diferentes perfiles sin reinstalar
- **Compatibilidad legacy**: Sigue funcionando con archivos `.env` existentes

#### Primer uso
1. Al abrir la aplicación por primera vez, verás la **Pantalla de Gestión de Perfiles**
2. Completa el formulario con los datos de tu proveedor IPTV:
   - **Nombre del perfil**: Un nombre descriptivo (ej: "Mi IPTV Principal")
   - **Host/Servidor**: URL completa del servidor (ej: `http://mi-servidor.com:8080`)
   - **Usuario**: Tu nombre de usuario IPTV
   - **Contraseña**: Tu contraseña IPTV
3. Pulsa **Guardar** y luego selecciona el perfil para comenzar

#### Gestión de perfiles
- **Agregar nuevos perfiles**: Usa el formulario en la parte superior
- **Editar perfiles**: Presiona el ícono de editar junto al perfil
- **Eliminar perfiles**: Presiona el ícono de eliminar (se pedirá confirmación)
- **Cambiar de perfil**: Desde el menú de usuario en la pantalla principal

### Variables de Entorno (Legacy)

El archivo `.env` contiene las siguientes variables que debes configurar:

- `XTREAM_HOST`: URL de tu servidor Xtream Codes (ejemplo: `http://mi-servidor.com:8080`)
- `XTREAM_USER`: Tu nombre de usuario de Xtream Codes
- `XTREAM_PASS`: Tu contraseña de Xtream Codes
- `TMDB_API_KEY`: Tu clave de API de TMDB (obtén una gratis en [themoviedb.org](https://www.themoviedb.org/settings/api))

### TMDB API Key

Para obtener una clave de API de TMDB:
1. Regístrate en [The Movie Database](https://www.themoviedb.org/)
2. Ve a tu perfil > Configuración > API
3. Solicita una clave de API
4. Usa la clave en tu archivo `.env`

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/                      # Modelos de datos
│   ├── channel.dart            # Modelo de canal IPTV
│   ├── category.dart           # Modelo de categoría
│   ├── metadata.dart           # Modelo de metadatos TMDB
│   └── user_profile.dart       # Modelo de perfil de usuario
├── screens/                     # Pantallas principales
│   ├── home_screen.dart        # Pantalla principal con lista de canales
│   ├── player_screen.dart      # Pantalla de reproducción
│   └── login_screen.dart       # Pantalla de gestión de perfiles
├── services/                    # Servicios de API y datos
│   ├── xtream_service.dart     # Servicio Xtream Codes
│   ├── tmdb_service.dart       # Servicio TMDB
│   ├── profile_service.dart    # Gestión de perfiles de usuario
│   └── cache_service.dart      # Sistema de cache persistente
├── widgets/                     # Widgets reutilizables
│   ├── channel_card.dart       # Card para mostrar canales
│   └── connection_test_widget.dart # Widget de test de conexión
└── utils/                       # Utilidades y constantes
    ├── constants.dart          # Constantes de la aplicación
    ├── helpers.dart            # Funciones auxiliares
    └── network_helper.dart     # Utilidades de red
```

## 🎮 Uso de la Aplicación

### Pantalla de Gestión de Perfiles
- **Primer acceso**: Si no hay perfiles configurados, se muestra automáticamente
- **Crear perfil**: Completa el formulario con los datos de tu proveedor IPTV
- **Gestionar perfiles**: Edita, elimina o cambia entre perfiles existentes
- **Seleccionar perfil**: Toca un perfil para activarlo y acceder a los canales

### Pantalla Principal
- **Lista de canales**: Muestra todos los canales del perfil activo
- **Cache inteligente**: Los datos se cargan desde cache primero, luego se actualizan
- **Búsqueda**: Busca canales por nombre
- **Filtro por categoría**: Filtra canales por categoría
- **Información enriquecida**: Muestra carátulas y descripciones cuando están disponibles
- **Gestión de sesión**: Cambia de perfil o cierra sesión desde el menú de usuario

### Pantalla de Reproducción
- **Reproductor de video**: Controles de play/pause y búsqueda
- **Información del programa**: Título, sinopsis, géneros y puntuación
- **Orientación vertical**: Optimizado para uso móvil

### Sistema de Cache
- **Cache automático**: Los canales y categorías se almacenan localmente
- **Expiración inteligente**: El cache se renueva cada hora automáticamente
- **Acceso offline parcial**: Navega por canales guardados sin conexión
- **Cache por perfil**: Cada usuario tiene su propio cache independiente

## 🔒 Seguridad y Privacidad

- **Almacenamiento local seguro**: Los perfiles se guardan cifrados en el dispositivo
- **Sin transmisión de credenciales**: Las credenciales solo se usan localmente
- **Variables sensibles**: El archivo `.env` sigue en `.gitignore` para compatibilidad
- **Gestión independiente**: Cada perfil mantiene sus datos por separado
- **Limpieza de cache**: Posibilidad de limpiar datos almacenados por perfil

## 🛠️ Desarrollo

### Ejecutar en modo debug
```bash
flutter run --debug
```

### Construir para release
```bash
flutter build apk --release
```

### Ejecutar tests
```bash
flutter test
```

### Ejecutar tests específicos
```bash
# Tests unitarios
flutter test test/services/

# Tests de widgets
flutter test test/widgets/

# Test específico
flutter test test/services/profile_service_test.dart
```

### Análisis de código
```bash
flutter analyze
```

## 📝 Notas Importantes

- La aplicación está diseñada específicamente para Android en orientación vertical
- Requiere conexión a internet para cargar streams y metadatos inicialmente
- El sistema de cache permite navegación parcial sin conexión
- Los perfiles se almacenan localmente y no se sincronizan entre dispositivos
- El rendimiento puede variar según la calidad del stream y la conexión
- Cada perfil mantiene su propio cache independiente

## 🧪 Testing

La aplicación incluye una suite completa de tests:

### Tests Unitarios
- **ProfileService**: Gestión de perfiles de usuario
- **CacheService**: Sistema de cache persistente  
- **XtreamService**: Integración con API de Xtream Codes

### Tests de Widgets
- **LoginScreen**: Pantalla de gestión de perfiles
- **PlayerScreen**: Pantalla de reproducción

### Ejecutar todos los tests
```bash
flutter test
```

## 🐛 Solución de Problemas

### Problemas de autenticación
- **Sin perfiles**: Si no aparece ningún perfil, crea uno nuevo con las credenciales correctas
- **Error de credenciales**: Verifica host, usuario y contraseña en el perfil
- **Servidor no responde**: Comprueba que el servidor IPTV esté funcionando

### Error de conexión
- Verifica que las URLs y credenciales en el perfil sean correctas
- Asegúrate de tener conexión a internet
- Prueba el test de conexión desde la aplicación

### Video no reproduce
- Verifica que el stream M3U8 sea válido
- Algunos streams pueden requerir configuración adicional
- Intenta con otro canal para aislar el problema
- Comprueba la conexión de red

### Problemas de cache
- **Cache corrupto**: Elimina el perfil y vuelve a crearlo
- **Datos obsoletos**: El cache se renueva automáticamente cada hora
- **Espacio insuficiente**: El cache se limpia automáticamente

### Imágenes no cargan
- Verifica tu clave de TMDB API en el archivo `.env`
- Comprueba la conexión a internet
- Algunas imágenes pueden no estar disponibles en TMDB

## 📄 Licencia

Este proyecto es de código abierto. Úsalo responsablemente y respeta los términos de servicio de los proveedores de IPTV y APIs.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

**Nota**: Este proyecto es para fines educativos. Asegúrate de cumplir con las leyes locales y los términos de servicio al usar contenido IPTV.