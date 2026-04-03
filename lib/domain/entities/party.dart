import 'package:equatable/equatable.dart';

class Party extends Equatable {
  final int? id;
  final String name;
  final String? businessNumber;
  final String? vatNumber;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Party({
    this.id,
    required this.name,
    this.businessNumber,
    this.vatNumber,
    this.address,
    this.city,
    this.phone,
    this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Party copyWith({
    int? id,
    String? name,
    String? businessNumber,
    String? vatNumber,
    String? address,
    String? city,
    String? phone,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      businessNumber: businessNumber ?? this.businessNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        businessNumber,
        vatNumber,
        address,
        city,
        phone,
        email,
        isActive,
        createdAt,
        updatedAt,
      ];
}
