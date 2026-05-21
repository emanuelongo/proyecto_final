import 'app_database.dart' as db;
import '../models/insumo.dart' as model;
import '../models/lote.dart' as model;
import '../models/solicitud.dart' as model;
import '../models/alerta.dart' as model;
import '../models/movimiento.dart' as model;

model.Insumo insumoFromDb(db.Insumo row) {
  return model.Insumo(
    id: row.id,
    name: row.name,
    unit: row.unit,
    totalQuantity: row.totalQuantity,
    status: model.InventoryStatus.values.byName(row.status),
    lowStockThreshold: row.lowStockThreshold,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: model.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Insumo insumoToDb(model.Insumo insumo) {
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

model.Lote loteFromDb(db.Lote row) {
  return model.Lote(
    id: row.id,
    insumoId: row.insumoId,
    quantity: row.quantity,
    expirationDate: row.expirationDate,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: model.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Lote loteToDb(model.Lote lote) {
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

model.Solicitud solicitudFromDb(db.Solicitud row) {
  return model.Solicitud(
    id: row.id,
    insumoId: row.insumoId,
    requestedBy: row.requestedBy,
    quantity: row.quantity,
    status: model.SolicitudStatus.values.byName(row.status),
    reviewerId: row.reviewerId,
    rejectionReason: row.rejectionReason,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    syncStatus: model.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Solicitud solicitudToDb(model.Solicitud solicitud) {
  return db.Solicitud(
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

model.Alerta alertaFromDb(db.Alerta row) {
  return model.Alerta(
    id: row.id,
    insumoId: row.insumoId,
    type: model.AlertType.values.byName(row.type),
    message: row.message,
    createdAt: row.createdAt,
    resolved: row.resolved,
    syncStatus: model.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Alerta alertaToDb(model.Alerta alerta) {
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

model.Movimiento movimientoFromDb(db.Movimiento row) {
  return model.Movimiento(
    id: row.id,
    insumoId: row.insumoId,
    loteId: row.loteId,
    type: model.MovementType.values.byName(row.type),
    quantity: row.quantity,
    createdBy: row.createdBy,
    createdAt: row.createdAt,
    syncStatus: model.SyncStatus.values.byName(row.syncStatus),
  );
}

db.Movimiento movimientoToDb(model.Movimiento movimiento) {
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
