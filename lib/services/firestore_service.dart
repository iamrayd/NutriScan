import 'package:cloud_firestore/cloud_firestore.dart';
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
          .set(product.toMap());
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
          .get();
      return query.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }
}