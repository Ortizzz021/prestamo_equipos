# Evidencia de Crashlytics

## Configuración

- Plugins de Android: `com.google.gms.google-services` y `com.google.firebase.crashlytics` en `android/settings.gradle.kts` y `android/app/build.gradle.kts`.
- `lib/main.dart` activa la recolección solo fuera de modo debug (`setCrashlyticsCollectionEnabled(!kDebugMode)`), registra `FlutterError.onError` como error fatal y captura las excepciones asíncronas con `PlatformDispatcher.instance.onError`.
- Al iniciar se envían las claves personalizadas `app_version` y `build_mode`. Al iniciar o cerrar sesión se asigna o limpia el identificador de usuario con el UID de Firebase; no se envían nombre ni correo.
- `lib/core/logging/app_logger.dart` centraliza los reportes:
  - Errores de red esperados: no fatales, con motivo `Fallo de red esperado`.
  - Errores inesperados: no fatales, con motivo `Excepción inesperada`.
  - Reglas de negocio (`ReglaNegocioException`): no se reportan, porque son validaciones normales del flujo.
  - Se reporta el tipo del error y la traza, no el mensaje, para no enviar datos personales. Los textos de `log` se limpian de correos, contraseñas y tokens.

## Pantalla de diagnóstico

Solo en modo debug, la barra superior de cualquier inicio muestra el ícono de diagnóstico. La pantalla ofrece:

- **Enviar error no fatal de prueba**: habilita la recolección para esa ejecución y registra un `StateError` con motivo `Evento no fatal de diagnóstico`.
- **Forzar cierre de prueba**: cierra la aplicación con `FirebaseCrashlytics.crash()`. El reporte se envía al volver a abrirla.

En las versiones release el botón no aparece y la pantalla no muestra contenido.

## Procedimiento de verificación

1. Ejecutar la app en el emulador o un celular Android con `flutter run`.
2. Iniciar sesión con cualquier cuenta y tocar el ícono de diagnóstico.
3. Tocar **Enviar error no fatal de prueba** y confirmar el mensaje de envío.
4. Tocar **Forzar cierre de prueba**, aceptar y volver a abrir la app desde el emulador para que se suba el reporte.
5. Esperar unos minutos y revisar Firebase Console → Crashlytics del proyecto `prestamo-equipos-36c3c`.
6. En el detalle del evento verificar el motivo, las claves `app_version` y `build_mode` y el identificador de usuario.

## Resultados

| Prueba | Fecha | Resultado | Captura |
| --- | --- | --- | --- |
| Cierre forzado desde Diagnóstico | 2026-11-12 | En Crashlytics de `prestamo_equipos (android)` se registraron 5 fallas de 1 usuario | [QA-17.jpeg](evidencias/QA-17.jpeg) |

El caso correspondiente en la matriz de QA es QA-17 (`docs/matriz_qa.md`).
