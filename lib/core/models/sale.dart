import 'package:freezed_annotation/freezed_annotation.dart';
import 'sale_item.dart';
import 'sale_payment.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

/// Sale lifecycle status.
@JsonEnum(alwaysCreate: true)
enum SaleStatus {
  @JsonValue('draft') draft,
  @JsonValue('pending') pending,
  @JsonValue('completed') completed,
  @JsonValue('voided') voided,
  @JsonValue('refunded') refunded,
  @JsonValue('on_credit') onCredit,
}

/// A point-of-sale transaction (receipt).
///
/// Money is minor units. [items] and [payments] are nested documents.
/// A `syncId` (UUID) is assigned client-side for idempotent push.
@freezed
class Sale with _$Sale {
  const factory Sale({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'cashier_id') String? cashierId,
    @JsonKey(name: 'customer_id') String? customerId,
    /// Human-readable receipt number (e.g. ROS-000123).
    @JsonKey(name: 'receipt_no') String? receiptNo,
    required SaleStatus status,
    /// Client-generated idempotency key for sync.
    @JsonKey(name: 'sync_id') String? syncId,
    /// Subtotal before tax/discount (minor units).
    @JsonKey(name: 'subtotal_minor') @Default(0) int subtotalMinor,
    /// Discount applied (minor units).
    @JsonKey(name: 'discount_minor') @Default(0) int discountMinor,
    /// Tax applied (minor units).
    @JsonKey(name: 'tax_minor') @Default(0) int taxMinor,
    /// Total amount charged (minor units).
    @JsonKey(name: 'total_minor') @Default(0) int totalMinor,
    /// Total amount paid (minor units).
    @JsonKey(name: 'paid_minor') @Default(0) int paidMinor,
    /// Outstanding balance (minor units) — set when on_credit / refunded.
    @JsonKey(name: 'balance_minor') @Default(0) int balanceMinor,
    String? note,
    @Default([]) List<SaleItem> items,
    @Default([]) List<SalePayment> payments,
    @JsonKey(name: 'sold_at') DateTime? soldAt,
    @JsonKey(name: 'voided_at') DateTime? voidedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
}
