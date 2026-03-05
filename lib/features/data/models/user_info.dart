class UserInfo {
  final String name;
  final String contact;

  const UserInfo({required this.name, required this.contact});

  Map<String, dynamic> toJson() => {
        'user_name': name,
        'user_contact': contact,
      };
}
