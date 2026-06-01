# Inventario de laboratorio con lotes

Aplicacion para gestionar insumos de laboratorio mediante lotes, fechas de vencimiento,
movimientos de inventario y solicitudes con roles, estados de cuenta, persistencia local y
sincronizacion con Firebase.

## Integrantes
- Emanuel
- Juliana
- Laura
- Juan
- Jhon

## Roles implementados
- Auxiliar
- Docente
- Administrador

Responsabilidades:
- Auxiliar: crea solicitudes y registra movimientos.
- Docente: aprueba o rechaza solicitudes.
- Administrador: gestiona usuarios y configuraciones.

## Usuarios de prueba
| Correo | Contrasena | Rol | Estado | Valida |
| --- | --- | --- | --- | --- |
| auxiliar@test.com | 123456 | auxiliar | active | Creacion de solicitudes y movimientos. |
| docente@test.com | 123456 | docente | active | Aprobacion y rechazo. |docen
| admin@test.com | 123456 | admin | active | Gestion de usuarios e inventario. |
| bloqueado@test.com | 123456 | auxiliar | blocked | Acceso restringido. |

## Descripcion del problema
Los laboratorios requieren controlar insumos por lotes, fechas de vencimiento y salidas por solicitud.
La app permite registrar entradas y salidas, generar alertas por stock bajo o vencimiento, y gestionar
solicitudes segun roles y estados de cuenta.

## Entidades principales
- Usuario
- Insumo
- Lote
- Movimiento
- Solicitud
- Alerta

## Modelo en Firestore (detallado)
Colecciones principales:
- users/{uid}
- insumos/{insumoId}
- lotes/{loteId}
- movimientos/{movimientoId}
- solicitudes/{solicitudId}
- alertas/{alertaId}

Campos comunes:
- id, createdAt, updatedAt, syncStatus

Ejemplo de insumo:
{
	"id": "insumo_001",
	"name": "Reactivo A",
	"unit": "ml",
	"totalQuantity": 1200,
	"status": "available",
	"lowStockThreshold": 200,
	"syncStatus": "synced"
}

Ejemplo de lote:
{
	"id": "lote_001",
	"insumoId": "insumo_001",
	"quantity": 300,
	"expirationDate": "2026-09-01T00:00:00.000Z",
	"syncStatus": "synced"
}

Ejemplo de solicitud:
{
	"id": "sol_001",
	"insumoId": "insumo_001",
	"requestedBy": "uid_aux",
	"quantity": 50,
	"status": "requested",
	"syncStatus": "pendingSync"
}

## Reglas de negocio
- No se puede retirar mas cantidad de la disponible.
- Un lote vencido no puede usarse.
- Un insumo con stock bajo genera alerta.
- Todo movimiento afecta inventario y lotes.
- Solicitud aprobada descuenta stock.
- Solicitud rechazada no modifica cantidades.

## Estados de negocio
Entidad principal: Solicitud
Estados: requested, approved, rejected
Transiciones permitidas: requested -> approved / rejected

## Flujo principal
Login -> consultar insumos -> crear solicitud -> validar stock -> enviar solicitud -> estado pendiente.

## Autenticacion y permisos
- Firebase Authentication (correo y contrasena).
- Perfil en Firestore users/{uid} con rol y estado de cuenta.
- Redireccion segun estado de cuenta (pendingApproval, active, blocked).
- Reglas de permisos en PermissionService.

## Persistencia local
- Drift/SQLite con tablas para users, insumos, lotes, movimientos, solicitudes y alertas.
- syncStatus: synced, pendingSync, failedSync.

## Sincronizacion (Offline-First)

### Cómo funciona

La app usa un modelo **offline-first**:

1. **Escritura Local:** Todo se guarda primero en SQLite local con `syncStatus = pendingSync`
2. **Intento de Sync:** SyncService intenta enviar a Firestore si hay conexión
3. **Estados posibles:**
   - `synced` -  Datos están en Firestore y local
   - `pendingSync` -  Datos locales pero no en Firestore (sin internet o en progreso)
   - `failedSync` -  Falló el envío (error de validación, permisos, etc.)

### Flujo detallado

```
Acción del usuario
    ↓
Guardar en SQLite (syncStatus=pendingSync)
    ↓
Mostrar "Sincronizando..." en UI
    ↓
SyncService.syncAll() intenta:
    1. Push (pendingSync → Firestore)
    2. Pull (Firestore → local)
    ↓
¿Hay conexión?
    SÍ → Intenta enviar con reintentos exponenciales (500ms, 1s, 2s)
    NO → Espera reconexión, reintenta automáticamente
    ↓
¿Envío exitoso?
    SÍ → syncStatus = synced 
    NO → syncStatus = failedSync  (Usuario puede reintentar)
```

### Reintentos automáticos

- **Intervalo:** 500ms × 2^(intento-1)
  - Intento 1: 500ms
  - Intento 2: 1s
  - Intento 3: 2s
- **Máximo:** 3 reintentos por defecto
- **Desencadenante:** 
  - Se ejecuta al abrir app (splash_page)
  - Se ejecuta al cambiar conexión (connectivity_plus)
  - Usuario puede forzar con botón "Reintentar"

### Datos pendientes en UI

- **Chip de estado:** Muestra rojo si `syncStatus != synced`
- **Offline indicator:** Barra roja en top si sin internet
- **Notificación:** Toast cuando se completa sync exitoso
- **Acciones:** Botón "Reintentar" visible en items con `failedSync`

### Ejemplo: Crear solicitud sin internet

1. Usuario: "Crear solicitud de 50ml Reactivo A"
2. App: Guarda en SQLite con `syncStatus = pendingSync`
3. UI: Muestra chip naranja "Sincronizando..."
4. Usuario: Sale del wifi
5. App: Mantiene `syncStatus = pendingSync` localmente
6. Usuario: Vuelve a conectarse
7. App: SyncService detecta cambio de conexión, ejecuta `syncAll()`
8. Firestore: Recibe solicitud, aprueba/rechaza
9. App: Actualiza a `syncStatus = synced` con estado de solicitud

### Firestore sync rules

```javascript
// Solo se sincan datos con syncStatus válido
// Se validan permisos por rol/estado antes de escribir
```

## Instrucciones de ejecucion
1. Instala dependencias:
	flutter pub get
2. Configura Firebase:
	flutterfire configure
3. Ejecuta:
	flutter run

## Generar APK
flutter build apk
Salida esperada:
build/app/outputs/flutter-apk/app-release.apk

## Pruebas
- Unit tests y widget tests en /test.
- Ejecutar: flutter test

## Documentacion
Ver carpeta docs/ con pruebas, checklist de release, backlog y rc candidate.
