# RC Candidate

Version candidata: 0.1.0
Fecha: 2026-05-21

## Funcionalidades incluidas
- Autenticacion con Firebase Auth.
- Perfil en Firestore con roles y estados.
- Inventario con insumos, lotes y alertas.
- Solicitudes con flujo requested/approved/rejected.
- Persistencia local Drift y sincronizacion.
- Unit tests y widget tests base.

## Funcionalidades pendientes
- Historial de movimientos en detalle de insumo.
- Pantallas de aprobacion/rechazo con reglas completas.
- Reportes avanzados.

## Riesgos conocidos
- Reintentos de sync sin backoff.
- Falta de manejo de conflictos en datos concurrentes.

## Decision
- Aun no listo para entrega final. Requiere completar flujo de aprobacion y documentacion final.
