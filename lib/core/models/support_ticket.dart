import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

/// Support ticket lifecycle status.
@JsonEnum(alwaysCreate: true)
enum TicketStatus {
  @JsonValue('open') open,
  @JsonValue('pending') pending,
  @JsonValue('resolved') resolved,
  @JsonValue('closed') closed,
}

/// Support ticket priority.
@JsonEnum(alwaysCreate: true)
enum TicketPriority {
  @JsonValue('low') low,
  @JsonValue('normal') normal,
  @JsonValue('high') high,
  @JsonValue('urgent') urgent,
}

/// A customer support ticket.
@freezed
class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'user_id') required String userId,
    required String subject,
    String? description,
    @Default(TicketStatus.open) TicketStatus status,
    @Default(TicketPriority.normal) TicketPriority priority,
    String? category,
    @Default(0) int messagesCount,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);
}
