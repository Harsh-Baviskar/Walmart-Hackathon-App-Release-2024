import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'camera_screen.dart';
import 'new_walmart2.dart';
//import 'package:image_picker/image_picker.dart';

// Mock product data
class Product {
  final int id;
  final String name;
  final double price;
  final String brand;
  final String category;
  Product(this.id, this.name, this.price, this.brand, this.category);
}

final List<Product> products = [
  Product(1, "Amul Milk 1L", 60, "Amul", "dairy"),
  Product(2, "Mother Dairy Milk 1L", 65, "Mother Dairy", "dairy"),
  Product(3, "Amul Butter 250g", 120, "Amul", "dairy"),
  Product(4, "Mother Dairy Butter 250g", 130, "Mother Dairy", "dairy"),
  Product(5, "Amul Cheese 100g", 150, "Amul", "dairy"),
  Product(6, "Mother Dairy Cheese 100g", 160, "Mother Dairy", "dairy"),
  Product(7, "Amul Ghee 250g", 180, "Amul", "dairy"),
  Product(8, "Mother Dairy Ghee 250g", 190, "Mother Dairy", "dairy"),
  Product(9, "Amul Curd 250g", 200, "Amul", "dairy"),
  Product(3, "Nestle Milk 1L", 70, "Nestle", "dairy"),
  Product(4, "Britannia Bread", 25, "Britannia", "bakery"),
  // ... add more as needed
];

// App State
class AppState extends ChangeNotifier {
  GoogleSignInAccount? user;
  double budget = 0;
  double spent = 0;
  Map<int, int> cart = {}; // productId -> quantity

  void setUser(GoogleSignInAccount? u) {
    user = u;
    notifyListeners();
  }

  void setBudget(double b) {
    budget = b;
    notifyListeners();
  }

  void addToCart(Product p) {
    cart[p.id] = (cart[p.id] ?? 0) + 1;
    spent += p.price;
    notifyListeners();
  }

  void removeFromCart(Product p) {
    if (cart[p.id] != null && cart[p.id]! > 0) {
      cart[p.id] = cart[p.id]! - 1;
      spent -= p.price;
      if (cart[p.id] == 0) cart.remove(p.id);
      notifyListeners();
    }
  }

  void logout() {
    // user = null;
    budget = 0;
    spent = 0;
    cart.clear();
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.user == null) return const LoginScreen();
          if (state.budget == 0) return const BudgetScreen();
          return const HomeScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            final user = await _googleSignIn.signIn();
            if (user != null) {
              Provider.of<AppState>(context, listen: false).setUser(user);
            }
          },
        ),
      ),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budget')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Enter your monthly budget:'),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget (₹)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Set Budget'),
              onPressed: () {
                final budget = double.tryParse(_controller.text) ?? 0;
                if (budget > 0) {
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).setBudget(budget);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // For demo: split products into frequent and recent (customize logic as needed)
    final frequentBuys = products.where((p) => p.brand == "Amul").toList();
    final recentBuys = products.where((p) => p.brand != "Amul").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walmart : Smart Budget Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              GoogleSignIn().signOut();
              state.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text('Budget: ₹${state.budget.toStringAsFixed(2)}'),
              subtitle: Text(
                'Remaining: ₹${(state.budget - state.spent).toStringAsFixed(2)}',
              ),
              trailing: Text('Spent: ₹${state.spent.toStringAsFixed(2)}'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "YOUR FREQUENT BUYS :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: frequentBuys.map((p) {
                final qty = state.cart[p.id] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: 200,
                    child: ListTile(
                      title: Text(p.name, style: TextStyle(fontSize: 12)),
                      subtitle: Text('₹${p.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: qty > 0
                                ? () => state.removeFromCart(p)
                                : null,
                          ),
                          Text('$qty'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => state.addToCart(p),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "YOUR RECENT BUYS :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView(
              children: recentBuys.map((p) {
                final qty = state.cart[p.id] ?? 0;
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('₹${p.price} • ${p.brand}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: qty > 0
                            ? () => state.removeFromCart(p)
                            : null,
                      ),
                      Text('$qty'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => state.addToCart(p),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
        },
      ),
    );
  }
}

//class CameraScreen extends StatelessWidget {
  //const CameraScreen({super.key});

  //@override
  //Widget build(BuildContext context) {
//    return Scaffold(
  //    appBar: AppBar(title: const Text('HOME')),
    //  body: Center(
      //  child: ElevatedButton(
        //  onPressed: () {
          //  Navigator.push(
            //  context,
              //MaterialPageRoute(builder: (context) => const CameraScreen()),
//            );
  //        },
    //      child: const Text('Open Camera'),
      //  ),
//      ),
  //  );
//  }
//}
