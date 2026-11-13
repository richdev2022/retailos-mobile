import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// A customer who buys from the business (walk-in customers are anonymous).
@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') String? branchId,
    String? name,
    String? phone,
    String? email,
    String? address,
    /// Outstanding credit balance (minor units).
    @JsonKey(name: 'balance_minor') @Default(0) int balanceMinor,
    /// Total lifetime spend (minor units).
    @JsonKey(name: 'lifetime_value_minor') @Default(0) int lifetimeValueMinor,
    @Default(0) int visits,
    String? note,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
