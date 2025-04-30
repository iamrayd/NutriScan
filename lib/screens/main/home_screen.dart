import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutriscan/utils/utils.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/barcode_service.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();
    final AuthService _authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: _firestoreService.getUserProfile(_authService.getCurrentUser()!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            UserModel user = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 16),
                Image.asset("assets/home_screen_asset.png", height: ScreenUtils.imageHeightHalf(context)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BarcodeScannerScreen(user: user)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: StadiumBorder(),
                  ),
                  child: const Text("Start Scan", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18),
                      SizedBox(width: 6),
                      Text("Recent Scans", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<ProductModel>>(
                    future: _firestoreService.getProducts(_authService.getCurrentUser()!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final products = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final item = products[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text("Barcode #: ${item.barcode}"),
                              subtitle: Text("Product: ${item.productName} | Date: ${item.date} | Price: ${item.price}"),
                              trailing: Text(
                                item.isSafe ? "Safe" : "Not Safe",
                                style: TextStyle(
                                  color: item.isSafe ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  final UserModel user;

  const BarcodeScannerScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final BarcodeService _barcodeService = BarcodeService();
    final FirestoreService _firestoreService = FirestoreService();
    final AuthService _authService = AuthService();

    return Scaffold(
      body: MobileScanner(
        controller: MobileScannerController(
          facing: CameraFacing.back,
        ),
        onDetect: (capture) async {
          try {
            final barcode = capture.barcodes.first;
            final value = barcode.rawValue ?? "---";

            // Fetch product details
            ProductModel product = await _barcodeService.fetchProductDetails(value);
            // Check if product is safe
            product = ProductModel(
              barcode: product.barcode,
              productName: product.productName,
              date: product.date,
              price: product.price,
              isSafe: _barcodeService.checkProductSafety(user, product),
              ingredients: product.ingredients,
            );
            // Save product to Firestore
            await _firestoreService.saveProduct(_authService.getCurrentUser()!.uid, product);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scanned: $value - ${product.isSafe ? "Safe" : "Not Safe"}')),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error scanning product: $e')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}