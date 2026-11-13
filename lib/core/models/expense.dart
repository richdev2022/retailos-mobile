import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Expense / outgoing payment category.
@JsonEnum(alwaysCreate: true)
enum ExpenseCategory {
  @JsonValue('rent') rent,
  @JsonValue('utilities') utilities,
  @JsonValue('salaries') salaries,
  @JsonValue('transport') transport,
  @JsonValue('marketing') marketing,
  @JsonValue('maintenance') maintenance,
  @JsonValue('supplies') supplies,
  @JsonValue('miscellaneous') miscellaneous,
}

/// A business expense.
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'recorded_by') String? recordedBy,
    @JsonKey(name: 'supplier_id') String? supplierId,
    required String title,
    String? description,
    @JsonKey(name: 'category') required ExpenseCategory category,
    /// Amount (minor units).
    @JsonKey(name: 'amount_minor') @Default(0) int amountMinor,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'sync_id') String? syncId,
    @JsonKey(name: 'expended_at') DateTime? expendedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
