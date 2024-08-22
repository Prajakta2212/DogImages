import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(DogImageApp());
}

class DogImageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Image App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DogImageHomePage(),
    );
  }
}

class DogImageHomePage extends StatefulWidget {
  @override
  _DogImageHomePageState createState() => _DogImageHomePageState();
}

class _DogImageHomePageState extends State<DogImageHomePage> {
  int _selectedIndex = 0;
  String imageUrl = 'https://via.placeholder.com/300';
  List<String> history = [];
  List<CartItem> cart = [];

  Future<void> fetchDogImage() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        imageUrl = data['message'];
        history.add(imageUrl);
      });
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  void addToCart(CartItem item) {
    setState(() {
      cart.add(item);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      ImagePage(fetchDogImage: fetchDogImage, imageUrl: imageUrl),
      HistoryPage(history: history, cart: cart, onAddToCart: addToCart),
      CartPage(cart: cart),
    ];

    return Scaffold(
      appBar: AppBar(
       leading: Icon(Icons.image_rounded),
        title: Text('Dog Images'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ImagePage extends StatelessWidget {
  final Future<void> Function() fetchDogImage;
  final String imageUrl;

  ImagePage({required this.fetchDogImage, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  // width: 380, 
                  // height: 300, 
                  fit: BoxFit.cover, 
                )
              : CircularProgressIndicator(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchDogImage,
            child: Text('Fetch New Image'),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  final List<String> history;
  final List<CartItem> cart;
  final Function(CartItem) onAddToCart;

  HistoryPage({required this.history, required this.cart, required this.onAddToCart});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.history.isEmpty
          ? Center(child: Text('No images fetched yet!'))
          : ListView.builder(
              itemCount: widget.history.length,
              itemBuilder: (context, index) {
                TextEditingController amountController =
                    TextEditingController();
                final imageUrl = widget.history[index];
                final isAdded =
                    widget.cart.any((item) => item.imageUrl == imageUrl);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.network(imageUrl),
                        SizedBox(height: 10),
                        if (isAdded)
                          Text('Item added to the cart')
                        else
                          Column(
                            children: [
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  final amount =
                                      int.tryParse(amountController.text) ?? 1;
                                  final item = CartItem(
                                      imageUrl: imageUrl, amount: amount);
                                  widget.onAddToCart(item);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Added to cart')),
                                  );
                                },
                                child: Text('Add to Cart'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
class CartPage extends StatelessWidget {
  final List<CartItem> cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    int totalAmount = cart.fold(0, (sum, item) => sum + item.amount);
    return Scaffold(
      body: cart.isEmpty
          ? Center(child: Text('No items in the cart yet!'))
          : Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: Image.network(cart[index].imageUrl),
                            title: Text('Amount: ${cart[index].amount}'),
                          ),
                          SizedBox(height: 20), // Add spacing between items
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Total Amount: $totalAmount',
                      style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
    );
  }
}

class CartItem {
  final String imageUrl;
  final int amount;

  CartItem({required this.imageUrl, required this.amount});
}
