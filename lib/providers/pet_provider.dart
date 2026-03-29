import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';

class PetNotifier extends Notifier<List<Pet>> {
  // กำหนดค่าเริ่มต้น (Initial State) เป็นลิสต์ว่างๆ []
  @override
  List<Pet> build() {
    return [];
  }

  void addPet(Pet pet) {
    state = [...state, pet];
  }

  void deletePet(String id) {
    state = state.where((pet) => pet.id != id).toList();
  }

  void updatePet(Pet updatedPet) {
    state = [
      for (final pet in state)
        if (pet.id == updatedPet.id) updatedPet else pet,
    ];
  }
}

final petProvider = NotifierProvider<PetNotifier, List<Pet>>(() {
  return PetNotifier();
});
