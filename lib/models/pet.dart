import 'package:uuid/uuid.dart';

class Pet {
  final String id;
  final String name;
  final String breed;
  final DateTime birthDate;
  final String? imagePath;
  final bool isVaccinated;
  final DateTime? vaccineSchedule;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    this.imagePath,
    this.isVaccinated = false,
    this.vaccineSchedule,
  });

  String get ageDisplay {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return '$years ปี $months เดือน';
    } else {
      return '$months เดือน';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
      'imagePath': imagePath,
      'isVaccinated': isVaccinated,
      'vaccineSchedule': vaccineSchedule?.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      birthDate: DateTime.parse(map['birthDate']),
      imagePath: map['imagePath'],
      isVaccinated: map['isVaccinated'] ?? false,
      vaccineSchedule: map['vaccineSchedule'] != null
          ? DateTime.parse(map['vaccineSchedule'])
          : null,
    );
  }
}
