import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final int? id;
  final String? code;
  final String name;
  final String? description;
  final String unit;
  final double price;
  final double vatRate;
  final bool isService;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemEntity({
    this.id,
    this.code,
    required this.name,
    this.description,
    required this.unit,
    required this.price,
    required this.vatRate,
    required this.isService,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  ItemEntity copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? unit,
    double? price,
    double? vatRate,
    bool? isService,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      vatRate: vatRate ?? this.vatRate,
      isService: isService ?? this.isService,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, code, name, description, unit, price, vatRate, isService, isActive, createdAt, updatedAt];
}
