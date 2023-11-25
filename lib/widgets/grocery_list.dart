import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/dummy_items.dart';
import 'package:flutter_shopping_list/models/grocery_item.dart';
import 'package:flutter_shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryList = [];

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

  @override
  Widget build(BuildContext context) {
    Widget displayList() {
      if (_groceryList.isEmpty) {
        return const Center(
          child: Text(
            'Add new items',
            style: TextStyle(fontSize: 20),
          ),
        );
      }
      return ListView.builder(
          itemCount: _groceryList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey<String>(_groceryList[index].id),
              onDismissed: (direction) {
                setState(() {
                  _groceryList.removeAt(index);
                });
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

    return Scaffold(
      appBar: AppBar(title: const Text('Groceries'), actions: [
        IconButton(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
        ),
      ]),
      body: displayList(),
    );
  }
}
