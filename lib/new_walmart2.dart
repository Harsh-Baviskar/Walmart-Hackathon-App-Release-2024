import 'package:flutter/material.dart';

void main() {
  runApp(const SmartBudgetAnalyzerApp());
}

class SmartBudgetAnalyzerApp extends StatelessWidget {
  const SmartBudgetAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SmartBudgetAnalyzer(),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String password;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}

class Product {
  final int id;
  String name;
  int price;
  final String barcode;
  final String category;
  final List<Alternative> alternatives;
  int quantity;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.category,
    required this.alternatives,
    this.quantity = 1,
  });
}

class Alternative {
  final String name;
  final int price;
  final int savings;
  Alternative({required this.name, required this.price, required this.savings});
}

class Recommendation {
  final int id;
  final String message;
  final String product;
  final Alternative alternative;
  Recommendation({
    required this.id,
    required this.message,
    required this.product,
    required this.alternative,
  });
}

class SmartBudgetAnalyzer extends StatefulWidget {
  @override
  _SmartBudgetAnalyzerState createState() => _SmartBudgetAnalyzerState();
}

class _SmartBudgetAnalyzerState extends State<SmartBudgetAnalyzer> {
  User? user;
  double budget = 0;
  List<Product> cart = [];
  bool showLogin = false;
  bool showSignup = false;
  bool showBudgetInput = false;
  bool showScanner = false;
  String loginEmail = '';
  String loginPassword = '';
  String signupName = '';
  String signupEmail = '';
  String signupPassword = '';
  String budgetInput = '';
  List<Recommendation> recommendations = [];
  String? notification;
  bool notificationError = false;

  final List<Product> productDatabase = [
    Product(
      id: 1,
      name: 'Milk 1L',
      price: 65,
      barcode: '123456789',
      category: 'Dairy',
      alternatives: [
        Alternative(name: 'Store Brand Milk', price: 55, savings: 10),
      ],
    ),
    Product(
      id: 2,
      name: 'Bread Loaf',
      price: 40,
      barcode: '987654321',
      category: 'Bakery',
      alternatives: [
        Alternative(name: 'Whole Wheat Bread', price: 35, savings: 5),
      ],
    ),
    Product(
      id: 3,
      name: 'Rice 5kg',
      price: 450,
      barcode: '456789123',
      category: 'Grains',
      alternatives: [
        Alternative(name: 'Basmati Rice', price: 400, savings: 50),
      ],
    ),
    Product(
      id: 4,
      name: 'Cooking Oil 1L',
      price: 180,
      barcode: '789123456',
      category: 'Oil',
      alternatives: [
        Alternative(name: 'Sunflower Oil', price: 160, savings: 20),
      ],
    ),
    Product(
      id: 5,
      name: 'Apple 1kg',
      price: 120,
      barcode: '321654987',
      category: 'Fruits',
      alternatives: [
        Alternative(name: 'Seasonal Apples', price: 100, savings: 20),
      ],
    ),
    Product(
      id: 6,
      name: 'Chicken 1kg',
      price: 280,
      barcode: '654987321',
      category: 'Meat',
      alternatives: [
        Alternative(name: 'Fresh Chicken', price: 250, savings: 30),
      ],
    ),
  ];

