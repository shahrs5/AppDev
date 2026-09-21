class Address {
  final String street;
  final String city;
  Address({required this.street, required this.city});
  factory Address.fromJson(Map<String, dynamic> j) =>
      Address(street: j['street'], city: j['city']);
}

class Company {
  final String name;
  Company({required this.name});
  factory Company.fromJson(Map<String, dynamic> j) => Company(name: j['name']);
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final Address address;
  final Company company;
  final bool favourites;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
    this.favourites = false,
  });
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    name: j['name'],
    email: j['email'],
    phone: j['phone'],
    address: Address.fromJson(j['address']),
    company: Company.fromJson(j['company']),
  );
}
