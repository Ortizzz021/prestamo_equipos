# G61-1 Préstamo de equipos tecnológicos

Proyecto final de Desarrollo Móvil, Universidad de Medellín, 2026-2.

## Integrantes

| Nombre | Usuario de GitHub |
| --- | --- |
| Juan Pablo Berrío Díaz | berrip |
| Daniel Ortiz Ortiz | Ortizzz021 |

## Caso

Aplicación Android para solicitar en préstamo equipos tecnológicos (portátiles, tablets, cámaras, proyectores y audio) de una bodega institucional. Un solicitante consulta el catálogo, elige un equipo y una franja horaria y envía la solicitud. Un coordinador la aprueba o la rechaza, y el encargado de bodega registra la entrega y la devolución del equipo.

Las solicitudes se guardan primero en el dispositivo y se sincronizan con Firestore cuando hay conexión, de modo que la app sigue funcionando sin internet.

## Roles

| Rol | Valor en `users/{uid}.rol` | Qué puede hacer |
| --- | --- | --- |
| Solicitante | `solicitante` | Ver catálogo y detalle, filtrar por categoría, solicitar un préstamo por franja, ver sus préstamos, cancelar solicitudes en estado Solicitado o Aprobado y reintentar o descartar las rechazadas por el servidor. |
| Coordinador | `coordinador` | Ver la bandeja de solicitudes pendientes, aprobar (ocupa la franja) o rechazar con motivo, y bloquear o desbloquear equipos con motivo. |
| Encargado de bodega | `bodega` | Registrar la entrega de solicitudes aprobadas y la devolución de equipos entregados, con observación. La devolución libera la franja. |

Toda cuenta nueva se registra como `solicitante`. Los roles `coordinador` y `bodega` se asignan editando el campo `rol` del documento `users/{uid}` desde Firebase Console; las reglas impiden que un usuario cambie su propio rol.

### Estados de una solicitud

```
SOLICITADO ──(coordinador)──> APROBADO ──(bodega)──> ENTREGADO ──(bodega)──> DEVUELTO
     │                            │
     ├──(coordinador)──> RECHAZADO│
     └──(solicitante)──> CANCELADO <──(solicitante)
```

Franjas fijas por día: 08:00-10:00, 10:00-12:00, 14:00-16:00 y 16:00-18:00. Una franja aprobada queda ocupada para ese equipo hasta que la solicitud se cancela o el equipo se devuelve.

## Requisitos y ejecución

- Flutter estable con Dart `^3.12.2` (probado con Flutter 3.47).
- Android SDK con un emulador con Google APIs (API 34 o superior recomendado) o un celular Android 6.0+ con depuración USB.
- JDK 17 o superior.

```bash
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Para regenerar el código de Drift después de cambiar las tablas:

```bash
dart run build_runner build --delete-conflicting-outputs
```

La app está pensada para Android. No se soporta la versión web.

## Configuración de Firebase

Proyecto: `prestamo-equipos-36c3c`. Servicios usados: Authentication (correo y contraseña), Cloud Firestore y Crashlytics.

- `android/app/google-services.json` y `lib/firebase_options.dart` se generaron con `flutterfire configure`.
- En Authentication debe estar habilitado el proveedor **Correo electrónico/contraseña**.
- Reglas e índices de Firestore se publican desde la raíz del proyecto:

```bash
firebase deploy --only firestore
```

Esto publica `firestore.rules` y `firestore.indexes.json`. Sin el índice compuesto `estado` + `creadaEn`, las bandejas de coordinador y bodega no cargan.

Para usar otro proyecto de Firebase, ejecutar `flutterfire configure` con ese proyecto, publicar reglas e índices y crear las cuentas de prueba.

## Endpoint del catálogo

El catálogo se consulta por HTTP GET y responde un arreglo JSON:

```
https://raw.githubusercontent.com/Ortizzz021/prestamo_equipos/main/api/equipos.json
```

El archivo fuente está en `api/equipos.json` (10 equipos). Cada elemento tiene `id`, `nombre`, `categoria`, `descripcion` e `imagen`. La URL se puede cambiar al compilar con `--dart-define=CATALOGO_URL=<url>`.

Manejo de errores (`lib/core/errors/api_exception.dart`): sin conexión, tiempo agotado (10 s), respuesta HTTP no exitosa, formato inválido y error inesperado. Cada caso muestra un mensaje en pantalla, con botón de reintento cuando el error es temporal (sin conexión, tiempo agotado, errores 5xx, 408 o 429).

## Arquitectura

```
lib/
  core/        configuración, errores, preferencias, tema, fechas y logging
  domain/      modelos y reglas de negocio (estados, franjas, roles)
  data/
    remote/    API HTTP del catálogo y fuentes de datos de Firestore
    local/     base de datos Drift
    repositories/
    sync/      sincronización local ↔ Firestore
  features/    pantallas por módulo (auth, catálogo, solicitudes, coordinación, bodega, diagnóstico)
