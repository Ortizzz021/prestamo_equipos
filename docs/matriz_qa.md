# Matriz de QA manual

Versión probada: 1.0.0+1
Dispositivo: emulador Android (Medium Phone API 37.0)
Fecha de ejecución: 2026-11-11
Ejecutado por: Juan Pablo Berrío Díaz y Daniel Ortiz Ortiz

Cuentas y datos usados: sección Datos de prueba del `README.md`. Las capturas están en `docs/evidencias/` y se nombran con el ID del caso.

Estado: **Pasó**, **Falló** (se registra en el Registro de defectos del `README.md`) o **Pendiente** (aún sin ejecutar).

## Autenticación

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-01 | Registro | Solicitante | App instalada, sin sesión | Tocar Registrarse, llenar nombre, correo y contraseña válidos y enviar | Se crea la cuenta y se abre el inicio con rol Solicitante | Se creó la cuenta "Solicitante Uno" y abrió el inicio con el chip "Rol: Solicitante", Catálogo de equipos y Mis préstamos | Pasó | [QA-01.jpeg](evidencias/QA-01.jpeg) |
| QA-02.1 | Registro, validación | — | Sin sesión, en Crear cuenta | Escribir una contraseña de menos de 6 caracteres y enviar | Mensaje de validación debajo del campo; no se crea la cuenta | Con "Sol2" se mostró "La contraseña debe tener al menos 6 caracteres" | Pasó | [QA-02.jpeg](evidencias/QA-02.jpeg) |
| QA-02.2 | Registro, correo duplicado | — | Cuenta `solicitante2@gmail.com` ya registrada | Registrarse con ese mismo correo | Mensaje de correo en uso; no se crea otra cuenta | Se mostró "Ya existe una cuenta con ese correo electrónico" | Pasó | [QA-02.jpeg](evidencias/QA-02.jpeg) |
| QA-03.1 | Inicio de sesión | Solicitante | Cuenta con `rol: solicitante` | Iniciar sesión con la cuenta del solicitante | Abre el inicio de solicitante | Abrió "Préstamo de Equipos" con "Hola, Solicitante Uno", rol Solicitante, Catálogo y Mis préstamos | Pasó | [QA-03.1.jpeg](evidencias/QA-03.1.jpeg) |
| QA-03.2 | Inicio de sesión | Coordinador | Cuenta con `rol: coordinador` | Iniciar sesión con la cuenta del coordinador | Abre el inicio de coordinación | Abrió "Coordinación" con rol Coordinador, Bandeja de solicitudes y Bloqueo de equipos | Pasó | [QA-03.2.jpeg](evidencias/QA-03.2.jpeg) |
| QA-03.3 | Inicio de sesión | Bodega | Cuenta con `rol: bodega` | Iniciar sesión con la cuenta de bodega | Abre el inicio de bodega | Abrió "Bodega" con rol Encargado de bodega, Registrar entrega y Registrar devolución | Pasó | [QA-03.3.jpeg](evidencias/QA-03.3.jpeg) |
| QA-03.4 | Cierre de sesión | Cualquiera | Sesión iniciada | Tocar el ícono de salida y confirmar | Vuelve a la pantalla de inicio de sesión | | Pendiente | QA-03.4.jpeg |