  final List<User> usersDatabase = [
    User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
    ),
    User(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      password: 'password456',
    ),
  ];

  void showNotification(String message, {bool error = false}) {
    setState(() {
      notification = message;
      notificationError = error;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        notification = null;
      });
    });
  }

  void handleLogin() {
    final foundUser = usersDatabase.firstWhere(
      (u) => u.email == loginEmail && u.password == loginPassword,
      orElse: () => User(id: -1, name: '', email: '', password: ''),
    );
    if (foundUser.id != -1) {
      setState(() {
        user = foundUser;
        showLogin = false;
        showBudgetInput = true;
      });
      showNotification('Login successful!');
    } else {
      showNotification(
        'Invalid credentials. Try: john@example.com / password123',
        error: true,
      );
    }
  }

  void handleSignup() {
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: signupName,
      email: signupEmail,
      password: signupPassword,
    );
    setState(() {
      user = newUser;
      showSignup = false;
      showBudgetInput = true;
    });
    showNotification('Account created successfully!');
  }

  void handleBudgetSubmit() {
    setState(() {
      budget = double.tryParse(budgetInput) ?? 0;
      showBudgetInput = false;
    });
    showNotification('Budget set to ₹$budgetInput');
  }

  void simulateBarcodeScan() {
    final randomProduct = (productDatabase..shuffle()).first;
    final existingItem = cart.firstWhere(
      (item) => item.id == randomProduct.id,
      orElse: () => Product(
        id: -1,
        name: '',
        price: 0,
        barcode: '',
        category: '',
        alternatives: [],
      ),
    );
    setState(() {
      if (existingItem.id != -1) {
        cart = cart.map((item) {
          if (item.id == randomProduct.id) {
            item.quantity += 1;
          }
          return item;
        }).toList();
      } else {
        cart.add(
          Product(
            id: randomProduct.id,
            name: randomProduct.name,
            price: randomProduct.price,
            barcode: randomProduct.barcode,
            category: randomProduct.category,
            alternatives: randomProduct.alternatives,
            quantity: 1,
          ),
        );
      }
      if (randomProduct.alternatives.isNotEmpty) {
        final alt = randomProduct.alternatives[0];
        recommendations.add(
          Recommendation(
            id: DateTime.now().millisecondsSinceEpoch,
            message: 'Save ₹${alt.savings} by switching to ${alt.name}',
            product: randomProduct.name,
            alternative: alt,
          ),
        );
      }
      showScanner = false;
    });
    showNotification('Added ${randomProduct.name} to cart');
  }

  void updateQuantity(int id, int change) {
    setState(() {
      cart = cart
          .map((item) {
            if (item.id == id) {
              item.quantity = (item.quantity + change).clamp(0, 999);
            }
            return item;
          })
          .where((item) => item.quantity > 0)
          .toList();
    });
  }

  void removeFromCart(int id) {
    setState(() {
      cart.removeWhere((item) => item.id == id);
    });
  }

  double getTotalCost() {
    return cart.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  double getRemainingBudget() {
    return budget - getTotalCost();
  }

  void applyRecommendation(Recommendation recommendation) {
    setState(() {
      cart = cart.map((item) {
        if (item.name == recommendation.product) {
          item.name = recommendation.alternative.name;
          item.price = recommendation.alternative.price;
        }
        return item;
      }).toList();
      recommendations.removeWhere((r) => r.id == recommendation.id);
    });
    showNotification(
      'Switched to ${recommendation.alternative.name} - Saved ₹${recommendation.alternative.savings}!',
    );
  }

  void logout() {
    setState(() {
      user = null;
      budget = 0;
      cart.clear();
      recommendations.clear();
      budgetInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (notification != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification!),
            backgroundColor: notificationError ? Colors.red : Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.blue[50],
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              width: 400,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Smart Budget Analyzer',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Track your spending, save money',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),
                  if (!showLogin && !showSignup) ...[
                    ElevatedButton(
                      onPressed: () => setState(() => showLogin = true),
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => showSignup = true),
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                  if (showLogin) ...[
                    TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (v) => loginEmail = v,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (v) => loginPassword = v,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: handleLogin,
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => showLogin = false),
                      child: Text('Back'),
                    ),
                  ],
                  if (showSignup) ...[
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (v) => signupName = v,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (v) => signupEmail = v,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (v) => signupPassword = v,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: handleSignup,
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => showSignup = false),
                      child: Text('Back'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (showBudgetInput) {
      return Scaffold(
        backgroundColor: Colors.blue[50],
        body: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_money, color: Colors.blue, size: 48),
                SizedBox(height: 16),
                Text(
                  'Set Your Budget',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'How much do you plan to spend today?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Budget Amount (₹)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => budgetInput = v,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: handleBudgetSubmit,
                  child: Text('Set Budget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (showScanner) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: Colors.blue, size: 48),
                SizedBox(height: 16),
                Text(
                  'Scan Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Point your camera at the barcode',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.blue,
                    size: 48,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Scanning for barcode...',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: simulateBarcodeScan,
                  child: Text('Simulate Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showScanner = false),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Smart Budget Analyzer'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Budget Overview
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _budgetInfo(
                    'Budget',
                    '₹${budget.toStringAsFixed(0)}',
                    Colors.blue,
                  ),
                  _budgetInfo(
                    'Spent',
                    '₹${getTotalCost().toStringAsFixed(0)}',
                    Colors.orange,
                  ),
                  _budgetInfo(
                    'Remaining',
                    '₹${getRemainingBudget().toStringAsFixed(0)}',
                    getRemainingBudget() < 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            if (getRemainingBudget() < 0)
              Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  "⚠️ You've exceeded your budget by ₹${getRemainingBudget().abs().toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Recommendations
            if (recommendations.isNotEmpty)
              Container(
                color: Colors.yellow[50],
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_down, color: Colors.yellow[700]),
                        SizedBox(width: 8),
                        Text(
                          'Smart Recommendations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ...recommendations.map(
                      (rec) => Card(
                        child: ListTile(
                          title: Text(rec.message),
                          trailing: ElevatedButton(
                            onPressed: () => applyRecommendation(rec),
                            child: Text('Apply'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Action Buttons
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => showScanner = true),
                      icon: Icon(Icons.qr_code_scanner),
                      label: Text('Scan Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => showBudgetInput = true),
                      icon: Icon(Icons.attach_money),
                      label: Text('Update Budget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Shopping Cart
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(width: 8),
                      Text(
                        'Shopping Cart (${cart.length} items)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (cart.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          Text('Your cart is empty'),
                          Text(
                            'Scan products to add them to your cart',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        ...cart.map(
                          (item) => Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            item.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '₹${item.price}',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () =>
                                                updateQuantity(item.id, -1),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () =>
                                                updateQuantity(item.id, 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal: ₹${item.price * item.quantity}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            removeFromCart(item.id),
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.blue,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Bill',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${getTotalCost().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
