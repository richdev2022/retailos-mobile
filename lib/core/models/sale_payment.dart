import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_payment.freezed.dart';
part 'sale_payment.g.dart';

/// Payment method for a sale.
@JsonEnum(alwaysCreate: true)
enum PaymentMethod {
  @JsonValue('cash') cash,
  @JsonValue('card') card,
  @JsonValue('transfer') transfer,
  @JsonValue('ussd') ussd,
  @JsonValue('pos') pos,
  @JsonValue('wallet') wallet,
  @JsonValue('credit') credit,
}

/// A payment applied to a sale.
@freezed
class SalePayment with _$SalePayment {
  const factory SalePayment({
    @JsonKey(name: 'method') required PaymentMethod method,
    /// Amount paid (minor units).
    @JsonKey(name: 'amount_minor') @Default(0) int amountMinor,
    String? reference,
    /// For card / POS: last 4 digits of the card / terminal id.
    String? meta,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
  }) = _SalePayment;

  factory SalePayment.fromJson(Map<String, dynamic> json) =>
      _$SalePaymentFromJson(json);
}
