class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
  final String phoneNumber;
  final String bio;
  final List<String> allergens;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phoneNumber,
    required this.bio,
    required this.allergens,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'allergens': allergens,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      allergens: List<String>.from(map['allergens'] ?? []),
    );
  }
}