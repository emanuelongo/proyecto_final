import 'app_database.dart' as db;
import '../models/enums.dart' as enums;
import '../models/insumo.dart' as insumo_model;
import '../models/lote.dart' as lote_model;
import '../models/solicitud.dart' as solicitud_model;
import '../models/alerta.dart' as alerta_model;
import '../models/movimiento.dart' as movimiento_model;

insumo_model.Insumo insumoFromDb(db.Insumo row) {
  return insumo_model.Insumo(
    id: row.id,
    name: row.name,
    unit: row.unit,
    totalQuantity: row.totalQuantity,
    status: enums.InventoryStatus.values.byName(row.status),
    lowStockThreshold: row.lowStockThreshold,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: enums.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Insumo insumoToDb(insumo_model.Insumo insumo) {
  return db.Insumo(
    id: insumo.id,
    name: insumo.name,
    unit: insumo.unit,
    totalQuantity: insumo.totalQuantity,
    status: insumo.status.name,
    lowStockThreshold: insumo.lowStockThreshold,
    createdAt: insumo.createdAt,
    updatedAt: insumo.updatedAt,
    syncStatus: insumo.syncStatus.name,
  );
}

lote_model.Lote loteFromDb(db.Lote row) {
  return lote_model.Lote(
    id: row.id,
    insumoId: row.insumoId,
    quantity: row.quantity,
    expirationDate: row.expirationDate,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: enums.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Lote loteToDb(lote_model.Lote lote) {
  return db.Lote(
    id: lote.id,
    insumoId: lote.insumoId,
    quantity: lote.quantity,
    expirationDate: lote.expirationDate,
    createdAt: lote.createdAt,
    updatedAt: lote.updatedAt,
    syncStatus: lote.syncStatus.name,
  );
}

solicitud_model.Solicitud solicitudFromDb(db.Solicitude row) {
  return solicitud_model.Solicitud(
    id: row.id,
    insumoId: row.insumoId,
    requestedBy: row.requestedBy,
    quantity: row.quantity,
    status: enums.SolicitudStatus.values.byName(row.status),
    reviewerId: row.reviewerId,
    rejectionReason: row.rejectionReason,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: enums.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Solicitude solicitudToDb(solicitud_model.Solicitud solicitud) {
  return db.Solicitude(
    id: solicitud.id,
    insumoId: solicitud.insumoId,
    requestedBy: solicitud.requestedBy,
    quantity: solicitud.quantity,
    status: solicitud.status.name,
    reviewerId: solicitud.reviewerId,
    rejectionReason: solicitud.rejectionReason,
    createdAt: solicitud.createdAt,
    updatedAt: solicitud.updatedAt,
    syncStatus: solicitud.syncStatus.name,
  );
}

alerta_model.Alerta alertaFromDb(db.Alerta row) {
  return alerta_model.Alerta(
    id: row.id,
    insumoId: row.insumoId,
    type: enums.AlertType.values.byName(row.type),
    message: row.message,
    createdAt: row.createdAt,
    resolved: row.resolved,
    syncStatus: enums.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Alerta alertaToDb(alerta_model.Alerta alerta) {
  return db.Alerta(
    id: alerta.id,
    insumoId: alerta.insumoId,
    type: alerta.type.name,
    message: alerta.message,
    createdAt: alerta.createdAt,
    resolved: alerta.resolved,
    syncStatus: alerta.syncStatus.name,
  );
}

movimiento_model.Movimiento movimientoFromDb(db.Movimiento row) {
  return movimiento_model.Movimiento(
    id: row.id,
    insumoId: row.insumoId,
    loteId: row.loteId,
    type: enums.MovementType.values.byName(row.type),
    quantity: row.quantity,
    createdBy: row.createdBy,
    createdAt: row.createdAt,
    syncStatus: enums.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Movimiento movimientoToDb(movimiento_model.Movimiento movimiento) {
  return db.Movimiento(
    id: movimiento.id,
    insumoId: movimiento.insumoId,
    loteId: movimiento.loteId,
    type: movimiento.type.name,
    quantity: movimiento.quantity,
    createdBy: movimiento.createdBy,
    createdAt: movimiento.createdAt,
    syncStatus: movimiento.syncStatus.name,
  );
}
