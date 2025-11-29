class FamilyMemberRequest {
  final String name;
  final String birthday;
  final String gender;

  FamilyMemberRequest({
    required this.name,
    required this.birthday,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "birthday": birthday,
    "gender": gender,
  };
}
