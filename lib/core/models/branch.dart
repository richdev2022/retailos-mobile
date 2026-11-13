import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';
part 'branch.g.dart';

/// A physical branch / store location belonging to a business.
@freezed
class Branch with _$Branch {
  const factory Branch({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String name,
    String? phone,
    String? address,
    String? managerId,
    @Default(true) bool active,
    @Default(false) bool isHeadquarters,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) =>
      _$BranchFromJson(json);
}
