import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriscan/screens/chatbot_screen.dart';
import 'package:nutriscan/services/api_service.dart';
import 'package:nutriscan/services/chatbot_service.dart';
import 'package:nutriscan/utils/utils.dart';
import '../models/product_model.dart';
import 'dart:math';
import 'dart:convert';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isFavorite = false;
  List<ProductModel> healthyAlternatives = [];
  List<String> userAllergens = [];
  bool isLoadingAlternatives = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _checkUserAllergenMatch();
    _fetchHealthyAlternatives();
  }

  Future<void> _checkUserAllergenMatch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        userAllergens = List<String>.from(doc.data()?['allergens'] ?? []);
        debugPrint("User allergens: $userAllergens");
        debugPrint("Product allergens: ${widget.product.allergens}");

        List<String> productAllergensList = widget.product.allergens?.cast<String>() ?? [];
        List<String> matchedAllergens = productAllergensList
            .where((productAllergen) => userAllergens.contains(productAllergen))
            .toList();

        _showAllergenAlert(matchedAllergens);
      } else {
        debugPrint("User document does not exist for UID: ${user.uid}");
      }
    } catch (e) {
      debugPrint("Failed to fetch allergen profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch allergen profile: $e')),
      );
    }
  }

  Future<void> _fetchHealthyAlternatives() async {
    setState(() => isLoadingAlternatives = true);
    try {
      // Step 1: Use ChatbotService to get similar product barcodes
      final chatbotService = ChatbotService();
      final prompt =
          "Suggest 3-6 products that are similar to '${widget.product.productName}' in the same category. \n"
          "Search for products in the category of '${widget.product.productName}' (primary category from categories_tags) in the Open Food Facts API. \n"
          "Return only the barcodes as a comma-separated list (e.g., '123456,789101,112131,415161') or include barcodes in your response (e.g., 'Similar products: 123456, 789101'). ""\n"
          "Make sure the similar barcodes exist in the Open Food Facts API.";
      final response = await chatbotService.getChatbotResponse(prompt);
      debugPrint("Chatbot response: $response");

      // Parse barcodes using ChatbotService
      List<String> barcodes = chatbotService.parseBarcodes(response);
      if (barcodes.isEmpty) {
        debugPrint("No valid barcodes found in chatbot response");
        setState(() => isLoadingAlternatives = false);
        return;
      }
      if (barcodes.length > 4) {
        barcodes = barcodes.sublist(0, 4); // Limit to 4
      }

      // Step 2: Fetch product details using ApiService
      final apiService = ApiService();
      List<ProductModel> fetchedAlternatives = [];
      for (String barcode in barcodes) {
        try {
          final product = await apiService.fetchProductDetails(barcode);
          if (product != null) {
            fetchedAlternatives.add(product);
          }
        } catch (e) {
          debugPrint("Failed to fetch product for barcode $barcode: $e");
        }
      }

      // Step 3: Filter out products with matching allergens
      List<ProductModel> safeAlternatives = [];
      for (var product in fetchedAlternatives) {
        List<String> productAllergens = product.allergens?.cast<String>() ?? [];
        bool hasAllergens = productAllergens.any((allergen) => userAllergens.contains(allergen));
        if (!hasAllergens) {
          safeAlternatives.add(product);
        }
      }

      // Step 4: Randomly select 1-4 safe alternatives
      if (safeAlternatives.isNotEmpty) {
        final random = Random();
        final count = random.nextInt(min(safeAlternatives.length, 4)) + 1; // 1-4
        safeAlternatives.shuffle(random);
        setState(() {
          healthyAlternatives = safeAlternatives.sublist(0, count);
          isLoadingAlternatives = false;
        });
      } else {
        setState(() => isLoadingAlternatives = false);
      }
    } catch (e) {
      debugPrint("Error fetching healthy alternatives: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch healthy alternatives: $e')),
      );
      setState(() => isLoadingAlternatives = false);
    }
  }

  void _showAllergenAlert(List<String> matchedAllergens) {
    final isSafe = matchedAllergens.isEmpty;
    final title = isSafe ? 'No Allergen Detected' : 'Allergen Detected';
    final message = isSafe ? 'Safe for user consumption' : matchedAllergens.join(', ');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSafe ? Icons.check_circle : Icons.cancel,
                color: isSafe ? Colors.green : Colors.red,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSafe ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_products')
          .doc(widget.product.barcode)
          .get();

      if (mounted) {
        setState(() {
          isFavorite = doc.exists;
        });
      }
    } catch (e) {
      debugPrint("Error checking favorite: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please log in to save products');
      return;
    }

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_products')
        .doc(widget.product.barcode);

    try {
      if (isFavorite) {
        await savedRef.delete();
        _showSnackBar('Removed from saved products');
      } else {
        await savedRef.set(_createProductMap(withTimestamp: true));
        _showSnackBar('Added to saved products');
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      _showSnackBar('Failed to update saved products: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Map<String, dynamic> _createProductMap({bool withTimestamp = false}) {
    final map = {
      'productName': widget.product.productName ?? 'Unknown',
      'barcode': widget.product.barcode ?? '',
      'imageURL': widget.product.imageURL ?? '',
      'calories': widget.product.calories ?? 'N/A',
      'nutrients': widget.product.nutrients ?? 'N/A',
      'ingredients': widget.product.ingredients ?? [],
      'nutritionalInfo': widget.product.nutritionalInfo ?? 'N/A',
      'allergens': widget.product.allergens ?? [],
      'price': widget.product.price ?? 'N/A',
      'isSafe': widget.product.isSafe ?? false,
      'date': widget.product.date ?? '',
    };

    if (withTimestamp) {
      map['timestamp'] = FieldValue.serverTimestamp();
    }

    return map;
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
      await recentRef.set(_createProductMap(withTimestamp: true));
    } catch (e) {
      debugPrint("Error adding to recent scans: $e");
    }
  }

  String _formatAllergens() {
    return widget.product.allergens.isNotEmpty
        ? widget.product.allergens.join(", ")
        : "None";
  }

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(chatHistory: []),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.black),
            onPressed: _navigateToChatbot,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProductImage(),
              const SizedBox(height: 8),
              _buildProductTitle(),
              const SizedBox(height: 8),
              Text(
                widget.product.barcode,
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildInfoCards(),
              const SizedBox(height: 20),
              _buildHealthyAlternativesSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.network(
            widget.product.imageURL.isNotEmpty
                ? widget.product.imageURL
                : 'https://via.placeholder.com/150',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/placeholder.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.yellow[600] : Colors.grey,
            size: 30,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildProductTitle() {
    return Text(
      widget.product.productName,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _infoCard("Calories", widget.product.calories, Icons.local_fire_department),
        _infoCard("Nutrients", widget.product.nutrients, Icons.restaurant),
        _infoCard("Ingredients", widget.product.ingredients.join(", "), Icons.list),
        _infoCard("Nutritional Info", widget.product.nutritionalInfo, Icons.info),
      ],
    );
  }

  Widget _buildHealthyAlternativesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: isLoadingAlternatives
              ? const Center(child: CircularProgressIndicator())
              : healthyAlternatives.isNotEmpty
              ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: healthyAlternatives.length,
            itemBuilder: (context, index) {
              final alt = healthyAlternatives[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to ProductDetailsScreen with the selected alternative
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(
                        product: alt,
                      ),
                    ),
                  );
                },
                child: _altCard(alt.productName, alt.calories, alt.imageURL),
              );
            },
          )
              : const Center(child: Text("No healthy alternatives found")),
        ),
      ],
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
              Icon(icon, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/120x60',
              height: 60,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/placeholder.png',
                  height: 60,
                  width: 120,
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}