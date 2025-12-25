/// Signup Data Model
///
/// Holds user signup information to pass between screens
class SignupData {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  const SignupData({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}
