# Pruebas manuales y evidencias

Fecha: 2026-05-21

## Casos manuales

1. Login y estados de cuenta
- Usuario active: accede a home.
- Usuario pendingApproval: ve pantalla de espera.
- Usuario blocked: ve pantalla de acceso bloqueado.

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

## Notas
Adjuntar capturas o logs de 'flutter test' al entregar.
