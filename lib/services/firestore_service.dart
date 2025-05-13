import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_constants.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<List<ProductModel>> getSavedProducts(String uid) async {
    try {
      QuerySnapshot query = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.savedProductsCollection)
          .get();
      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch saved products: $e');
    }
  }

  Future<void> updateUserAllergens(String uid, List<String> allergens) async {
    try {
      await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .update({'allergens': allergens});
    } catch (e) {
      throw Exception('Failed to update allergens: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> saveProduct(String userId, ProductModel product) async {
    try {
      await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.productsCollection)
          .doc(product.barcode)
          .set({
        ...product.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  Future<List<ProductModel>> getProducts(String userId) async {
    try {
      QuerySnapshot query = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.productsCollection)
          .orderBy('timestamp', descending: true)
          .get();
      return query.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get saved products: $e');
    }
  }

  Future<void> saveRecentScan(String userId, ProductModel product) async {
    try {
      await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.recentScansCollection)
          .doc(product.barcode)
          .set({
        ...product.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save recent scan: $e');
    }
  }

  Future<List<ProductModel>> getRecentScans(String userId) async {
    try {
      QuerySnapshot query = await _db
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.recentScansCollection)
          .orderBy('timestamp', descending: true)
          .get();
      return query.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent scans: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final recentScansQuery = await _db
        .collection('users')
        .doc(user.uid)
        .collection('recent_scans')
        .limit(5)
        .get();
    final savedProductsQuery = await _db
        .collection('users')
        .doc(user.uid)
        .collection('saved_products')
        .limit(5)
        .get();

    List<String> allergens = List<String>.from(userDoc.data()?['allergens'] ?? []);
    List<Map<String, dynamic>> recentScans = recentScansQuery.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    List<Map<String, dynamic>> savedProducts = savedProductsQuery.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return {
      'allergens': allergens,
      'recentScans': recentScans,
      'savedProducts': savedProducts,
    };
  }
}