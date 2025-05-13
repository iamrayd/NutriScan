import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriscan/utils/utils.dart';
import '../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final List<ProductModel>? healthyAlternatives;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.healthyAlternatives,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _showSummaryPopup();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_products')
        .doc(widget.product.barcode)
        .get();

    setState(() {
      isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_products')
        .doc(widget.product.barcode);

    if (isFavorite) {
      await savedRef.delete();
    } else {
      await savedRef.set({
        'productName': widget.product.productName,
        'barcode': widget.product.barcode,
        'imageURL': widget.product.imageURL,
        'calories': widget.product.calories,
        'nutrients': widget.product.nutrients,
        'ingredients': widget.product.ingredients,
        'nutritionalInfo': widget.product.nutritionalInfo,
        'allergens': widget.product.allergens,
        'price': widget.product.price,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _addToRecentScans() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final recentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recent_scans')
        .doc(widget.product.barcode);

    try {
      await recentRef.set({
        'productName': widget.product.productName,
        'barcode': widget.product.barcode,
        'imageURL': widget.product.imageURL,
        'calories': widget.product.calories,
        'nutrients': widget.product.nutrients,
        'ingredients': widget.product.ingredients,
        'nutritionalInfo': widget.product.nutritionalInfo,
        'allergens': widget.product.allergens,
        'price': widget.product.price,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error adding to recent scans: $e");
    }
  }

  void _showSummaryPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.product.isSafe ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.product.isSafe ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        widget.product.isSafe ? Icons.check_circle : Icons.warning,
                        color: widget.product.isSafe ? Colors.green : Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 12), // Vertical spacing between icon and text
                      Text(
                        widget.product.isSafe ? 'No Allergen Detected' : 'Allergen Detected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.product.isSafe ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.clipper,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await _addToRecentScans();
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      widget.product.imageURL,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/todo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.productName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.product.barcode, style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _infoCard("Calories", widget.product.calories, Icons.local_fire_department),
                  _infoCard("Nutrients", widget.product.nutrients, Icons.restaurant),
                  _infoCard("Ingredients", widget.product.ingredients.join(", "), Icons.list),
                  _infoCard("Nutritional Info", widget.product.nutritionalInfo, Icons.info),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Healthy alternatives you can try",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: (widget.healthyAlternatives != null &&
                    widget.healthyAlternatives!.isNotEmpty)
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.healthyAlternatives!.length,
                  itemBuilder: (context, index) {
                    final alt = widget.healthyAlternatives![index];
                    return _altCard(alt.productName, alt.calories, alt.imageURL);
                  },
                )
                    : const Center(child: Text("Nothing to show")),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content, IconData icon) {
    return Container(
      width: 160,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content.isNotEmpty ? content : 'N/A',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _altCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 60,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/todo.png',
                  height: 60,
                  width: 120,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}