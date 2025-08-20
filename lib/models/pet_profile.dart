class PetProfile {
  String name;
  String age;
  String memo;
  String gender;
  String profileImagePath;
  String backgroundImagePath;

  PetProfile({
    required this.name,
    required this.age,
    this.memo = '',
    this.gender = 'male',
    this.profileImagePath = '',
    this.backgroundImagePath = '',
  });
}
