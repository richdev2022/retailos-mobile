import 'package:freezed_annotation/freezed_annotation.dart';

part 'business.freezed.dart';
part 'business.g.dart';

/// A business (merchant) account in RetailOS.
///
/// Money fields are minor units (kobo for NGN).
/// All [DateTime]s are UTC.
@freezed
class Business with _$Business {
  const factory Business({
    required String id,
    required String name,
    String? category,
    String? phone,
    String? email,
    String? address,
    @Default('NG') String country,
    @Default('NGN') String currency,
    String? taxId,
    String? logoUrl,
    @JsonKey(name: 'owner_id') required String ownerId,
    @Default(false) bool verified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);
}
