# Release Checklist - v1.0.0

Fecha: 2026-05-24 

## CRÍTICO - Debe completarse antes de release

### Compilación y Build
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] App compila sin errores ni warnings
- [ ] `flutter build apk --release` genera APK correctamente
- [ ] APK está en `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Archivo APK es firmado correctamente
- [ ] Tamaño de APK < 200MB

### Pruebas Básicas (Device/Emulator)
- [ ] App se abre sin crashes
- [ ] Splash screen muestra correctamente
- [ ] Login funciona con usuarios de prueba

### Autenticación y Acceso
- [ ] Login auxiliar@test.com → Redirige a home (auxiliar)
- [ ] Login docente@test.com → Redirige a home (docente)
- [ ] Login admin@test.com → Redirige a home (admin)
- [ ] Login bloqueado@test.com → Muestra "Acceso Bloqueado"
- [ ] Credenciales inválidas muestran error
- [ ] Logout funcionan correctamente

### Roles y Permisos
- [ ] Auxiliar: Ve botón "Crear Solicitud" ✓
- [ ] Auxiliar: NO ve botón "Aprobar Solicitud" ✓
- [ ] Docente: Ve botón "Aprobar/Rechazar" ✓
- [ ] Admin: Ve tab de Usuarios ✓
- [ ] Admin: Ve tab de Reportes ✓
- [ ] Auxiliar: No ve tab de Usuarios ✓

### Inventario y Lotes
- [ ] Página de Inventario carga insumos correctamente
- [ ] Detalle de insumo muestra lotes no vencidos
- [ ] Lotes vencidos NO aparecen en la lista
- [ ] Estados de inventario (disponible, bajo stock, agotado) correctos
- [ ] Stock bajo genera alerta visual (chip rojo)
- [ ] Expandir lotes muestra información correcta

### Solicitudes y Movimientos
- [ ] Crear solicitud: Valida stock disponible
- [ ] Crear solicitud: Muestra error si stock insuficiente
- [ ] Crear solicitud: Se guarda en local con syncStatus=pendingSync
- [ ] Docente: Puede aprobar solicitud → Stock se descuenta
- [ ] Docente: Puede rechazar solicitud → Stock NO se modifica
- [ ] Movimiento manual: Afecta inventario correctamente
- [ ] Movimiento rechazado: Revierte cambios

### Sincronización
- [ ] Con internet: syncStatus = synced después de 2s
- [ ] Sin internet: syncStatus = pendingSync se mantiene
- [ ] Sin internet: Escritura local funciona ✓
- [ ] Reconectar: syncAll() se ejecuta automáticamente
- [ ] Reintentos exponenciales funcionan (500ms, 1s, 2s)
- [ ] Errores de sync se manejan sin crashes
- [ ] Datos pendientes se syncan después de reconectar

### Alertas
- [ ] Stock bajo genera alerta automática
- [ ] Lote próximo a vencer genera alerta
- [ ] Alertas aparecen en página de alertas
- [ ] Eliminar alerta funciona

### Datos y Persistencia
- [ ] Datos persisten después de cerrar app
- [ ] Base de datos local no está corrupta
- [ ] Campos `createdAt`, `updatedAt`, `syncStatus` están presentes
- [ ] No hay registros duplicados después de sync

### UI/UX
- [ ] Loading states funcionan
- [ ] Empty states muestran correctamente
- [ ] Error states muestran mensajes útiles
- [ ] Offline indicator visible cuando no hay conexión
- [ ] Sync status chips muestran estado correcto
- [ ] Botones están deshabilitados cuando es apropiado

---

## ALTA - Debería estar antes de release

### Tests
- [ ] `flutter test` ejecuta todos los tests sin errores
- [ ] Unit tests de RulesService pasan
- [ ] Unit tests de PermissionService pasan
- [ ] Widget tests de account states pasan
- [ ] Tests de inventario pasan
- [ ] Cobertura de tests > 70%

### Documentación
- [ ] README actualizado con flujo completo
- [ ] README incluye instrucciones de setup
- [ ] README incluye usuarios de prueba
- [ ] `docs/plan_equipo.md` actualizado
- [ ] `docs/pruebas.md` completo
- [ ] `docs/bugs-backlog.md` actualizado

### Firestore
- [ ] Firebase rules están configuradas correctamente
- [ ] No hay permisos abiertos (allow read, write)
- [ ] Datos se syncan correctamente a Firestore
- [ ] Índices de Firestore creados si es necesario

### Android Signing
- [ ] Keystore creado (`~/keystore.jks`)
- [ ] APK firmado con clave release
- [ ] firma.properties configurado (si aplica)

---

## MEDIA - Post-MVP

### Performance
- [ ] App no freezea durante sync
- [ ] UI responde durante operaciones en background
- [ ] Scroll de listas es fluido
- [ ] No hay memory leaks obvios

### CI/CD
- [ ] GitHub Actions workflow creado
- [ ] Workflow compila APK automáticamente
- [ ] Workflow ejecuta tests automáticamente
- [ ] Releases automáticas en tag

### Otros
- [ ] iOS build no rompe (flutter build ios --release)
- [ ] App se puede compartir/distribuir
- [ ] Version en pubspec.yaml está actualizada

---