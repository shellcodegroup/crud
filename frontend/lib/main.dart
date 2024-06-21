import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/item.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String serverUrl = 'http://localhost:3000';
  final TextEditingController nameController = TextEditingController();

  Future<List<dynamic>> fetchItems() async {
    final response = await http.get(Uri.parse('$serverUrl/api/v1/items'));

    if (response.statusCode == 200) {
      final itemList = jsonDecode(response.body);
      final items = itemList.map((item) {
        return Item.fromjson(item);
      }).toList();
      return items;
    } else {
      throw Exception("failed to fetch items");
    }
  }

  Future<Item> addItem(String name) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/v1/items'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      final dynamic json = jsonDecode(response.body);
      final Item item = Item.fromjson(json);
      return item;
    } else {
      throw Exception("failed to add item");
    }
  }

  Future<void> updateItem(int id, String name) async {
    final response = await http.put(Uri.parse('$serverUrl/api/v1/items/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}));

    if (response.statusCode != 200) {
      throw Exception("failed to update item");
    }
  }

  Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$serverUrl/api/v1/items/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception("failed to delete item");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          FutureBuilder(
              future: fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return ListTile(
                          title: Text(item.name),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      deleteItem(item.id);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete)),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Update Item"),
                                              content: TextFormField(
                                                controller: nameController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Item Name'),
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      updateItem(item.id,
                                                          nameController.text);
                                                      setState(() {
                                                        nameController.clear();
                                                      });
                                                    },
                                                    child: const Text(
                                                        'Update Item')),
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(Icons.edit)),
                              ],
                            ),
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Add Item"),
                  content: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          addItem(nameController.text);
                          setState(() {
                            nameController.clear();
                          });
                        },
                        child: const Text('Add Item')),
                  ],
                );
              });
        },
        tooltip: "add item",
        child: const Icon(Icons.add),
      ),
    );
  }
}
