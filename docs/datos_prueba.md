# Datos de prueba

## Cuentas por rol

Las contraseñas no se guardan en el repositorio; se entregan al docente por el canal de la entrega.

| Rol | Nombre | Correo | Cómo se asigna el rol |
| --- | --- | --- | --- |
| Solicitante | Solicitante Uno | ______ | Registro desde la app |
| Solicitante | Solicitante Dos | ______ | Registro desde la app (para QA-12 y QA-18) |
| Coordinador | Coordinador | ______ | Registro desde la app y luego `rol: coordinador` en `users/{uid}` |
| Encargado de bodega | Bodega | ______ | Registro desde la app y luego `rol: bodega` en `users/{uid}` |

## Registros HTTP del catálogo

Fuente: `api/equipos.json`, publicado en `https://raw.githubusercontent.com/Ortizzz021/prestamo_equipos/main/api/equipos.json`.

| ID | Nombre | Categoría |
| --- | --- | --- |
| eq-1 | Portátil Lenovo ThinkPad E14 | Portátiles |
| eq-2 | Portátil Dell Latitude 5440 | Portátiles |
| eq-3 | MacBook Air M2 | Portátiles |
| eq-4 | iPad 10.ª generación | Tablets |
| eq-5 | Samsung Galaxy Tab S9 FE | Tablets |
| eq-6 | Proyector Epson PowerLite X49 | Proyectores |
| eq-7 | Proyector portátil BenQ GV31 | Proyectores |
| eq-8 | Cámara Canon EOS Rebel T7 | Cámaras |
| eq-9 | Micrófono Blue Yeti | Audio |
| eq-10 | Audífonos Sony WH-CH720N | Audio |

## Operaciones en distintos estados

Se crean desde la app con las cuentas anteriores, en fechas futuras. Al terminar, cada fila debe verse con su estado en Mis préstamos y en la colección `solicitudes` de Firestore.

| # | Equipo | Franja | Cómo se obtiene | Estado final |
| --- | --- | --- | --- | --- |
| 1 | eq-1 ThinkPad E14 | 08:00-10:00 | Solicitante Uno solicita | Solicitado |
| 2 | eq-4 iPad | 10:00-12:00 | Solicitante Uno solicita; coordinador aprueba | Aprobado |
| 3 | eq-6 Epson X49 | 14:00-16:00 | Solicitante Uno solicita; coordinador rechaza con motivo "Equipo reservado para evento" | Rechazado |
| 4 | eq-9 Blue Yeti | 16:00-18:00 | Solicitante Uno solicita y luego cancela | Cancelado |
| 5 | eq-8 Canon T7 | 08:00-10:00 | Solicitante Dos solicita; coordinador aprueba; bodega entrega con observación "Incluye batería y cargador" | Entregado |
| 6 | eq-10 Sony WH-CH720N | 10:00-12:00 | Solicitante Dos solicita; coordinador aprueba; bodega entrega y registra devolución "Devuelto en buen estado" | Devuelto |
| 7 | eq-3 MacBook Air M2 | 14:00-16:00 | Solicitante Uno solicita en modo avión y sincroniza al volver la conexión | Solicitado (creada sin conexión) |

Equipo bloqueado para QA-13: eq-7 BenQ GV31, motivo "Mantenimiento de lámpara".
