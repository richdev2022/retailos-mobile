import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';
part 'subscription_plan.g.dart';

/// Billing interval for a subscription plan.
@JsonEnum(alwaysCreate: true)
enum BillingInterval {
  @JsonValue('monthly') monthly,
  @JsonValue('quarterly') quarterly,
  @JsonValue('yearly') yearly,
}

/// A subscription tier / plan (e.g. Starter, Growth, Pro).
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    String? description,
    required BillingInterval interval,
    /// Price (minor units).
    @JsonKey(name: 'price_minor') @Default(0) int priceMinor,
    String currency,
    @Default(1) int branchLimit,
    @Default(0) int staffLimit,
    @Default(false) bool multiBranch,
    @Default(false) bool advancedReports,
    @Default(false) bool apiAccess,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}
