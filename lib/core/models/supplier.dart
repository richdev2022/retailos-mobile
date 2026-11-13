import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

/// A supplier / vendor.
@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? category,
    /// Amount owed to this supplier (minor units).
    @JsonKey(name: 'payable_minor') @Default(0) int payableMinor,
    String? note,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}
