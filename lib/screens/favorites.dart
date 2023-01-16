/// Favorites screen - favorite.dart
/// ===============================
/// The favorites screen gives a list of the groceries that have been favorited.
/// It calculates the total cost of the list, and displays this at the bottom.
import 'dart:collection';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/grocery.dart';

class FavoritesPage extends StatefulWidget {
  // SplaySet accepts a comparator, so we can sort favorites alphabetically.
  final saved = SplayTreeSet<Grocery>((a, b) => a.name.compareTo(b.name));

  FavoritesPage({super.key, required Set<Grocery> saved}){
    this.saved.addAll(saved);
  }

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// The users first name, used to identify their favorites.
  late String firstName;
  final _biggerFont = const TextStyle(fontSize: 18);

  /// Retrieve snapshot of the SQLite database on open.
  @override
  void initState() {
    super.initState();
    refreshGroceries();
  }

  /// Refreshes the snapshot of the groceries database.
  Future<void> refreshGroceries() async {
    // Gets the users name from the preferences.
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
    });
  }

  /// Remove a grocery from favorites.
  void _removeFromFavorites(Grocery grocery) {
    setState(() {
      widget.saved.remove(grocery);
    });
  }

  /// Changes the first name of the user to a random WordPari
  Future<void> _setRandomName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'default';
      prefs.setString('first_name', WordPair.random().toString());
      firstName = prefs.getString('first_name')!;
    });
  }

  /// Calculate and format the total price of all favorite groceries.
  String calculateTotal() {
    // Calculate the total price for all items in favorites.
    var prices = widget.saved.map((e) => e.price);
    // Check if favorites empty, to avoid trying to reduce an empty list.
    var subtotal = prices.isNotEmpty
        ? prices.reduce((sum, element) => sum + element)
        : 0.0;
    // Round the price to 2 decimal places, as convention with money totals.
    var total = subtotal.toStringAsFixed(2);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Construct a list of favorites tiles (this can be empty!)
    final tiles = widget.saved.map(
      (grocery) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(grocery.icon),
          ),
          title: Text(
            grocery.name,
            style: _biggerFont,
          ),
          subtitle: Text('\$${grocery.price.toString()}'),
          trailing: GestureDetector(
            child: const Icon(Icons.delete),
            onTap: () => _removeFromFavorites(grocery),
          ),
        );
      },
    );
    // Check if there are favorites, otherwise return empty list.
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(context: context, tiles: tiles).toList()
        : <Widget>[];
    // Favorites screen.
    return Scaffold(
      appBar: AppBar(
        title: Text('$firstName\'s favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _setRandomName,
            tooltip: 'Set random first name',
          ),
        ],
      ),
      // Give the favorites list.
      body: ListView(children: divided),
      // Display the total cost at the bottom of the page.
      bottomSheet: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(Icons.shopping_cart),
        ),
        title: Text('Total: \$${calculateTotal()}'),
        tileColor: Colors.black,
        textColor: Colors.white,
      ),
      // TODO share button offers prompt to share the grocery list as text.
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.share),
      ),
    );
  }
}
