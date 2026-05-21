# Plan y reparto del proyecto

Fecha: 2026-05-21
Proyecto: Gestion de inventario de laboratorio con lotes

## Objetivo
Definir el reparto por integrante y el orden de ejecucion para habilitar trabajo paralelo.

## Reparto

### 1) Emanuel (bloque inicial y base tecnica)
- Estructura de carpetas y convenciones.
- Modelos base: UserProfile, Insumo, Lote, Movimiento, Solicitud, Alerta.
- Enums: roles, estados de cuenta, estados de inventario, estados de solicitud, syncStatus.
- Reglas y permisos en servicios: PermissionService y RulesService.
- Flujo de estados de Solicitud e Insumo.
- Esqueleto de autenticacion + lectura de perfil + redireccion por rol/estado.
- Base de persistencia local (Drift): esquema inicial y tablas.
- Scaffolding de sincronizacion local/remota.

### 2) Juliana (autenticacion y perfiles)
- UI login, pantalla pendiente de aprobacion, pantalla de acceso bloqueado.
- Integracion Firebase Auth + Firestore users/{uid}.
- Guards de rutas y redireccion por rol/estado.
- Widget tests de estados de cuenta.

### 3) Laura (inventario y lotes)
- UI y servicios de insumos y lotes.
- Reglas: lote vencido no usable, stock bajo genera alerta, estados de inventario.
- Vistas con estados UI: vacio, error, offline, pendingSync.
- Unit tests de reglas de inventario.

### 4) Juan (solicitudes y movimientos)
- Flujo: crear solicitud -> validar stock -> enviar -> aprobar/rechazar.
- Movimientos que afectan inventario; aprobacion descuenta stock; rechazo no cambia.
- UI de solicitudes por rol (auxiliar, docente, admin).
- Unit tests de reglas y transiciones.

### 5) Jhon (sincronizacion, docs y build)
- Sincronizacion local/remota con Firestore (pendingSync, failedSync).
- Manejo offline-first y reintentos.
- Documentacion en docs/ y README.
- Checklist de release y build de APK.

## Dependencias de trabajo
1. Emanuel entrega estructura, modelos, servicios base y flujo de estados.
2. Juliana y Laura construyen UI y reglas apoyadas en modelos/servicios.
3. Juan integra solicitudes y movimientos con reglas existentes.
4. Jhon conecta sincronizacion y documenta el flujo completo.

## Nota
Este plan habilita trabajo paralelo desde el bloque inicial de Emanuel.
