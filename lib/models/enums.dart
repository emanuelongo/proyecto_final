enum UserRole { auxiliar, docente, admin }

enum AccountStatus { pendingApproval, active, blocked }

enum InventoryStatus { available, lowStock, outOfStock, expired }

enum SolicitudStatus { requested, approved, rejected }

enum SyncStatus { synced, pendingSync, failedSync }

enum MovementType { inbound, outbound, adjustment }

enum AlertType { lowStock, expired }
