import 'package:equatable/equatable.dart';

class CartTotals extends Equatable {
  final double subtotal;
  final double vat;
  final double grandTotal;

  const CartTotals({
    required this.subtotal,
    required this.vat,
    required this.grandTotal,
  });

  factory CartTotals.empty() => CartTotals(subtotal: 0, vat: 0, grandTotal: 0);

  @override
  List<Object?> get props => [subtotal, vat, grandTotal];

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      vat: (json['vat'] as num? ?? 0.0).toDouble(),
      grandTotal: (json['grandTotal'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'subtotal': subtotal, 'vat': vat, 'grandTotal': grandTotal};
  }
}
