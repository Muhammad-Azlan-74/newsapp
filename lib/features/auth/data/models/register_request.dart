/// Register Request Model
///
/// Request body for /register API endpoint
class RegisterRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String selectedTeam;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.selectedTeam,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'fullName': name,  // Backend expects 'fullName' instead of 'name'
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'selectedTeam': selectedTeam,
    };
  }
}
