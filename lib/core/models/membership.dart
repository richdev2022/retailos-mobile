import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

/// A user's membership (role) in a business.
@JsonEnum(alwaysCreate: true)
enum BusinessRole {
  @JsonValue('owner') owner,
  @JsonValue('admin') admin,
  @JsonValue('manager') manager,
  @JsonValue('cashier') cashier,
  @JsonValue('staff') staff,
  @JsonValue('accountant') accountant,
}

@freezed
class Membership with _$Membership {
  const factory Membership({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'branch_id') String? branchId,
    required BusinessRole role,
    @Default(true) bool active,
    @JsonKey(name: 'invited_by') String? invitedBy,
    @JsonKey(name: 'accepted_at') DateTime? acceptedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
