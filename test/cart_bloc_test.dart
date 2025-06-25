import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mini_pos/src/cart/cart_bloc.dart';
import 'package:mini_pos/src/catalog/models/item.dart';
import 'package:mini_pos/utils/money_extension.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  final itemA = Item(id: 'p01', name: 'Coffee', price: 2.50);
  final itemB = Item(id: 'p02', name: 'Bagel', price: 3.20);

  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('CartBloc', () {
    blocTest<CartBloc, CartState>(
      'adds two items and calculates totals',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(itemA))
        ..add(AddItem(itemB)),
      expect: () => [isA<CartState>(), isA<CartState>()],
      verify: (bloc) {
        final totals = bloc.state.totals;
        expect(totals.subtotal, 5.70);
        expect(totals.vat, 0.855);
        expect(totals.grandTotal, 6.555);
      },
    );

    blocTest<CartBloc, CartState>(
      'updates quantity and discount',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(itemA))
        ..add(ChangeQty(itemA.id, 3))
        ..add(ChangeDiscount(itemA.id, 0.1)),
      expect: () => [isA<CartState>(), isA<CartState>(), isA<CartState>()],
      verify: (bloc) {
        final line = bloc.state.lines.first;
        expect(line.qty, 3);
        expect(line.discount, 0.1);
        expect(bloc.state.totals.subtotal.asMoney, "6.75");
        expect(bloc.state.totals.vat.asMoney, "1.01");
        expect(bloc.state.totals.grandTotal.asMoney, "7.76");
      },
    );

    blocTest<CartBloc, CartState>(
      'clears cart',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(itemA))
        ..add(ClearCart()),
      expect: () => [isA<CartState>(), CartState.empty()],
    );

    blocTest<CartBloc, CartState>(
      'Discount must be between 0.0 and 1.0 else throws ArgumentError',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(itemA))
        ..add(ChangeDiscount(itemA.id, 2)),
      expect: () => [isA<CartState>()],
      errors: () => [isA<ArgumentError>()],
    );

    blocTest<CartBloc, CartState>(
      'add same item three times and check quantity',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(itemA))
        ..add(AddItem(itemA))
        ..add(AddItem(itemA)),
      expect: () => [isA<CartState>(), isA<CartState>(), isA<CartState>()],
      verify: (bloc) {
        final lines = bloc.state.lines;
        expect(lines.length, 1);
        expect(lines[0].qty, 3);
      },
    );
  });
}
