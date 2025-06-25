import 'package:equatable/equatable.dart';
import 'package:mini_pos/src/cart/cart_bloc.dart';

import 'cart_line.dart';
import 'cart_totals.dart';

class Receipt extends Equatable {
  final DateTime date;
  final List<CartLine> lines;
  final CartTotals totals;

  Receipt({required this.date, required this.lines, required this.totals});

  @override
  List<Object?> get props => [date, lines, totals];
}

Receipt buildReceipt(CartState state, DateTime dateTime) {
  return Receipt(date: dateTime, lines: state.lines, totals: state.totals);
}
