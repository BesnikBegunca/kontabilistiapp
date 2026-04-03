import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final int? id;
  final String name;
  final String? businessNumber;
  final String? vatNumber;
  final String? address;
  final String? city;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? bankAccount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Company({
    this.id,
    required this.name,
    this.businessNumber,
    this.vatNumber,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.bankAccount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Company copyWith({
    int? id,
    String? name,
    String? businessNumber,
    String? vatNumber,
    String? address,
    String? city,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? bankAccount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      businessNumber: businessNumber ?? this.businessNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      bankAccount: bankAccount ?? this.bankAccount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, businessNumber, vatNumber, address, city, country, phone, email, website, bankAccount, notes, createdAt, updatedAt];
}
