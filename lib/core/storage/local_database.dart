import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

// ===========================================================================
// Tables
//
// All tables carry a `syncId` (client-generated UUID used for idempotency),
// a `serverId` (the backend's canonical id, nullable until first sync), a
// `dirty` flag (true when local changes haven't been pushed yet), and a
// `lastSyncedAt` timestamp.
//
// Money fields are int minor units. DateTimes are UTC.
// ===========================================================================

/// Mirror of [Product] with sync metadata.
class LocalProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get priceMinor => integer().withDefault(const Constant(0))();
  IntColumn get costMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxBps => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('piece'))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(true))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(0))();
  IntColumn get stockOnHand => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Local sales (POS transactions). Items + payments are stored as JSON blobs.
class LocalSales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get cashierId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get receiptNo => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get balanceMinor => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  /// JSON-encoded list of SaleItem.
  TextColumn get itemsJson => text().withDefault(const Constant('[]'))();
  /// JSON-encoded list of SalePayment.
  TextColumn get paymentsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get soldAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Inventory movements pending sync (payload = full JSON snapshot).
class LocalStockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get productId => text()();
  TextColumn get type => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get note => text().nullable()();
  /// Full JSON payload (used when pushing).
  TextColumn get payload => text()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get movementAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get recordedBy => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  IntColumn get amountMinor => integer().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get payload => text()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get expendedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalCustomers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get balanceMinor => integer().withDefault(const Constant(0))();
  IntColumn get lifetimeValueMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get visits => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class LocalSuppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get payableMinor => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// The outbound sync queue. One row per pending mutation. The sync engine
/// drains this in batches; status moves pending → processing → synced/failed.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// e.g. "product.create", "sale.create", "stock.movement", "expense.create".
  TextColumn get operation => text()();
  /// Entity type this row pertains to ("product", "sale", ...).
  TextColumn get entity => text()();
  /// JSON payload to push to the backend.
  TextColumn get payload => text()();
  /// Client-generated idempotency key (UUID).
  TextColumn get syncId => text()();
  /// One of: pending, processing, synced, failed.
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Generic key-value store for sync cursors, last-sync timestamps, etc.
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Status of a queued sync operation.
enum SyncStatus {
  pending,
  processing,
  synced,
  failed,
}

SyncStatus parseSyncStatus(String? s) {
  switch (s) {
    case 'processing':
      return SyncStatus.processing;
    case 'synced':
      return SyncStatus.synced;
    case 'failed':
      return SyncStatus.failed;
    case 'pending':
    default:
      return SyncStatus.pending;
  }
}

// ===========================================================================
// Database
// ===========================================================================

