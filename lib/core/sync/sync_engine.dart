import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/local_database.dart';
import '../storage/secure_storage.dart';

/// Externally-visible snapshot of sync progress for the UI.
class SyncStatusState {
  const SyncStatusState({
    this.isOnline = false,
    this.isRunning = false,
    this.pending = 0,
    this.lastSyncedAt,
    this.lastError,
  });

  final bool isOnline;
  final bool isRunning;
  final int pending;
  final DateTime? lastSyncedAt;
  final String? lastError;

  SyncStatusState copyWith({
    bool? isOnline,
    bool? isRunning,
    int? pending,
    DateTime? lastSyncedAt,
    String? lastError,
  }) {
    return SyncStatusState(
      isOnline: isOnline ?? this.isOnline,
      isRunning: isRunning ?? this.isRunning,
      pending: pending ?? this.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError,
    );
  }

  @override
  String toString() =>
      'SyncStatusState(online=$isOnline, running=$isRunning, pending=$pending)';
}

/// Coordinates offline-first synchronization between the local Drift DB and
/// the RetailOS backend.
///
///   - [pushPending]: drain [SyncQueue] in batches via POST /sync/push.
///   - [pullChanges]: GET /sync/pull?lastSyncAt=<cursor> and reconcile.
///   - [runFullSync]: push then pull, atomic-ish.
///   - Listens to connectivity_plus: runs a full sync when the network
///     returns.
///
/// Screens watch [statusProvider] to render a sync indicator.
class SyncEngine {
  SyncEngine({
    required ApiClient apiClient,
    required LocalDatabase database,
    required SecureStorage secureStorage,
  })  : _api = apiClient,
        _db = database,
        _storage = secureStorage {
    _initConnectivity();
  }

  final ApiClient _api;
  final LocalDatabase _db;
  final SecureStorage _storage;

  final _controller = StreamController<SyncStatusState>.broadcast();
  SyncStatusState _state = const SyncStatusState();
  SyncStatusState get state => _state;
  Stream<SyncStatusState> get statusStream => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  Timer? _debounce;
  bool _disposed = false;

  static const _maxAttempts = 5;
  static const _cursorKey = 'sync.cursor';
  static const _lastSyncedKey = 'sync.lastSyncedAt';

