import 'package:freezed_annotation/freezed_annotation.dart';
import 'subscription_plan.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Subscription lifecycle status.
@JsonEnum(alwaysCreate: true)
enum SubscriptionStatus {
  @JsonValue('trialing') trialing,
  @JsonValue('active') active,
  @JsonValue('past_due') pastDue,
  @JsonValue('canceled') canceled,
  @JsonValue('expired') expired,
}

/// A business's active subscription.
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'plan_id') required String planId,
    SubscriptionPlan? plan,
    required SubscriptionStatus status,
    @Default(true) bool autoRenew,
    @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'trial_ends_at') DateTime? trialEndsAt,
    @JsonKey(name: 'canceled_at') DateTime? canceledAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  const Subscription._();

  bool get isActive => status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;
}
