import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/grocery.dart';

class FavoritesPage extends StatefulWidget {

  final Set<Grocery> saved;

  const FavoritesPage({Key? key, required this.saved}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  /// The users first name, used to identify their favorites.
  late String firstName;
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  /// Retrieve snapshot of the SQLite database on open.
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

  @override
  Widget build(BuildContext context) {
    // Calculate the total price for all items in favorites.
    var prices = widget.saved.map((e) => e.price);
    // Check if favorites empty, to avoid trying to reduce an empty list.
    var subtotal = prices.isNotEmpty? prices.reduce((sum, element) => sum + element) : 0.0;
    // Round the price to 2 decimal places, as convention with money totals.
    var total = subtotal.toStringAsFixed(2);

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
          subtitle: Text(
              '\$${grocery.price.toString()}'
          ),
          trailing: GestureDetector(
            child: Icon(Icons.delete),
            onTap: () => _removeFromFavorites(grocery),
          ),
        );
      },
    );

    final divided = tiles.isNotEmpty?
    ListTile.divideTiles(
        context: context,
        tiles: tiles
    ).toList()
        :
    <Widget>[];

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
      body: ListView(children: divided),
      bottomSheet: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(Icons.shopping_cart),
        ),
        title: Text('Total: \$$total'),
        tileColor: Colors.black,
        textColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        child: const Icon(Icons.share),
        backgroundColor: Colors.red,
      ),
    );
  }

}
