import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int id;
  final String name;
  final String species;
  final String? breed;
  final String? color;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? weight;
  final String? microchipId;
  final int? ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.color,
    this.gender,
    this.dateOfBirth,
    this.weight,
    this.microchipId,
    this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.notes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        breed,
        color,
        gender,
        dateOfBirth,
        weight,
        microchipId,
        ownerId,
        ownerName,
        ownerPhone,
        ownerEmail,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];
}
