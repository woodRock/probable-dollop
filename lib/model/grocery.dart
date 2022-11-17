/// Grocery Model - grocery.dart
/// ============================
/// This is the Grocery Model, it represents a grocery from a supermarket.
class Grocery {
  final int id;
  final String icon;
  final String name;
  final double price;

  const Grocery({
    required this.id,
    required this.icon,
    required this.name,
    required this.price,
  });

  /// Convert a Grocery into a Map. The keys must correspond to the names of the
  /// columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'price': price,
    };
  }

  /// Shows the contents of a grocery object in a format suitable for debugging.
  @override
  String toString() {
    return 'Grocery{id: $id, icon: $icon, name: $name, price: $price}';
  }

  /// Two groceries are equal to each other, if they have matching ids.
  @override
  bool operator ==(other) {
    if (other is! Grocery) {
      return false;
    }
    return id == other.id && name == other.name;
  }

  /// Hash code is the id for the grocery.
  @override
  int get hashCode => (id).hashCode;
}
