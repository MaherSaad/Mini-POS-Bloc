// File: lib/src/cart/cart_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../catalog/models/item.dart';
import 'models/cart_line.dart';
import 'models/cart_totals.dart';

/// ------ Events ------
sealed class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddItem extends CartEvent {
  final Item item;

  AddItem(this.item);
}

class RemoveItem extends CartEvent {
  final String itemId;

  RemoveItem(this.itemId);
}

class ChangeQty extends CartEvent {
  final String itemId;
  final int qty;

  ChangeQty(this.itemId, this.qty);
}

class ChangeDiscount extends CartEvent {
  final String itemId;
  final double discount;

  ChangeDiscount(this.itemId, this.discount);
}

class ClearCart extends CartEvent {}

/// ------ States ------
class CartState extends Equatable {
  final List<CartLine> lines;
  final CartTotals totals;

  CartState({required this.lines, required this.totals});

  // Creates empty Cart State
  factory CartState.empty() => CartState(lines: [], totals: CartTotals.empty());

  @override
  List<Object?> get props => [lines, totals];
}

/// ------ Cart BLoC ------
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(CartState.empty()) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<ChangeQty>(_onChangeQty);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ClearCart>(_onClearCart);
  }

  // Handles adding an item to the cart
  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    final lines = List<CartLine>.from(state.lines);
    final existingIndex = lines.indexWhere(
      (line) => line.item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      // Item exists, increment quantity
      final existingLine = lines[existingIndex];
      lines[existingIndex] = existingLine.copyWith(qty: existingLine.qty + 1);
    } else {
      // New item, add to cart
      lines.add(CartLine(item: event.item, qty: 1));
    }

    emit(CartState(lines: lines, totals: calculateTotals(lines)));
  }

  // Handles removing an item from the cart
  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final lines = state.lines
        .where((line) => line.item.id != event.itemId)
        .toList();
    emit(CartState(lines: lines, totals: calculateTotals(lines)));
  }

  // Handles changing the quantity of an item in the cart
  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    if (event.qty <= 0) {
      add(RemoveItem(event.itemId));
      return;
    }

    final lines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return line.copyWith(qty: event.qty);
      }
      return line;
    }).toList();

    emit(CartState(lines: lines, totals: calculateTotals(lines)));
  }

  // Handles changing the discount for an item in the cart
  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    final discount = event.discount;
    if (discount < 0.0 || discount > 1.0) {
      throw ArgumentError("Discount must be between 0.0 and 1.0");
    }
    final lines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return line.copyWith(discount: discount);
      }
      return line;
    }).toList();

    emit(CartState(lines: lines, totals: calculateTotals(lines)));
  }

  // Handles clearing the cart
  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartState.empty());
  }

  ///Calculate cart totals
  CartTotals calculateTotals(List<CartLine> lines) {
    final subtotal = lines.fold(0.0, (sum, line) => sum + line.lineNet);
    final vat = subtotal * 0.15;
    final grandTotal = subtotal + vat;
    return CartTotals(subtotal: subtotal, vat: vat, grandTotal: grandTotal);
  }

  ///handle Hydrated Bloc fromJson
  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final lines = (json['lines'] as List)
          .map((e) => CartLine.fromJson(e))
          .toList();
      final totals = CartTotals.fromJson(json['totals']);
      return CartState(lines: lines, totals: totals);
    } catch (_) {
      return null;
    }
  }

  ///handle Hydrated Bloc toJson
  @override
  Map<String, dynamic>? toJson(CartState state) {
    return {
      'lines': state.lines.map((e) => e.toJson()).toList(),
      'totals': state.totals.toJson(),
    };
  }
}