@DriftDatabase(tables: [
  LocalProducts,
  LocalSales,
  LocalStockMovements,
  LocalExpenses,
  LocalCustomers,
  LocalSuppliers,
  SyncQueue,
  KeyValues,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_open());

  /// Constructor for tests that accepts a custom executor.
  LocalDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // ---- Products ---------------------------------------------------------

  Future<List<LocalProduct>> getAllProducts() => select(localProducts).get();

  Future<List<LocalProduct>> getDirtyProducts() =>
      (select(localProducts)..where((t) => t.dirty.equals(true))).get();

  Future<int> upsertProduct(LocalProductsCompanion entry) =>
      into(localProducts).insertOnConflictUpdate(entry);

  Future<int> markProductDirty(int id) =>
      (update(localProducts)..where((t) => t.id.equals(id))).write(
        LocalProductsCompanion(
          dirty: const Value(true),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<int> markProductSynced(int localId, String? serverId) =>
      (update(localProducts)..where((t) => t.id.equals(localId))).write(
        LocalProductsCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<List<LocalProduct>> getProductsSince(DateTime since) =>
      (select(localProducts)
            ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
          .get();

  // ---- Sales ------------------------------------------------------------

  Future<int> upsertSale(LocalSalesCompanion entry) =>
      into(localSales).insertOnConflictUpdate(entry);

  Future<List<LocalSale>> getDirtySales() =>
      (select(localSales)..where((t) => t.dirty.equals(true))).get();

  Future<int> markSaleSynced(int localId, String? serverId) =>
      (update(localSales)..where((t) => t.id.equals(localId))).write(
        LocalSalesCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  // ---- Stock movements --------------------------------------------------

  Future<int> enqueueStockMovement(LocalStockMovementsCompanion entry) =>
      into(localStockMovements).insert(entry);

  Future<int> markStockMovementSynced(int id, String? serverId) =>
      (update(localStockMovements)..where((t) => t.id.equals(id))).write(
        LocalStockMovementsCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
        ),
      );

  // ---- Expenses ---------------------------------------------------------

  Future<int> upsertExpense(LocalExpensesCompanion entry) =>
      into(localExpenses).insertOnConflictUpdate(entry);

  Future<int> markExpenseSynced(int id, String? serverId) =>
      (update(localExpenses)..where((t) => t.id.equals(id))).write(
        LocalExpensesCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  // ---- Customers / Suppliers -------------------------------------------

  Future<int> upsertCustomer(LocalCustomersCompanion entry) =>
      into(localCustomers).insertOnConflictUpdate(entry);

  Future<int> markCustomerSynced(int id, String? serverId) =>
      (update(localCustomers)..where((t) => t.id.equals(id))).write(
        LocalCustomersCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<int> upsertSupplier(LocalSuppliersCompanion entry) =>
      into(localSuppliers).insertOnConflictUpdate(entry);

  Future<int> markSupplierSynced(int id, String? serverId) =>
      (update(localSuppliers)..where((t) => t.id.equals(id))).write(
        LocalSuppliersCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  // ---- Sync queue -------------------------------------------------------

  Future<int> enqueueSync(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<List<SyncQueueData>> getPendingSync({int count = 50}) =>
      (select(syncQueue)
            ..where((t) => t.status.isIn(['pending', 'failed']))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(count))
          .get();

  Future<void> markQueueProcessing(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          status: const Value('processing'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> markQueueSynced(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          status: const Value('synced'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> markQueueFailed(int id, String error) async {
    // Increment attempts atomically via raw SQL (Companion can't express +1).
    await customUpdate(
      'UPDATE sync_queue SET status = ?, attempts = attempts + 1, '
      'last_error = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withString('failed'),
        Variable.withString(error),
        Variable.withDateTime(DateTime.now().toUtc()),
        Variable.withInt(id),
      ],
      updates: {syncQueue},
    );
  }

  Future<void> clearSynced() =>
      (delete(syncQueue)..where((t) => t.status.equals('synced'))).go();

  Future<int> countPending() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.isIn(['pending', 'failed', 'processing']));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ---- Key / value ------------------------------------------------------

  Future<String?> readKey(String key) async {
    final row = await (select(keyValues)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> writeKey(String key, String value) =>
      into(keyValues).insertOnConflictUpdate(
        KeyValuesCompanion(key: Value(key), value: Value(value)),
      );

  // ---- Reconcile after push ----

  /// After a successful push, the backend echoes the canonical record (with a
  /// stable server id). This marks the matching local row (looked up by
  /// [syncId]) as synced and stamps its server id. [entity] is one of:
  /// `product`, `sale`, `expense`, `customer`, `supplier`, `stock_movement`.
  Future<void> reconcilePushed(
    String entity,
    String syncId,
    String? serverId,
  ) async {
    final now = DateTime.now().toUtc();
    switch (entity) {
      case 'product':
        await (update(localProducts)..where((t) => t.syncId.equals(syncId)))
            .write(LocalProductsCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
          updatedAt: Value(now),
        ));
        break;
      case 'sale':
        await (update(localSales)..where((t) => t.syncId.equals(syncId)))
            .write(LocalSalesCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
          updatedAt: Value(now),
        ));
        break;
      case 'expense':
        await (update(localExpenses)..where((t) => t.syncId.equals(syncId)))
            .write(LocalExpensesCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
          updatedAt: Value(now),
        ));
        break;
      case 'customer':
        await (update(localCustomers)..where((t) => t.syncId.equals(syncId)))
            .write(LocalCustomersCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
          updatedAt: Value(now),
        ));
        break;
      case 'supplier':
        await (update(localSuppliers)..where((t) => t.syncId.equals(syncId)))
            .write(LocalSuppliersCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
          updatedAt: Value(now),
        ));
        break;
      case 'stock_movement':
        await (update(localStockMovements)
              ..where((t) => t.syncId.equals(syncId)))
            .write(LocalStockMovementsCompanion(
          serverId: Value(serverId),
          dirty: const Value(false),
          lastSyncedAt: Value(now),
        ));
        break;
      default:
        break;
    }
  }

  // ---- Maintenance ------------------------------------------------------

  /// Clears all local data (used on logout when configured).
  Future<void> clearAll() async {
    await batch((b) {
      b.deleteAll(localProducts);
      b.deleteAll(localSales);
      b.deleteAll(localStockMovements);
      b.deleteAll(localExpenses);
      b.deleteAll(localCustomers);
      b.deleteAll(localSuppliers);
      b.deleteAll(syncQueue);
      b.deleteAll(keyValues);
    });
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'retailos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
