# Matriz de QA manual

Versión probada: 1.0.0+1
Dispositivo: emulador Android (Medium Phone API 37) / celular: ______
Fecha de ejecución: ______
Ejecutado por: ______

Cuentas y datos usados: `docs/datos_prueba.md`. Las capturas se guardan en `docs/evidencias/` con el ID del caso como nombre (por ejemplo `QA-01.png`).

Estado: **Pasó**, **Falló** (se registra en `docs/defectos.md`) o **Pendiente**.

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-01 | Registro | Solicitante | App instalada, sin sesión | Tocar Registrarse, llenar nombre, correo y contraseña válidos y enviar | Se crea la cuenta, se abre el inicio de solicitante y en Firestore aparece `users/{uid}` con `rol: solicitante` | | Pendiente | QA-01.png |
| QA-02 | Registro | — | Sin sesión | Registrarse con un correo ya usado; luego con contraseña de menos de 6 caracteres | Mensaje de correo en uso y validación de contraseña; no se crea cuenta | | Pendiente | QA-02.png |
| QA-03 | Inicio y cierre de sesión | Los tres | Cuentas de los tres roles creadas | Iniciar sesión con cada cuenta, verificar el inicio según el rol y cerrar sesión desde el ícono de salida | Cada rol ve su propio inicio; al cerrar sesión vuelve a la pantalla de login | | Pendiente | QA-03.png |
| QA-04 | Catálogo HTTP | Solicitante | Con internet | Abrir Catálogo y luego el detalle de un equipo | Se listan los 10 equipos con imagen, nombre y categoría; el detalle muestra descripción | | Pendiente | QA-04.png |
| QA-05 | Catálogo HTTP, error | Solicitante | Modo avión activo | Abrir Catálogo; quitar modo avión y tocar Reintentar | Mensaje de sin conexión con botón Reintentar; al reintentar carga el catálogo | | Pendiente | QA-05.png |
| QA-06 | Preferencias | Solicitante | Catálogo cargado | Filtrar por la categoría Audio, cerrar la app por completo y volver a abrirla | El catálogo se abre con el filtro Audio aplicado | | Pendiente | QA-06.png |
| QA-07 | Solicitud con conexión | Solicitante | Con internet | Solicitar un equipo en una fecha y franja futuras | Aparece en Mis préstamos como Solicitado y Sincronizado; existe en Firestore `solicitudes` | | Pendiente | QA-07.png |
| QA-08 | Solicitud sin conexión | Solicitante | Modo avión activo | Crear una solicitud, cerrar y abrir la app, quitar modo avión | Se guarda como pendiente y se ve tras reabrir; al volver la conexión se sincroniza sola, sin duplicados | | Pendiente | QA-08.png |
| QA-09 | Solicitud duplicada | Solicitante | Solicitud activa del QA-07 | Volver a solicitar el mismo equipo en la misma fecha y franja | Mensaje de solicitud activa para ese equipo y franja; no se crea otra | | Pendiente | QA-09.png |
| QA-10 | Aprobación | Coordinador | Solicitud en Solicitado | Abrir la bandeja y aprobar | Pasa a Aprobado; se crea `franjas/{equipo}_{fecha}_{slot}`; el solicitante la ve como Aprobado sin refrescar | | Pendiente | QA-10.png |
| QA-11 | Rechazo | Coordinador | Otra solicitud en Solicitado | Rechazar sin motivo y luego con motivo | Sin motivo no deja continuar; con motivo pasa a Rechazado y el solicitante ve el motivo | | Pendiente | QA-11.png |
| QA-12 | Franja ocupada | Solicitante y coordinador | Franja aprobada en QA-10 | Con otra cuenta solicitante, pedir el mismo equipo, fecha y franja | La franja aparece ocupada o el coordinador no puede aprobarla (Franja ocupada) | | Pendiente | QA-12.png |
| QA-13 | Bloqueo de equipo | Coordinador | Con internet | Bloquear un equipo con motivo; como solicitante intentar pedirlo; desbloquear | Mientras está bloqueado no se puede solicitar ni aprobar; al desbloquear vuelve a estar disponible | | Pendiente | QA-13.png |
| QA-14 | Entrega | Bodega | Solicitud Aprobado | Registrar entrega con observación | Pasa a Entregado; el solicitante lo ve actualizado | | Pendiente | QA-14.png |
| QA-15 | Devolución | Bodega | Solicitud Entregado | Registrar devolución con observación | Pasa a Devuelto y se borra la franja en Firestore; la franja queda libre para nuevas solicitudes | | Pendiente | QA-15.png |
| QA-16 | Cancelación | Solicitante | Una solicitud Solicitado y otra Aprobado | Cancelar ambas desde Mis préstamos | Ambas pasan a Cancelado; la franja de la aprobada se libera | | Pendiente | QA-16.png |
| QA-17 | Reglas de seguridad | Solicitante | Sesión de solicitante | En Rules Playground de Firestore simular que el solicitante actualiza `users/{uid}.rol` a `coordinador` y lee una solicitud ajena | Ambas operaciones denegadas | | Pendiente | QA-17.png |
| QA-18 | Cambio de cuenta | Dos solicitantes | Solicitante A con una solicitud pendiente sin conexión | Cerrar sesión de A, iniciar con B, volver a tener conexión | B no ve las solicitudes de A y no se suben a nombre de B; al volver A se sincronizan | | Pendiente | QA-18.png |
| QA-19 | Crashlytics | Cualquiera | App en debug | Pantalla Diagnóstico: enviar error no fatal y forzar cierre; reabrir la app | Ambos eventos aparecen en Firebase Console → Crashlytics con `app_version` y `build_mode` | | Pendiente | QA-19.png |
| QA-20 | APK release | — | APK release generado | Instalar `app-release.apk` en un dispositivo limpio y recorrer QA-03 y QA-07 | La app instala, abre, inicia sesión y sincroniza | | Pendiente | QA-20.png |

## Resumen

| Total | Pasó | Falló | Pendiente |
| --- | --- | --- | --- |
| 20 | | | |
