import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final double price;

  const Item({required this.id, required this.name, required this.price});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  @override
  List<Object?> get props => [id, name, price];
}