## Catálogo HTTP y preferencias

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-04.1 | Catálogo | Solicitante | Con internet | Abrir Catálogo de equipos | Lista de equipos con imagen, nombre y categoría, y filtros por categoría | Se listaron los equipos ordenados por nombre con imagen y categoría, y los filtros Todas, Audio, Cámaras, Portátiles… | Pasó | [QA-04.1.jpeg](evidencias/QA-04.1.jpeg) |
| QA-04.2 | Detalle de equipo | Solicitante | Catálogo cargado | Tocar Audífonos Sony WH-CH720N | Detalle con imagen, categoría, descripción, código y botón para solicitar | Se mostró el detalle con categoría Audio, descripción, código eq-10 y "Solicitar préstamo" | Pasó | [QA-04.2.jpeg](evidencias/QA-04.2.jpeg) |
| QA-05.1 | Catálogo sin conexión | Solicitante | Modo avión activo | Abrir Catálogo de equipos | Mensaje de sin conexión con botón Reintentar | Se mostró "Sin conexión a internet. Revisa tu conexión e inténtalo de nuevo." con Reintentar | Pasó | [QA-05.1.jpeg](evidencias/QA-05.1.jpeg) |
| QA-05.2 | Reintento del catálogo | Solicitante | Error de QA-05.1 en pantalla | Quitar modo avión y tocar Reintentar | El catálogo carga sin salir de la pantalla | El catálogo cargó completo | Pasó | [QA-05.2.jpeg](evidencias/QA-05.2.jpeg) |
| QA-06 | Preferencia de filtro | Solicitante | Catálogo cargado | Filtrar por Audio, cerrar la app por completo y volver a abrir el catálogo | El catálogo se abre con el filtro Audio aplicado | El catálogo abrió con Audio seleccionado y solo Audífonos Sony y Micrófono Blue Yeti | Pasó | [QA-06.jpeg](evidencias/QA-06.jpeg) |

## Solicitudes y sincronización

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-07 | Solicitud con conexión | Solicitante | Con internet | Solicitar Cámara Canon EOS Rebel T7 para el sáb 14 nov, 16:00-18:00 | Aparece en Mis préstamos como Solicitado y Sincronizado | Apareció como Solicitado y Sincronizado | Pasó | [QA-07.jpeg](evidencias/QA-07.jpeg) |
| QA-08.1 | Solicitud sin conexión | Solicitante | Modo avión activo | Solicitar iPad 10.ª generación para el lun 16 nov, 14:00-16:00 | Se guarda en el dispositivo como pendiente de sincronizar | Apareció como Solicitado y "Pendiente de sincronizar" con el aviso "Sin conexión con el servidor. Se reintentará automáticamente." | Pasó | [QA-08.1.jpeg](evidencias/QA-08.1.jpeg) |
| QA-08.2 | Sincronización automática | Solicitante | Solicitud pendiente de QA-08.1 | Quitar modo avión sin tocar nada más | La solicitud se sincroniza sola y sin duplicados | La solicitud del iPad pasó a Sincronizado y en la lista quedó una sola vez | Pasó | [QA-08.2.jpeg](evidencias/QA-08.2.jpeg) |
| QA-09 | Solicitud duplicada | Solicitante | Solicitud activa de QA-07 | Volver a solicitar la Canon EOS Rebel T7 el mismo día y franja | Mensaje de solicitud activa; no se crea otra | Se mostró "Ya tienes una solicitud activa para este equipo en esa franja." | Pasó | [QA-09.jpeg](evidencias/QA-09.jpeg) |
| QA-10.1 | Cancelación de solicitud pendiente | Solicitante | Portátil Dell Latitude 5440 en Solicitado (dom 15 nov, 10:00-12:00) | Tocar Cancelar y confirmar | Pasa a Cancelado | Pasó de Solicitado a Cancelado y Sincronizado | Pasó | [QA-10-antes.jpeg](evidencias/QA-10-antes.jpeg), [QA-10-despues.jpeg](evidencias/QA-10-despues.jpeg) |
| QA-10.2 | Cancelación de solicitud aprobada | Solicitante | Micrófono Blue Yeti en Aprobado (vie 13 nov, 10:00-12:00) | Tocar Cancelar y confirmar | Pasa a Cancelado y la franja queda libre | Pasó de Aprobado a Cancelado y Sincronizado | Pasó | [QA-10-antes.jpeg](evidencias/QA-10-antes.jpeg), [QA-10-despues.jpeg](evidencias/QA-10-despues.jpeg) |

