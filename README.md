# Kybers Flutter IPTV

Una aplicación Flutter para Android que permite ver canales IPTV mediante streams HLS/M3U8, con integración de Xtream Codes API y TMDB para información enriquecida.

## 📱 Características

- **Reproductor IPTV**: Soporte completo para streams HLS/M3U8
- **Orientación vertical**: Diseñado específicamente para Android en modo portrait
- **Integración con Xtream Codes**: Acceso a categorías y canales
- **Integración con TMDB**: Información enriquecida de programas y películas
- **Diseño Material Dark**: Interfaz moderna y atractiva
- **Búsqueda de canales**: Encuentra canales rápidamente
- **Cache de imágenes**: Optimización de carga de carátulas

## 🛠️ Tecnologías

- **Flutter** >=3.0.0
- **Dart** >=3.0.0
- **video_player**: Reproducción de streams HLS
- **http**: Consumo de APIs REST
- **flutter_dotenv**: Gestión de variables de entorno
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

4. **Configura las variables de entorno**:
   
   Edita el archivo `.env` en la raíz del proyecto:
   ```env
   XTREAM_HOST=http://tu-servidor-iptv.com:8080
   XTREAM_USER=tu_usuario
   XTREAM_PASS=tu_contraseña
   TMDB_API_KEY=tu_clave_tmdb
   ```

5. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

## 🔧 Configuración

### Variables de Entorno

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
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── channel.dart         # Modelo de canal IPTV
│   ├── category.dart        # Modelo de categoría
│   └── metadata.dart        # Modelo de metadatos TMDB
├── screens/                 # Pantallas principales
│   ├── home_screen.dart     # Pantalla principal con lista de canales
│   └── player_screen.dart   # Pantalla de reproducción
├── services/                # Servicios de API
│   ├── xtream_service.dart  # Servicio Xtream Codes
│   └── tmdb_service.dart    # Servicio TMDB
├── widgets/                 # Widgets reutilizables
│   └── channel_card.dart    # Card para mostrar canales
└── utils/                   # Utilidades y constantes
    ├── constants.dart       # Constantes de la aplicación
    └── helpers.dart         # Funciones auxiliares
```

## 🎮 Uso de la Aplicación

### Pantalla Principal
- **Lista de canales**: Muestra todos los canales disponibles
- **Búsqueda**: Busca canales por nombre
- **Filtro por categoría**: Filtra canales por categoría
- **Información enriquecida**: Muestra carátulas y descripciones cuando están disponibles

### Pantalla de Reproducción
- **Reproductor de video**: Controles de play/pause y búsqueda
- **Información del programa**: Título, sinopsis, géneros y puntuación
- **Orientación vertical**: Optimizado para uso móvil

## 🔒 Seguridad

- Las variables sensibles se almacenan en el archivo `.env`
- El archivo `.env` está incluido en `.gitignore` para evitar commits accidentales
- Usa conexiones HTTPS cuando sea posible

## 🛠️ Desarrollo

### Ejecutar en modo debug
```bash
flutter run --debug
```

### Construir para release
```bash
flutter build apk --release
```

### Análisis de código
```bash
flutter analyze
```

## 📝 Notas Importantes

- La aplicación está diseñada específicamente para Android en orientación vertical
- Requiere conexión a internet para cargar streams y metadatos
- El rendimiento puede variar según la calidad del stream y la conexión
- Asegúrate de tener las credenciales correctas de Xtream Codes

## 🐛 Solución de Problemas

### Error de conexión
- Verifica que las URLs y credenciales en `.env` sean correctas
- Asegúrate de tener conexión a internet
- Comprueba que el servidor Xtream Codes esté funcionando

### Video no reproduce
- Verifica que el stream M3U8 sea válido
- Algunos streams pueden requerir configuración adicional
- Intenta con otro canal para aislar el problema

### Imágenes no cargan
- Verifica tu clave de TMDB API
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