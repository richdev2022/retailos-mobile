import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// A RetailOS user account.
///
/// All [DateTime]s are UTC over the wire. Money fields (none here) are minor
/// units. See PRD §2.2 / §4.1.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? phone,
    required String fullName,
    String? avatarUrl,
    String? defaultBusinessId,
    @Default('en') String locale,
    @Default('NG') String country,
    @Default(true) bool emailVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