## Coordinación

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-11 | Aprobación | Coordinador y solicitante | Solicitud de QA-07 en Solicitado | El coordinador la aprueba desde la bandeja | El solicitante la ve como Aprobado sin refrescar | La Canon EOS Rebel T7 apareció como Aprobado y Sincronizado en Mis préstamos | Pasó | [QA-11.jpeg](evidencias/QA-11.jpeg) |
| QA-12.1 | Rechazo sin motivo | Coordinador | Solicitud en Solicitado | Tocar Rechazar y Continuar con el motivo vacío | No deja continuar y pide el motivo | | Pendiente | QA-12.1.jpeg |
| QA-12.2 | Rechazo con motivo | Coordinador y solicitante | Solicitud de QA-08.1 en Solicitado | El coordinador la rechaza escribiendo un motivo | El solicitante la ve como Rechazado con el motivo | El iPad apareció como Rechazado y Sincronizado, pero sin el motivo; se registró DEF-09 y se corrigió. Falta repetir la prueba | Falló | [QA-12.2.jpeg](evidencias/QA-12.2.jpeg) |
| QA-13 | Franja ocupada | Solicitante | Franja de QA-11 aprobada | Abrir Solicitar préstamo de la Canon EOS Rebel T7 el sáb 14 nov | La franja aprobada aparece ocupada y no se puede enviar | La franja 16:00-18:00 apareció como "Ocupada" y deshabilitada, y el botón Enviar solicitud quedó inactivo | Pasó | [QA-13.jpeg](evidencias/QA-13.jpeg) |
| QA-14.1 | Bloqueo de equipo | Coordinador y solicitante | Con internet | El coordinador bloquea los Audífonos Sony con motivo; el solicitante abre el detalle | Se ve Bloqueado con el motivo y no se puede solicitar | Se mostró el chip Bloqueado, el motivo "No Disponible" y el botón "Equipo bloqueado" inactivo | Pasó | [QA-14.1.jpeg](evidencias/QA-14.1.jpeg) |
| QA-14.2 | Desbloqueo de equipo | Coordinador y solicitante | Equipo bloqueado de QA-14.1 | El coordinador lo desbloquea; el solicitante abre el detalle | Vuelve a aparecer "Solicitar préstamo" | | Pendiente | QA-14.2.jpeg |

## Bodega

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-15 | Entrega | Bodega | Solicitud de QA-11 en Aprobado | Registrar entrega con la observación "Incluye batería y cargador" | Pasa a Entregado y el solicitante lo ve actualizado | La Canon EOS Rebel T7 pasó a Entregado y Sincronizado en Mis préstamos del solicitante | Pasó | [QA-15.jpeg](evidencias/QA-15.jpeg) |
| QA-16 | Devolución | Bodega | Solicitud de QA-15 en Entregado | Registrar devolución con la observación "Devuelto en buen estado" | Pasa a Devuelto y el solicitante lo ve actualizado | La Canon EOS Rebel T7 pasó a Devuelto y Sincronizado | Pasó | [QA-16.jpeg](evidencias/QA-16.jpeg) |

## Monitoreo y release

| ID | Módulo | Rol | Precondición | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-17 | Crashlytics | Cualquiera | App en debug | Diagnóstico → Forzar cierre de prueba, volver a abrir la app y revisar Firebase Console → Crashlytics | Los cierres aparecen como fallas de la app Android | En Crashlytics de `prestamo_equipos (android)` aparecieron 5 fallas de 1 usuario el 12 nov | Pasó | [QA-17.jpeg](evidencias/QA-17.jpeg) |
| QA-18 | APK release | Solicitante | `app-release.apk` firmado con el keystore del proyecto | Instalar el APK release en el emulador e iniciar sesión | La app instala, abre e inicia sesión; el ícono de diagnóstico no aparece en release | Abrió el inicio con "Hola, Solicitante Uno" y rol Solicitante; la barra solo muestra el ícono de cerrar sesión, sin el de diagnóstico | Pasó | [QA-18.jpeg](evidencias/QA-18.jpeg) |

## Resumen

| Total | Pasó | Falló | Pendiente |
| --- | --- | --- | --- |
| 28 | 24 | 1 | 3 |
