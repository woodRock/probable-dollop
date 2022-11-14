/// Grocery Model - grocery.dart
/// ============================
/// This is the Grocery Model, it represents a grocery from a supermarket.
class Grocery {
  final int id;
  final String name;
  final double price;

  const Grocery({
    required this.id,
    required this.name,
    required this.price,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Grocery{id: $id, name: $name, price: $price}';
  }
}