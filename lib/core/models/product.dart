import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Product unit / packaging.
enum ProductUnit {
  @JsonValue('piece') piece,
  @JsonValue('box') box,
  @JsonValue('carton') carton,
  @JsonValue('kg') kg,
  @JsonValue('litre') litre,
  @JsonValue('pack') pack,
}

/// A sellable product / SKU.
///
/// All money fields are **minor units** (kobo for NGN). Never use double.
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') String? branchId,
    required String name,
    String? sku,
    String? barcode,
    String? category,
    String? description,
    String? imageUrl,
    /// Selling price (minor units).
    @JsonKey(name: 'price_minor') @Default(0) int priceMinor,
    /// Cost price (minor units).
    @JsonKey(name: 'cost_minor') @Default(0) int costMinor,
    /// Tax rate as basis points (e.g. 750 = 7.5%).
    @JsonKey(name: 'tax_bps') @Default(0) int taxBps,
    @Default(ProductUnit.piece) ProductUnit unit,
    @JsonKey(name: 'track_inventory') @Default(true) bool trackInventory,
    @JsonKey(name: 'low_stock_threshold') @Default(0) int lowStockThreshold,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
