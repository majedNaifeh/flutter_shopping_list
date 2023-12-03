import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/models/grocery_item.dart';
import 'package:flutter_shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-shopping-list-testing-default-rtdb.firebaseio.com',
        'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data, please try again later.";
        });
      }
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.name == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryList = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong, please try again later';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) {
        return const NewItem();
      }),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryList.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryList.indexOf(item);
    setState(() {
      _groceryList.remove(item);
    });
    final url = Uri.https(
        'flutter-shopping-list-testing-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting item'),
        ),
      );
      setState(() {
        _groceryList.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'Add new items',
        style: TextStyle(fontSize: 20),
      ),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryList.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey<String>(_groceryList[index].id),
              onDismissed: (direction) {
                _removeItem(_groceryList[index]);
              },
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete),
              ),
              child: ListTile(
                title: Text(_groceryList[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryList[index].category.color,
                ),
                trailing: Text(_groceryList[index].quantity.toString()),
              ),
            );
          });
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Groceries'), actions: [
        IconButton(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
        ),
      ]),
      body: content,
    );
  }
}

//using future builder
//i will not use future builder cz to make it works , it must load items every time the build happened. both are working
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_shopping_list/data/categories.dart';
// import 'package:flutter_shopping_list/models/grocery_item.dart';
// import 'package:flutter_shopping_list/widgets/new_item.dart';
// import 'package:http/http.dart' as http;

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryList = [];
//   late Future<List<GroceryItem>> _loadedItems;

//   @override
//   void initState() {
//     super.initState();
//     _loadedItems = _loadItems();
//   }

//   Future<List<GroceryItem>> _loadItems() async {
//     final url = Uri.https(
//         'flutter-shopping-list-testing-default-rtdb.firebaseio.com',
//         'shopping-list.json');

//     final response = await http.get(url);

//     if (response.body == 'null') {
//       return [];
//     }
//     final Map<String, dynamic> listData = json.decode(response.body);
//     final List<GroceryItem> loadedItem = [];

//     if (response.statusCode >= 400) {
//       throw Exception('Failed to fetch data, please try again later.');
//     }
//     for (final item in listData.entries) {
//       final category = categories.entries
//           .firstWhere((catItem) => catItem.value.name == item.value['category'])
//           .value;
//       loadedItem.add(
//         GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category,
//         ),
//       );
//     }
//     return loadedItem;
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(builder: (ctx) {
//         return const NewItem();
//       }),
//     );
//     if (newItem == null) {
//       return;
//     }
//     setState(() {
//       _groceryList.add(newItem);
//     });
//   }

//   void _removeItem(GroceryItem item) async {
//     final index = _groceryList.indexOf(item);
//     setState(() {
//       _groceryList.remove(item);
//     });
//     final url = Uri.https(
//         'flutter-shopping-list-testing-default-rtdb.firebaseio.com',
//         'shopping-list/${item.id}.json');
//     final response = await http.delete(url);
//     if (response.statusCode >= 400) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error deleting item'),
//         ),
//       );
//       setState(() {
//         _groceryList.insert(index, item);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Groceries'), actions: [
//         IconButton(
//           onPressed: _addItem,
//           icon: const Icon(Icons.add),
//         ),
//       ]),
//       body: FutureBuilder(
//           future: _loadItems(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(snapshot.error.toString()),
//               );
//             }
//             if (snapshot.data!.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'Add new items',
//                   style: TextStyle(fontSize: 20),
//                 ),
//               );
//             }
//             return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   return Dismissible(
//                     key: ValueKey<String>(snapshot.data![index].id),
//                     onDismissed: (direction) {
//                       _removeItem(snapshot.data![index]);
//                     },
//                     background: Container(
//                       color: Colors.red,
//                       child: const Icon(Icons.delete),
//                     ),
//                     child: ListTile(
//                       title: Text(snapshot.data![index].name),
//                       leading: Container(
//                         width: 24,
//                         height: 24,
//                         color: snapshot.data![index].category.color,
//                       ),
//                       trailing: Text(snapshot.data![index].quantity.toString()),
//                     ),
//                   );
//                 });
//           }),
//     );
//   }
// }
