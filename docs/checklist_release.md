# Checklist de release

Versión: 1.0.0+1

## Código

- [ ] `flutter analyze` sin problemas
- [ ] `version` actualizada en `pubspec.yaml` (nombre y código de versión)
- [ ] Sin credenciales, keystore ni `key.properties` en el repositorio
- [ ] Rama `main` actualizada en GitHub con los commits de ambos integrantes

## Firebase

- [ ] Proveedor correo/contraseña habilitado en Authentication
- [ ] `firestore.rules` publicadas (la consola no muestra modo de prueba)
- [ ] Índice compuesto `solicitudes` (`estado` + `creadaEn`) en estado Habilitado
- [ ] Una cuenta por rol con su `rol` asignado en `users/{uid}`
- [ ] Crashlytics recibe eventos (ver `docs/crashlytics.md`)

## Catálogo HTTP

- [ ] `https://raw.githubusercontent.com/Ortizzz021/prestamo_equipos/main/api/equipos.json` responde 200 con 10 equipos
- [ ] Las imágenes del catálogo cargan

## APK

- [ ] Keystore creado y `android/key.properties` configurado
- [ ] `flutter build apk --release` termina sin errores
- [ ] APK instalado en un dispositivo o emulador limpio
- [ ] Inicio de sesión, catálogo, solicitud y sincronización funcionan con el APK release
- [ ] El ícono de diagnóstico no aparece en el APK release
- [ ] APK adjunto a la entrega (o publicado como release en GitHub)

## Documentación

- [ ] README completo (integrantes, caso, roles, ejecución, Firebase, endpoint, modelo de datos, reglas, local-first, privacidad, límites, firma)
- [ ] `docs/matriz_qa.md` con al menos 12 casos ejecutados y su evidencia
- [ ] `docs/defectos.md` actualizado
- [ ] `docs/datos_prueba.md` con las cuentas y operaciones creadas
- [ ] Capturas en `docs/evidencias/`
