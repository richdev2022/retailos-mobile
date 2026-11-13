import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_movement.freezed.dart';
part 'inventory_movement.g.dart';

/// Direction of an inventory movement.
@JsonEnum(alwaysCreate: true)
enum MovementType {
  @JsonValue('in') in_, // purchases, returns-in, adjustments up
  @JsonValue('out') out_, // sales, damages, adjustments down
  @JsonValue('transfer') transfer,
  @JsonValue('adjustment') adjustment,
}

/// A single stock movement for a product.
@freezed
class InventoryMovement with _$InventoryMovement {
  const factory InventoryMovement({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'product_id') required String productId,
    required MovementType type,
    /// Signed quantity: positive = stock increases, negative = decreases.
    @Default(0) int quantity,
    @JsonKey(name: 'reference_type') String? referenceType,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'sync_id') String? syncId,
    String? note,
    @JsonKey(name: 'movement_at') DateTime? movementAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _InventoryMovement;

  factory InventoryMovement.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementFromJson(json);
}
