import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutriscan/utils/utils.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/barcode_service.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../product_details_screen.dart';

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
          future: _authService.getCurrentUser() != null
              ? _firestoreService.getUserProfile(_authService.getCurrentUser()!.uid).timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          )
              : Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Error loading user profile or no user logged in'));
            }
            UserModel user = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  "assets/home_screen_asset.png",
                  height: ScreenUtils.imageHeightHalf(context),
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_authService.getCurrentUser() != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BarcodeScannerScreen(user: user)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to scan products')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: const StadiumBorder(),
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
                    future: _authService.getCurrentUser() != null
                        ? _firestoreService.getRecentScans(_authService.getCurrentUser()!.uid)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(child: Text('Error loading recent scans'));
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
                              subtitle: Text("Product: ${item.productName} | Price: ${item.price}"),
                              trailing: Text(
                                item.isSafe ? "Safe" : "Not Safe",
                                style: TextStyle(
                                  color: item.isSafe ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsScreen(product: item),
                                  ),
                                );
                              },
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
    bool _isScanned = false;

    return Scaffold(
      body: MobileScanner(
        controller: MobileScannerController(
          facing: CameraFacing.back,
        ),
        onDetect: (capture) async {
          if (_isScanned) return;
          _isScanned = true;

          try {
            final barcode = capture.barcodes.first;
            final value = barcode.rawValue ?? "---";

            ProductModel product = await _barcodeService.fetchProductDetails(value);
            product = ProductModel(
              barcode: product.barcode,
              productName: product.productName,
              date: product.date,
              price: product.price,
              isSafe: _barcodeService.checkProductSafety(user, product),
              ingredients: product.ingredients,
              calories: product.calories,
              nutrients: product.nutrients,
              nutritionalInfo: product.nutritionalInfo,
              imageURL: product.imageURL,
              allergens: product.allergens,
            );
            await _firestoreService.saveRecentScan(_authService.getCurrentUser()!.uid, product);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scanned: $value - ${product.isSafe ? "Safe" : "Not Safe"}')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error scanning product: $e')),
            );
            _isScanned = false;
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}