# Registro de defectos

Severidad: **Alta** (bloquea un flujo principal), **Media** (afecta un flujo con alternativa), **Baja** (visual o menor).

| ID | Fecha | Módulo | Descripción | Pasos para reproducir | Severidad | Causa | Corrección | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DEF-01 | 2026-11-06 | Arranque (web) | La app abría en blanco al ejecutarla en Chrome | `flutter run -d chrome` | Media | Crashlytics no tiene implementación web y fallaba al iniciar | Se inicializa Crashlytics solo si `!kIsWeb`; la app se orienta a Android | Cerrado |
| DEF-02 | 2026-11-11 | Autenticación | Un error al leer el perfil al iniciar sesión no mostraba el mensaje amigable | Iniciar sesión con Firestore sin acceso | Baja | Faltaba `await` en `iniciarSesion`, así el `try` no capturaba la excepción | Se agregó `return await _leerPerfil(user)` | Cerrado |
| DEF-03 | 2026-11-11 | Reglas Firestore | La regla de lectura de `solicitudes` usaba `exists()` sobre el mismo documento, lo que podía denegar la consulta del solicitante | Escuchar `solicitudes` filtrado por `solicitanteUid` | Media | Evaluación de `exists()` dentro de una regla de consulta | Se reemplazó por `resource == null` y se reordenaron las condiciones; verificado con 28 casos en el emulador de Firestore | Cerrado |
| DEF-04 | 2026-11-11 | Coordinación y bodega | Las bandejas no cargaban por falta de índice | Abrir la bandeja del coordinador | Alta | La consulta `estado ==` con `orderBy(creadaEn)` requiere índice compuesto | Se agregó `firestore.indexes.json` y su referencia en `firebase.json` | Cerrado |
| DEF-05 | 2026-11-11 | Sincronización | Todas las solicitudes quedaban "Rechazado por el servidor" por permisos | Crear una solicitud con conexión | Alta | El modo de prueba de Firestore venció y las reglas del proyecto no estaban publicadas | Publicación de `firestore.rules`; las solicitudes afectadas se recuperan con Reintentar | Cerrado tras publicar reglas |
| DEF-06 | 2026-11-11 | Autenticación | Cerrar sesión no regresaba a la pantalla de login | Iniciar sesión y tocar Cerrar sesión | Alta | `perfilActual` usaba `asyncExpand`, que espera a que termine el listener del perfil; como ese listener nunca termina, el evento de cierre de sesión no llegaba | Se cambió a un flujo que cancela el listener del perfil al cambiar la sesión y se limpia el perfil al cerrar sesión | Cerrado |
| DEF-07 | 2026-11-11 | Autenticación | Tras cerrar sesión podía aparecer "No fue posible cargar el perfil" en el login | Cerrar sesión con reglas publicadas | Baja | El listener del perfil recibía permiso denegado justo después del cierre | Se ignoran errores del perfil cuando ya no hay sesión | Cerrado |

Los defectos nuevos que aparezcan al ejecutar `docs/matriz_qa.md` se agregan con el siguiente ID y el caso de QA que los detectó.