```

Estado con `provider`. Las pantallas usan repositorios y no acceden directamente a Firebase, HTTP ni Drift.

## Modelo de datos

### Firestore

| Colección | Documento | Campos |
| --- | --- | --- |
| `users` | `{uid}` | `uid`, `nombre`, `email`, `rol`, `creadoEn` |
| `solicitudes` | `{id}` (UUID v4 generado en el dispositivo) | `id`, `solicitanteUid`, `equipoId`, `equipoNombre`, `fecha`, `fechaClave`, `slot`, `franjaId`, `estado`, `version`, `creadaEn`, `actualizadaEn` y, según el estado: `aprobadoPor/En`, `rechazadoPor/En`, `motivoRechazo`, `entregadoPor/En`, `observacionEntrega`, `devueltoPor/En`, `observacionDevolucion`, `canceladaEn` |
| `franjas` | `{equipoId}_{yyyyMMdd}_{slot}` | `equipoId`, `fechaClave`, `slot`, `solicitudId`, `ocupadaEn` |
| `equipos_estado` | `{equipoId}` | `bloqueado`, `motivo`, `actualizadoPor`, `actualizadoEn` |

### Local (Drift)

Tabla `solicitudes` con los datos de la solicitud y además `ownerUid`, `version`, `estadoSync` (`PENDIENTE`, `SINCRONIZADO`, `RECHAZADO`) y `ultimoError`.

### SharedPreferences

`catalogo.categoria`: última categoría elegida en el filtro del catálogo.

## Reglas de seguridad

Están en `firestore.rules`. En resumen:

- Solo usuarios autenticados acceden a los datos y el rol se lee de `users/{uid}`.
- El solicitante solo crea solicitudes propias en estado `SOLICITADO`, solo lee las suyas y solo puede cancelarlas.
- El coordinador aprueba o rechaza solicitudes de otras personas y administra el bloqueo de equipos.
- Bodega solo registra entrega (desde `APROBADO`) y devolución (desde `ENTREGADO`).
- Cada cambio limita los campos que se pueden tocar, exige la marca de tiempo del servidor y aumenta `version`. No se permite borrar solicitudes ni perfiles.
- `franjas` solo la crea el coordinador en la misma transacción que aprueba, y solo la borran bodega al registrar la devolución o el dueño al cancelar una solicitud aprobada.

Las reglas se verificaron en el emulador de Firestore con las mismas operaciones que hace la app (registro, envío y reenvío, bandejas, aprobación, rechazo, cancelación, entrega, devolución y bloqueo) y con casos que deben negarse, como un solicitante cambiando su rol o leyendo solicitudes ajenas.

## Estrategia local-first

1. Al crear una solicitud se guarda en Drift como `PENDIENTE` y aparece de inmediato en Mis préstamos, con o sin internet.
2. `SyncService` sube las pendientes al iniciar sesión, al recuperar la conexión, al volver la app a primer plano y con el botón de sincronizar.
3. La subida es una transacción idempotente: si el documento ya existe con el mismo dueño solo se confirma, así un reintento no duplica la solicitud.
4. Fallas temporales (sin red, tiempo agotado) dejan la solicitud pendiente para el siguiente intento. Rechazos del servidor (permisos o datos inválidos) la marcan `RECHAZADO` con el motivo, y el usuario puede reintentar o descartar.
5. Un listener en tiempo real trae los cambios que hacen coordinador y bodega y los aplica en Drift. Si hay un cambio local más reciente sin sincronizar, no se sobrescribe.
6. Las acciones de coordinador, bodega y la cancelación de una solicitud ya enviada requieren conexión, porque dependen de transacciones sobre franjas compartidas.
7. Al cambiar de cuenta se detiene la subida de pendientes de la cuenta anterior; cada usuario solo ve sus propios registros locales.

## Privacidad y Crashlytics

- Crashlytics solo recolecta en compilaciones release; en debug está apagado salvo desde la pantalla de diagnóstico.
- Se reportan errores fatales, excepciones no controladas, fallas de red y errores inesperados. Las validaciones de negocio no se reportan.
- Se envía el tipo de error y la traza, no el mensaje. El usuario se identifica solo por su UID de Firebase; no se envían nombre, correo ni contraseña, y los textos de log se limpian de correos y tokens.
- Claves personalizadas: `app_version` y `build_mode`.
- Configuración, procedimiento y evidencia: [`docs/crashlytics.md`](docs/crashlytics.md).

## Generar y firmar el APK

Versión actual: `1.0.0+1` (campo `version` de `pubspec.yaml`).

1. Crear el keystore una sola vez, fuera del repositorio:

```bash
keytool -genkey -v -keystore %USERPROFILE%\prestamo-equipos.jks -keyalg RSA -keysize 2048 -validity 10000 -alias prestamo
```

2. Crear `android/key.properties` (está en `.gitignore` y no se sube):

```properties
storePassword=<contraseña del keystore>
keyPassword=<contraseña de la llave>
keyAlias=prestamo
storeFile=C:/Users/<usuario>/prestamo-equipos.jks
```

3. Compilar:

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Si `key.properties` no existe, el APK se firma con la llave de depuración, que sirve para instalarlo pero no para publicarlo.

## Documentación de calidad

| Documento | Ruta |
| --- | --- |
| Matriz de QA manual (28 casos ejecutados con resultado y evidencia) | [`docs/matriz_qa.md`](docs/matriz_qa.md) |
| Configuración y evidencia de Crashlytics | [`docs/crashlytics.md`](docs/crashlytics.md) |
| Capturas de las pruebas, nombradas con el ID de cada caso | [`docs/evidencias/`](docs/evidencias) |

## Datos de prueba

**Cuentas por rol.** Hay al menos una cuenta por rol en Firebase Authentication; las contraseñas se entregan aparte y no están en el repositorio.

| Rol | Cuenta | Uso en QA |
| --- | --- | --- |
| Solicitante | Solicitante Uno | Catálogo, solicitudes, sincronización y cancelaciones |
| Solicitante | Solicitante2 | Registro duplicado (QA-02.2) |
| Coordinador | Coordinador | Aprobación, rechazo y bloqueo |
| Encargado de bodega | Bodega | Entrega y devolución |

**Registros HTTP.** El catálogo `api/equipos.json` tiene 10 equipos en 5 categorías (Portátiles, Tablets, Proyectores, Cámaras y Audio).

**Operaciones en distintos estados** (ejecutadas durante la QA):

| Equipo | Franja | Estado | Caso |
| --- | --- | --- | --- |
| Cámara Canon EOS Rebel T7 | sáb 14 nov, 16:00-18:00 | Solicitado → Aprobado → Entregado → Devuelto | QA-07, QA-11, QA-15, QA-16 |
| iPad 10.ª generación | lun 16 nov, 14:00-16:00 | Solicitado sin conexión → Sincronizado → Rechazado | QA-08.1, QA-08.2, QA-12.2 |
| Portátil Dell Latitude 5440 | dom 15 nov, 10:00-12:00 | Solicitado → Cancelado | QA-10.1 |
| Micrófono Blue Yeti | vie 13 nov, 10:00-12:00 | Aprobado → Cancelado | QA-10.2 |
| Audífonos Sony WH-CH720N | — | Equipo bloqueado | QA-14.1 |

## Registro de defectos

| ID | Defecto | Severidad | Corrección | Estado |
| --- | --- | --- | --- | --- |
| DEF-01 | La app abría en blanco en Chrome | Media | Crashlytics se inicializa solo fuera de web; la app se orienta a Android | Cerrado |
| DEF-02 | Un error al leer el perfil en el inicio de sesión no mostraba el mensaje amigable | Baja | Se agregó el `await` que faltaba en `iniciarSesion` | Cerrado |
| DEF-03 | La regla de lectura de `solicitudes` podía negar la consulta del solicitante | Media | Se reemplazó `exists()` por `resource == null` y se verificó en el emulador | Cerrado |
| DEF-04 | Las bandejas de coordinador y bodega no cargaban | Alta | Índice compuesto `estado` + `creadaEn` en `firestore.indexes.json` | Cerrado |
| DEF-05 | Las solicitudes quedaban "Rechazado por el servidor" por permisos | Alta | Venció el modo de prueba; se publicaron `firestore.rules` y las solicitudes se recuperaron con Reintentar | Cerrado |
| DEF-06 | Cerrar sesión no regresaba al login | Alta | El flujo del perfil usaba `asyncExpand`, que nunca recibía el cierre de sesión; ahora cancela el listener al cambiar la sesión | Cerrado |
| DEF-07 | Tras cerrar sesión podía aparecer "No fue posible cargar el perfil" | Baja | Se ignoran errores del perfil cuando ya no hay sesión | Cerrado |
| DEF-08 | Pantalla roja `'_dependents.isEmpty'` al cerrar los diálogos de motivo u observación | Alta | Diálogo reutilizable `DialogoTexto`, que libera el campo de texto cuando ya se cerró | Cerrado |
| DEF-09 | El solicitante no veía el motivo del rechazo (QA-12.2) | Media | La tarjeta de Mis préstamos muestra el motivo | Corregido, pendiente de verificar con QA-12.2 |

## Checklist de release

- [x] `flutter analyze` sin problemas
- [x] Versión `1.0.0+1` en `pubspec.yaml`
- [x] Reglas de Firestore publicadas e índice compuesto creado
- [x] Una cuenta por rol con su `rol` asignado
- [x] Catálogo HTTP con 10 equipos disponible
- [x] Crashlytics recibe eventos (QA-17)
- [x] APK release firmado, instalado y probado (QA-18)
- [x] Sin keystore, `key.properties` ni contraseñas en el repositorio
- [ ] Casos pendientes de la matriz: QA-03.4, QA-12.1, QA-12.2 (repetición) y QA-14.2

## Límites conocidos

- Solo Android; no hay versión web ni iOS configurada.
- El catálogo es un archivo JSON estático en GitHub, de solo lectura, y requiere conexión; no se guarda en caché local.
- Las franjas son fijas (cuatro por día) y no se puede reservar más de una franja en una sola solicitud.
- Coordinador, bodega y cancelaciones de solicitudes ya enviadas requieren conexión.
- Los roles se asignan manualmente en Firebase Console.
- No hay notificaciones push; los cambios se ven al abrir la app gracias al listener en tiempo real.
