import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// In-app / push notification type.
@JsonEnum(alwaysCreate: true)
enum NotificationType {
  @JsonValue('sale') sale,
  @JsonValue('low_stock') lowStock,
  @JsonValue('expense') expense,
  @JsonValue('staff_invite') staffInvite,
  @JsonValue('subscription') subscription,
  @JsonValue('system') system,
}

/// A user-facing notification.
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'business_id') String? businessId,
    required NotificationType type,
    required String title,
    String? body,
    /// Arbitrary payload (deep-link target, sale id, etc.).
    Map<String, dynamic>? data,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  const AppNotification._();

  bool get isRead => readAt != null;
}
