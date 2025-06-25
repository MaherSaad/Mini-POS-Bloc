import 'package:equatable/equatable.dart';
import 'package:mini_pos/src/catalog/models/item.dart';

class CartLine extends Equatable {
  final Item item;
  final int qty;
  final double discount; // % between 0 and 1

  const CartLine({required this.item, required this.qty, this.discount = 0.0});

  double get lineNet => item.price * qty * (1 - discount);

  @override
  List<Object?> get props => [item, qty, discount];

  CartLine copyWith({Item? item, int? qty, double? discount}) {
    return CartLine(
      item: item ?? this.item,
      qty: qty ?? this.qty,
      discount: discount ?? this.discount,
    );
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      qty: json['qty'] as int? ?? 1,
      discount: (json['discount'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'item': item.toJson(), 'qty': qty, 'discount': discount};
  }
}
