// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_developer_assessment/database/databaseHelper.dart';
import 'package:http/http.dart' as http;

import 'models/data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> _products = [];
  int _currentPage = 1;
  ScrollController scrollController = ScrollController();
  int totProud = 1000;
  List<Map<String, dynamic>> data = [];
  IconData icon = Icons.favorite_border;
  String iconName = "Icons.favorite_border";
  late String stringFormat;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    getData();
    scrollController.addListener(loadMoreData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          var id = product.id.toString();
          if (data.isEmpty) {
            icon = Icons.favorite_border;
            iconName = "Icons.favorite_border";
          } else if (stringFormat.contains(id)) {
            icon = Icons.favorite;
            iconName = "Icons.favorite";
          } else {
            icon = Icons.favorite_border;
            iconName = "Icons.favorite_border";
          }
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Price: \$${product.price}'),
            trailing: IconButton(
              onPressed: () {
                if (!stringFormat.contains(id)) {
                  SQLHelper.addToFav(product.id);
                  // getData();
                } else if (stringFormat.contains(id)) {
                  SQLHelper.deleteFromFavorite(product.id);
                  // getData();
                }
                getData().then((_) {
                  setState(() {});
                });
              },
              icon: Icon(icon),
            ),
          );
        },
      ),
    );
  }

  Future<void> getData() async {
    final dbData = await SQLHelper.getItems();
    data = dbData;
    stringFormat = data.map((map) => map.toString()).join('\n');
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://app.apnabillbook.com/api/product?storeId=4ad3de84-bcaa-4bb2-9eb9-1846844e3314&page=$_currentPage&pageSize=15'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<Product> products = (jsonData['data']['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
      setState(() {
        totProud = jsonData['data']["totalItems"];
        _products.addAll(products);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void loadMoreData() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        _products.length < totProud) {
      setState(() {
        _currentPage++;
      });
      _fetchProducts();
    }
  }
}
