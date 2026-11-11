# Reglas de seguridad de Firestore

Las reglas están en `firestore.rules` y se despliegan al proyecto configurado por Firebase CLI con `firebase deploy --only firestore:rules`. Las operaciones de la app se ejecutan con usuarios autenticados y las reglas consultan `users/{uid}.rol` para autorizar cada rol. La asignación inicial de coordinador y bodega se hace desde una consola administrativa.

## Decisiones por colección

- `users/{uid}`: cada usuario puede leer su perfil; coordinador y bodega pueden leer perfiles para operar las solicitudes. El alta solo puede crear el documento con su propio UID y rol `solicitante`. El usuario solo puede actualizar nombre y correo, sin cambiar UID ni rol. Nadie puede borrar perfiles.
- `solicitudes/{id}`: crear solo permite solicitudes del usuario autenticado en estado `SOLICITADO`, con ID igual al documento y solo los campos iniciales de la app. El dueño solo cancela solicitudes `SOLICITADO` o `APROBADO`; el coordinador aprueba o rechaza solicitudes de otra persona; bodega entrega solicitudes aprobadas y registra la devolución de las entregadas. Cada operación limita los campos modificables, exige el autor autenticado y aumenta la versión. Nadie puede borrar solicitudes ni alterar dueño, equipo u horario.
- `franjas/{id}`: cualquier autenticado puede leer. Solo un coordinador crea la franja en la misma operación que deja su solicitud `APROBADO`. No se permiten cambios. Bodega la borra con la devolución y el dueño con una cancelación aprobada; las reglas verifican estado antes y después de la transacción.
- `equipos_estado/{equipoId}`: cualquier autenticado puede leer; solo coordinador crea o actualiza el bloqueo con campos permitidos y su UID como autor. No se permite borrar.

## Escenarios de verificación

| Escenario | Resultado esperado | Restricción que lo decide |
| --- | --- | --- |
| Solicitante cambia su propio `rol` | Denegado | El update solo admite cambios en `nombre` y `email`. |
| Solicitante crea una solicitud con otro `solicitanteUid` | Denegado | La creación exige `solicitanteUid == request.auth.uid`. |
| Solicitante intenta aprobar una solicitud | Denegado | La rama de aprobación exige rol coordinador; la rama solicitante solo permite `CANCELADO`. |
| Bodega intenta entregar una solicitud `SOLICITADO` | Denegado | La entrega exige estado previo `APROBADO`. |
| Coordinador aprueba la solicitud de otra persona | Permitido | Si continúa `SOLICITADO`, el autor es el coordinador y la transacción crea la franja correspondiente. |
| Solicitante lee una solicitud ajena | Denegado | La lectura para solicitantes exige que el `solicitanteUid` coincida con su UID. |

## Despliegue y prueba

Desde la raíz del proyecto, iniciar sesión con Firebase CLI, seleccionar `prestamo-equipos-36c3c` si lo solicita y ejecutar `firebase deploy --only firestore:rules`. También se puede pegar el contenido de `firestore.rules` en la pestaña Rules de Firestore. Al terminar, confirmar que la consola ya no indique modo de prueba. Validar las operaciones de la tabla con Rules Playground o Emulator Suite, usando usuarios autenticados cuyos perfiles tengan los tres roles. Finalmente, recorrer registro y envío, aprobación/cancelación, entrega y devolución con la app conectada.
