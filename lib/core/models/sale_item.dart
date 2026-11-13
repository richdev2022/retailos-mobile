import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_item.freezed.dart';
part 'sale_item.g.dart';

/// A single line item on a sale.
///
/// Money is minor units. `lineTotalMinor` should equal
/// `(priceMinor - discountMinor) * quantity`.
@freezed
class SaleItem with _$SaleItem {
  const factory SaleItem({
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'product_name') String? productName,
    String? sku,
    @Default(1) int quantity,
    /// Unit selling price (minor units).
    @JsonKey(name: 'price_minor') @Default(0) int priceMinor,
    /// Per-line discount (minor units).
    @JsonKey(name: 'discount_minor') @Default(0) int discountMinor,
    /// Tax for this line (minor units).
    @JsonKey(name: 'tax_minor') @Default(0) int taxMinor,
    /// Total for this line (minor units).
    @JsonKey(name: 'line_total_minor') @Default(0) int lineTotalMinor,
  }) = _SaleItem;

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
}
