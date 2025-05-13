import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _bioController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "Complete Profile",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/auth/complete_profile_asset.png',
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  hint: "First Name",
                  icon: Icons.person,
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter your first name";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: "Middle Name",
                  icon: Icons.person_outline,
                  controller: _middleNameController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: "Last Name",
                  icon: Icons.person,
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter your last name";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: "Phone number",
                  icon: Icons.phone,
                  controller: _phoneNumberController,
                  validator: (value) {
                    if (value == null || value.length < 10) return "Enter a valid phone number";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: "Bio",
                  icon: Icons.person_2_outlined,
                  controller: _bioController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print("Form is valid");
                        User? user = _authService.getCurrentUser();
                        if (user != null) {
                          UserModel userModel = UserModel(
                            uid: user.uid,
                            email: _emailController.text,
                            firstName: _firstNameController.text,
                            middleName: _middleNameController.text,
                            lastName: _lastNameController.text,
                            phoneNumber: _phoneNumberController.text,
                            bio: _bioController.text,
                            allergens: [],
                          );
                          await _firestoreService.saveUserProfile(userModel);
                          showDialog(
                            context: context,
                            builder: (_) => AllergenWidget(
                              onAllergensSelected: (selectedAllergens) async {
                                await _firestoreService.updateUserAllergens(user.uid, selectedAllergens);
                                AppNavigator.pushReplacement(context, ScreenHandler());
                              },
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Proceed",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}