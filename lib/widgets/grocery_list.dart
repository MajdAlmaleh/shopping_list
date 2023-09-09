import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = 'https://lxxwjjmkbdsgsvseqnpf.supabase.co/rest/v1';
final headers = {
  'apikey':
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4eHdqam1rYmRzZ3N2c2VxbnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQxNjE2OTYsImV4cCI6MjAwOTczNzY5Nn0.0OTwuXScRbk4U3-_EWTFYp9ignf_MAIeXuvqoB2ocFQ',
  'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4eHdqam1rYmRzZ3N2c2VxbnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQxNjE2OTYsImV4cCI6MjAwOTczNzY5Nn0.0OTwuXScRbk4U3-_EWTFYp9ignf_MAIeXuvqoB2ocFQ',
  'Prefer': 'return=representation',
};

class GroceryList extends StatefulWidget {
  const GroceryList({
    super.key,
  });

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  String? _error;
  bool _isLoading = true;
  List<GroceryItem> _groceryItems = [];
  final List<GroceryItem> _loadedGroceryItems = [];

  void _loadItem() async {
    try {
      final respondData = await supabase.from('theData').select('''
           id,
           name,
           category,
           quantity''');

      //print(data);

      /*  final respondData = await http.get(
      Uri.parse('$baseUrl/addedData?select=data'),
      headers: headers,
    ); */
      // print(respondData.statuscode);
      /*  if (respondData.statusCode >= 300) {
     
    } */

      // dynamic listData = jsonDecode(respondData);
      print(respondData);

      for (var item in respondData) {
        final category = categories.entries
            .firstWhere((element) => item['category'] == element.value.title)
            .value;

        _loadedGroceryItems.add(GroceryItem(
            id: item['id'],
            name: item['name'],
            category: category,
            quantity: item['quantity']));
      }
      setState(() {
        _groceryItems = _loadedGroceryItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    //  final url = Uri.http(baseUrl, '/addedData?select=id');
  }

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Widget check() {
    if (_error == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: Text(_error!),
      );
    }
  }

  void _removeItem(GroceryItem item) async {
    setState(() {
      _groceryItems.remove(item);
    });
    await supabase.from('theData').delete().eq('id', item.id);

    /* final error =
        await supabase.from('addedData').delete().eq('data', json.encode({'id': item.id}));
    print(error);
 */ /* 
    final x = await http.delete(
        Uri.parse('$baseUrl/addedData?data=eq.${json.encode({'id': item.id})}'),
        headers: headers);
    print(x.body);
    print(x.statusCode); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? check()
          : _groceryItems.isEmpty
              ? const Center(
                  child: Text('You got no items yet'),
                )
              : ListView.builder(
                  itemCount: _groceryItems.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      onDismissed: (direction) {
                        _removeItem(_groceryItems[index]);
                      },
                      key: ValueKey(_groceryItems[index].id),
                      child: ListTile(
                        leading: Container(
                          color: _groceryItems[index].category.color,
                          height: 20,
                          width: 20,
                        ),
                        title: Text(_groceryItems[index].name),
                        trailing:
                            Text(_groceryItems[index].quantity.toString()),
                      ),
                    );
                  },
                ),
    );
  }
}
