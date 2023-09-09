//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
//import 'package:shopping_list/models/grocery_item.dart';
//import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final supabase = Supabase.instance.client;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool isSending = false;

  final _formKey = GlobalKey<FormState>();

  void _saveItem() async {
    setState(() {
      isSending = true;
    });

    String id = uuid.v4();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

         await supabase.from('theData').insert([
       
          {
            'id':id,
            'name': _enterdName,
            'category': _selectedCategory.title,
            'quantity': _enterdQuantity,
          },
        
      ]);      

      /*    final data1 = await supabase.from('added').select('''
           name,
           category,
           quantity'''
            
          );
      print(data1); */
/* 
      const baseUrl = 'https://lxxwjjmkbdsgsvseqnpf.supabase.co/rest/v1';
      final headers = {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4eHdqam1rYmRzZ3N2c2VxbnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQxNjE2OTYsImV4cCI6MjAwOTczNzY5Nn0.0OTwuXScRbk4U3-_EWTFYp9ignf_MAIeXuvqoB2ocFQ',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4eHdqam1rYmRzZ3N2c2VxbnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQxNjE2OTYsImV4cCI6MjAwOTczNzY5Nn0.0OTwuXScRbk4U3-_EWTFYp9ignf_MAIeXuvqoB2ocFQ',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Prefer': 'return=representation',
      }; */

      //  final url = Uri.http(baseUrl, '/addedData?select=id');
      /*  await http.post(
        Uri.parse('$baseUrl/addedData'),
        headers: headers,
        body: json.encode(
          {
            'data': {
              'id': id,
              'name': _enterdName,
              'category': _selectedCategory.title,
              'quantity': _enterdQuantity,
            }
          },
        ),
      ); */
      /* final x = await http
          .post(Uri.parse('$baseUrl/theData'), headers: headers, body: {
        'id': id,
        'name': _enterdName,
        'category': _selectedCategory.title,
        int: _enterdQuantity
      });
      print(x.body);
      print(x.statusCode); */

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: id,
          name: _enterdName,
          category: _selectedCategory,
          quantity: _enterdQuantity));
    }
  }

  void _resetItems() {
    _formKey.currentState!.reset();
  }

  var _enterdName = '';
  var _enterdQuantity = 1;
  var _selectedCategory = categories[Categories.dairy]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _enterdName = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters. ';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _enterdQuantity = int.parse(newValue!);
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number. ';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      initialValue: _enterdQuantity.toString(),
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSending ? null : _resetItems,
                    child: const Text(
                      'Reset',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : _saveItem,
                    child: isSending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator())
                        : const Text(
                            'Add item',
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