  void _initConnectivity() {
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      _emit(_state.copyWith(isOnline: online));
      if (online) {
        // Debounce to avoid hammering when connectivity flaps.
        _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 2), () {
          if (!_disposed) runFullSync();
        });
      }
    });
  }

  // ---- Public API -------------------------------------------------------

  /// Drains the outbound sync queue.
  ///
  /// Each row is pushed to POST /sync/push with its `syncId` as the
  /// idempotency key. On failure the row's attempt count is incremented;
  /// rows that exceed [_maxAttempts] stay in `failed` status and surface
  /// in [state.lastError] (UI can offer a manual retry).
  Future<void> pushPending({int batchSize = 50}) async {
    if (_state.isRunning) return;
    _emit(_state.copyWith(isRunning: true, lastError: null));

    try {
      while (true) {
        final batch = await _db.getPendingSync(count: batchSize);
        if (batch.isEmpty) break;

        for (final item in batch) {
          await _db.markQueueProcessing(item.id);
          try {
            final response = await _api.post(
              ApiEndpoints.syncPush,
              data: {
                'operation': item.operation,
                'entity': item.entity,
                'sync_id': item.syncId,
                'payload': _decodePayload(item.payload),
              },
            );
            if (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300) {
              await _db.markQueueSynced(item.id);
              await _reconcilePushed(item, response.data);
            } else {
              final msg = 'Push failed (${response.statusCode}) for '
                  '${item.operation}/${item.syncId}';
              _log(msg);
              await _db.markQueueFailed(item.id, msg);
            }
          } catch (e) {
            final msg = e.toString();
            _log('Push error for ${item.operation}: $msg');
            await _db.markQueueFailed(item.id, msg);
          }
        }
      }
      await _db.clearSynced();
    } finally {
      final pending = await _db.countPending();
      _emit(_state.copyWith(isRunning: false, pending: pending));
    }
  }

  /// Pulls server-side changes since the last sync cursor and reconciles them
  /// into local tables.
  Future<void> pullChanges() async {
    if (!_state.isOnline) return;
    final cursor = await _storage.readKey(_cursorKey) ?? '';
    final lastSyncedAt = await _storage.readKey(_lastSyncedKey);
    _emit(_state.copyWith(isRunning: true, lastError: null));

    try {
      final response = await _api.get(
        ApiEndpoints.syncPull,
        queryParameters: {
          if (cursor.isNotEmpty) 'cursor': cursor,
          if (lastSyncedAt != null && lastSyncedAt.isNotEmpty)
            'lastSyncAt': lastSyncedAt,
        },
      );
      final data = response.data;
      if (data is! Map) {
        _emit(_state.copyWith(lastError: 'Malformed sync pull response.'));
        return;
      }

      await _applyPulled(data.cast<String, dynamic>());

      final newCursor = data['next_cursor']?.toString();
      if (newCursor != null && newCursor.isNotEmpty) {
        await _storage.writeKey(_cursorKey, newCursor);
      }
      final nowIso = DateTime.now().toUtc().toUtc().toIso8601String();
      await _storage.writeKey(_lastSyncedKey, nowIso);
      _emit(_state.copyWith(lastSyncedAt: DateTime.now().toUtc()));
    } catch (e) {
      _log('Pull error: $e');
      _emit(_state.copyWith(lastError: e.toString()));
    } finally {
      final pending = await _db.countPending();
      _emit(_state.copyWith(isRunning: false, pending: pending));
    }
  }

  /// Pushes pending local mutations, then pulls remote changes.
  Future<void> runFullSync() async {
    await pushPending();
    await pullChanges();
  }

  /// Manual retry hook (e.g. from an error banner's "Retry" button).
  Future<void> retryFailed() async {
    // Reset failed rows back to pending so pushPending picks them up.
    await _db.customUpdate(
      "UPDATE sync_queue SET status = 'pending', last_error = NULL "
      'WHERE status = ? AND attempts < ?',
      variables: [
        Variable.withString('failed'),
        Variable.withInt(_maxAttempts),
      ],
      updates: {_db.syncQueue},
    );
    await runFullSync();
  }

  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _connSub?.cancel();
    _controller.close();
  }

  // ---- Internals --------------------------------------------------------

  Future<void> _applyPulled(Map<String, dynamic> data) async {
    await _db.batch((b) {
      // Products ----------------------------------------------------------
      final products = data['products'];
      if (products is List) {
        for (final p in products) {
          if (p is! Map) continue;
          b.insert(
            _db.localProducts,
            _productFromServer(p.cast<String, dynamic>()),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
      // Customers ---------------------------------------------------------
      final customers = data['customers'];
      if (customers is List) {
        for (final c in customers) {
          if (c is! Map) continue;
          b.insert(
            _db.localCustomers,
            _customerFromServer(c.cast<String, dynamic>()),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
      // Suppliers ---------------------------------------------------------
      final suppliers = data['suppliers'];
      if (suppliers is List) {
        for (final s in suppliers) {
          if (s is! Map) continue;
          b.insert(
            _db.localSuppliers,
            _supplierFromServer(s.cast<String, dynamic>()),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });

    // Sales are applied one-by-one to keep the JSON columns simple.
    final sales = data['sales'];
    if (sales is List) {
      for (final s in sales) {
        if (s is! Map) continue;
        await _db.upsertSale(_saleFromServer(s.cast<String, dynamic>()));
      }
    }
  }

  LocalProductsCompanion _productFromServer(Map<String, dynamic> p) {
    return LocalProductsCompanion(
      id: const Value(absent()),
      serverId: Value(p['id']?.toString()),
      syncId: Value(p['sync_id']?.toString() ?? ''),
      businessId: Value(p['business_id']?.toString() ?? ''),
      branchId: Value(p['branch_id']?.toString()),
      name: Value(p['name']?.toString() ?? ''),
      sku: Value(p['sku']?.toString()),
      barcode: Value(p['barcode']?.toString()),
      category: Value(p['category']?.toString()),
      description: Value(p['description']?.toString()),
      imageUrl: Value(p['image_url']?.toString()),
      priceMinor: Value(_asInt(p['price_minor'])),
      costMinor: Value(_asInt(p['cost_minor'])),
      taxBps: Value(_asInt(p['tax_bps'])),
      unit: Value(p['unit']?.toString() ?? 'piece'),
      trackInventory: Value(p['track_inventory'] as bool? ?? true),
      lowStockThreshold: Value(_asInt(p['low_stock_threshold'])),
      stockOnHand: Value(_asInt(p['stock_on_hand'])),
      isActive: Value(p['is_active'] as bool? ?? true),
      dirty: const Value(false),
      lastSyncedAt: Value(DateTime.now().toUtc()),
      createdAt: Value(_asDate(p['created_at']) ?? DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }

  LocalCustomersCompanion _customerFromServer(Map<String, dynamic> c) {
    return LocalCustomersCompanion(
      serverId: Value(c['id']?.toString()),
      syncId: Value(c['sync_id']?.toString() ?? ''),
      businessId: Value(c['business_id']?.toString() ?? ''),
      branchId: Value(c['branch_id']?.toString()),
      name: Value(c['name']?.toString()),
      phone: Value(c['phone']?.toString()),
      email: Value(c['email']?.toString()),
      address: Value(c['address']?.toString()),
      balanceMinor: Value(_asInt(c['balance_minor'])),
      lifetimeValueMinor: Value(_asInt(c['lifetime_value_minor'])),
      visits: Value(_asInt(c['visits'])),
      note: Value(c['note']?.toString()),
      dirty: const Value(false),
      lastSyncedAt: Value(DateTime.now().toUtc()),
      createdAt: Value(_asDate(c['created_at']) ?? DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }

  LocalSuppliersCompanion _supplierFromServer(Map<String, dynamic> s) {
    return LocalSuppliersCompanion(
      serverId: Value(s['id']?.toString()),
      syncId: Value(s['sync_id']?.toString() ?? ''),
      businessId: Value(s['business_id']?.toString() ?? ''),
      name: Value(s['name']?.toString() ?? ''),
      contactPerson: Value(s['contact_person']?.toString()),
      phone: Value(s['phone']?.toString()),
      email: Value(s['email']?.toString()),
      address: Value(s['address']?.toString()),
      category: Value(s['category']?.toString()),
      payableMinor: Value(_asInt(s['payable_minor'])),
      note: Value(s['note']?.toString()),
      dirty: const Value(false),
      lastSyncedAt: Value(DateTime.now().toUtc()),
      createdAt: Value(_asDate(s['created_at']) ?? DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }

  LocalSalesCompanion _saleFromServer(Map<String, dynamic> s) {
    return LocalSalesCompanion(
      serverId: Value(s['id']?.toString()),
      syncId: Value(s['sync_id']?.toString() ?? ''),
      businessId: Value(s['business_id']?.toString() ?? ''),
      branchId: Value(s['branch_id']?.toString()),
      cashierId: Value(s['cashier_id']?.toString()),
      customerId: Value(s['customer_id']?.toString()),
      receiptNo: Value(s['receipt_no']?.toString()),
      status: Value(s['status']?.toString() ?? 'completed'),
      subtotalMinor: Value(_asInt(s['subtotal_minor'])),
      discountMinor: Value(_asInt(s['discount_minor'])),
      taxMinor: Value(_asInt(s['tax_minor'])),
      totalMinor: Value(_asInt(s['total_minor'])),
      paidMinor: Value(_asInt(s['paid_minor'])),
      balanceMinor: Value(_asInt(s['balance_minor'])),
      note: Value(s['note']?.toString()),
      itemsJson: Value(jsonEncode(s['items'] ?? [])),
      paymentsJson: Value(jsonEncode(s['payments'] ?? [])),
      dirty: const Value(false),
      soldAt: Value(_asDate(s['sold_at'])),
      lastSyncedAt: Value(DateTime.now().toUtc()),
      createdAt: Value(_asDate(s['created_at']) ?? DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }

  /// After a successful push, the backend may echo back the canonical record
  /// (with a stable server id). If so, mark the matching local row (looked up
  /// by syncId) as synced.
  Future<void> _reconcilePushed(SyncQueueData item, dynamic data) async {
    if (data is! Map) return;
    final serverId = data['id']?.toString();
    await _db.reconcilePushed(item.entity, item.syncId, serverId);
  }

  dynamic _decodePayload(String payload) {
    try {
      return jsonDecode(payload);
    } catch (_) {
      return payload;
    }
  }

  void _emit(SyncStatusState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  DateTime? _asDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      try {
        return DateTime.parse(v).toUtc();
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

void _log(Object? message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[SyncEngine] $message');
  }
}
