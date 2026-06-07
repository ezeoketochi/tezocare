import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String gender;
  final String? phone;
  final String? address;
  final String? state;
  final String? city;
  final String? occupation;
  final String? bloodGroup;
  final String? genotype;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? registeredBy;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    required this.gender,
    this.phone,
    this.address,
    this.state,
    this.city,
    this.occupation,
    this.bloodGroup,
    this.genotype,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.registeredBy,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  DateTime? get dob => dateOfBirth;

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? occupation,
    String? bloodGroup,
    String? genotype,
    List<String>? allergies,
    List<String>? chronicConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? registeredBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      genotype: genotype ?? this.genotype,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      registeredBy: registeredBy ?? this.registeredBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        phone,
        address,
        state,
        city,
        occupation,
        bloodGroup,
        genotype,
        allergies,
        chronicConditions,
        emergencyContactName,
        emergencyContactPhone,
        registeredBy,
        isActive,
        createdAt,
        updatedAt,
      ];
}
