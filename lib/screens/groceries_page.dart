/// Grocery Parge - grocery_page.dart
/// =================================
/// The screen which displays the list of groceries.
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock/db/sqlite_database.dart';

import '../model/grocery.dart';

/// This page shows the list of groceries.
class GroceriesPage extends StatefulWidget {

  const GroceriesPage({super.key});

  @override
  State<GroceriesPage> createState() => _GroceriesPageState();
}

/// This class stores the state for the stateful groceries widget above.
class _GroceriesPageState extends State<GroceriesPage> {
  /// Counter keeps track of auto-increment ID.
  static int counter = 1;

  final _groceries = <Grocery>[];
  final _saved = <Grocery>{};
  /// Stores if the app is currently loadings the database.
  bool isLoading = false;
  /// The users first name, used to identify their favorites.
  late String firstName;

  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  /// Retrieve snapshot of the SQLite database on open.
  void initState() {
    super.initState();
    refreshGroceries();
  }

  @override
  /// Close the instance of the SQLite database on exit.
  void dispose() {
    GroceriesDatabase.instance.close();
    super.dispose();
  }

  /// Changes the first name of the user to a random WordPari
  Future<void> _setRandomName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'default';
      prefs.setString('first_name', WordPair.random().toString());
    });
  }

  /// Refreshes the snapshot of the groceries database.
  Future<void> refreshGroceries() async {
    // Gets the users name from the preferences.
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
    });

    // Clear the existing groceries.
    _groceries.clear();

    // Retrieve the groceries from the database.
    setState(() => isLoading = true);
    _groceries.addAll(await GroceriesDatabase.instance.groceries());
    setState(() => isLoading = false);

    // Used to keep track of the autoincrement ID.
    counter = _groceries.length;
  }

  /// This function removes a grocery from the database and refreshes the snapshot.
  void _deleteGrocery(Grocery grocery) async {
    // Remove a grocery from the database.
    await GroceriesDatabase.instance.deleteGrocery(grocery.id);
    // Update the groceries from database.
    refreshGroceries();
    counter = counter - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Groceries'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: _setRandomName,
                tooltip: 'Set random first name',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addGrocery,
                tooltip: 'Add Grocery',
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: _seeFavorites,
                tooltip: 'Saved Suggestions',
              ),
            ]
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _groceries.length * 2,
            prototypeItem: const ListTile(
                title: Text('Hello, World!')
            ),
            itemBuilder: (context, i) {
              // Draw a diver between items
              if (i.isOdd) return const Divider();
              // Divider above, offsets i by factor of 2.
              final index = i ~/ 2;
              final alreadySaved = _saved.contains(_groceries[index]);

              return
                GestureDetector (
                  child: ListTile(
                    title: Text(
                      _groceries[index].toString(),
                      style: _biggerFont,
                    ),
                    trailing: Icon(
                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                      color: alreadySaved ? Colors.red : null,
                      semanticLabel: alreadySaved ? "Remove from saved" : "Save",
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (alreadySaved) {
                        _saved.remove(_groceries[index]);
                      } else {
                        _saved.add(_groceries[index]);
                      }
                    });
                  },
                  onLongPress: () => _editGrocery(_groceries[index]),
                  onDoubleTap: () => _deleteGrocery(_groceries[index]),
                );
            }
        )
    );
  }

  /// When favorites icon in navbar is pressed, they see a list of favourites.
  void _seeFavorites() {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) {
              final tiles = _saved.map(
                    (grocery) {
                  return ListTile(
                      title: Text(
                        grocery.toString(),
                        style: _biggerFont,
                      )
                  );
                },
              );
              final divided = tiles.isNotEmpty?
              ListTile.divideTiles(
                  context: context,
                  tiles: tiles
              ).toList()
                  : <Widget>[];

              return Scaffold(
                appBar: AppBar(
                    title: Text('$firstName\'s favorites')
                ),
                body: ListView(children: divided),
              );
            })
    );
  }

  /// When long tap on grocery, user can edit that item.
  void _addGrocery() {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController(text: counter.toString());
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                  appBar: AppBar(
                    title: const Text('New Grocery'),
                  ),
                  body: Form(
                    key: formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: $counter'),
                          TextFormField(
                            // Text in grey shown before user input.
                            decoration: const InputDecoration(
                              hintText: "Name",
                            ),
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            // Text in grey shown before user input.
                            decoration: const InputDecoration(
                              hintText: "\$0.00",
                              prefixText: '\$',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                            controller: priceController,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (formKey.currentState!.validate()) {
                                    // Construct the edited grocery.
                                    var newGrocery = Grocery(
                                        id: counter + 1,
                                        name: nameController.text,
                                        price: double.parse(priceController.text)
                                    );
                                    // Update the database with the edited grocery.
                                    await GroceriesDatabase.instance.insertGrocery(newGrocery);

                                    // Refresh the database snapshot.
                                    refreshGroceries();

                                    // Return to the previous page, the grocery list.
                                    Navigator.of(context).pop();

                                    // Increment the app counter.
                                    counter = counter + 1;
                                  }
                                },
                                child: const Text('Submit'),
                              )
                          )
                        ]
                    ),
                  )
              );
            }
        )
    );
  }

  /// When long tap on grocery, user can edit that item.
  void _editGrocery(Grocery grocery) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: grocery.name);
    final priceController = TextEditingController(text: grocery.price.toString());
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                  appBar: AppBar(
                      title: Text('Edit ${grocery.name}')
                  ),
                  body: Form(
                    key: formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            // The validator receives the text that the user has entered.
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              prefixText: '\$',
                            ),
                            // initialValue: grocery.price.toString(),
                            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                            controller: priceController,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Validate retunrs true if the form is valid, or false otherwise.
                                  if (formKey.currentState!.validate()) {
                                    // Construct the edited grocery.
                                    var editedGrocery = Grocery(
                                        id: grocery.id,
                                        name: nameController.text,
                                        price: double.parse(priceController.text)
                                    );
                                    // Update the database with the edited grocery.
                                    await GroceriesDatabase.instance.updateGrocery(editedGrocery);

                                    // Refresh the database snapshot.
                                    refreshGroceries();

                                    // Return to the previous page, the grocery list.
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Submit'),
                              )
                          )
                        ]
                    ),
                  )
              );
            }
        )
    );
  }
}
