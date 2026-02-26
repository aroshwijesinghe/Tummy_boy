class UserProfile {
  final int age;
  final int heightCm;
  final int weightKg;
  final String? illness;

  const UserProfile({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.illness,
  });
}
