# Pruebas manuales y evidencias

Fecha: 2026-05-21

## Casos manuales

1. Login y estados de cuenta
Fecha: 2026-05-21
- Usuario active con rol auxiliar: accede al home de auxiliar correctamente.
- Usuario active con rol docente: accede al home de docente correctamente.
- Usuario active con rol administrador: accede al home de administrador correctamente.
- Usuario pendingApproval: ve pantalla de espera.
- Usuario blocked: ve pantalla de acceso bloqueado.

(capturas tomadas)

2. Flujo principal
- Login -> inventario -> crear solicitud -> validar stock -> enviar -> estado solicitado.

3. Estados de UI
- Vacio: sin insumos muestra estado vacio.
- Error: falla de sincronizacion muestra banner.
- Pendiente de sincronizacion: chip 'Pendiente'.

4. Offline-first
- Desconectar red.
- Crear solicitud: queda pendingSync.
- Reintentar sync al restaurar conexion.

## Evidencia de pruebas automatizadas
- Unit tests: PermissionService, RulesService.
- Widget tests: estados UI y pantallas de cuenta.
- BlockedPage muestra el mensaje “Acceso bloqueado”.

## Notas
Adjuntar capturas o logs de 'flutter test' al entregar.

La idea es que no digan “Usuario pendingApproval: ve pantalla de espera” si todavía no lo pudieron probar manualmente. Mejor dejarlo como **implementado en widget test, pendiente de validación manual por acceso a Firestore**.


### Inventario y lotes -

Se validaron los estados visuales del inventario:

- Cargando: se muestra `LoadingState`.
- Vacío: se muestra “No hay insumos registrados.”
- Error: se muestra “Error al cargar inventario.”
- Offline: si falla la sincronización, se muestra “Sin conexión. Trabajando con datos locales.”
- PendingSync: los insumos muestran su estado mediante `SyncStatusChip`.

También se agregaron unit tests en `test/unit/inventory_rules_test.dart` para validar:

- Un lote vencido no puede usarse.
- Un lote vigente sí puede usarse.
- No se puede solicitar más cantidad de la disponible.
- El stock bajo genera condición de alerta.
- Cantidad cero queda como agotado.
- Cantidad baja queda como stock bajo.