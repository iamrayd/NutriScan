import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import for User
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/allergen_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    UserModel? fetchedUser = await _firestoreService.getUserProfile(_authService.getCurrentUser()!.uid);
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${user!.firstName} ${user!.lastName}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user!.bio.isNotEmpty ? user!.bio : "A Health Enthusiast",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Personal Information", style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputBox("First Name", user!.firstName)),
              const SizedBox(width: 8),
              Expanded(child: _buildInputBox("Last Name", user!.lastName)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInputBox("Email Address", _authService.getCurrentUser()!.email ?? "")),
              const SizedBox(width: 8),
              Expanded(child: _buildInputBox("Phone No.", user!.phoneNumber)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Allergen Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AllergenWidget(
                            onAllergensSelected: (selectedAllergens) async {
                              await _firestoreService.updateUserAllergens(_authService.getCurrentUser()!.uid, selectedAllergens);
                              _loadUserProfile(); // Refresh the profile
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const Text("User Allergens", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user!.allergens.isNotEmpty
                      ? user!.allergens.map((allergen) => _buildPill(allergen)).toList()
                      : [Text("No allergens selected")],
                ),
                const SizedBox(height: 16),
                const Text("Suggested Allergens", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(6, (_) => _buildPill("Suggested")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Fix the syntax error
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildPill(String allergen) {
    return Container(
      width: 100,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(allergen, style: TextStyle(fontSize: 12)),
    );
  }
}