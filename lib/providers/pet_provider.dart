import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PetNotifier extends Notifier<List<Pet>> {
  static const _storageKey = 'pet_list';
  @override
  List<Pet> build() {
    _loadPets();
    return [];
  }

  Future<void> _saveToStorage(List<Pet> pets) async {
    final preferences = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      pets.map((pet) => pet.toMap()).toList(),
    );
    await preferences.setString(_storageKey, encodedData);
  }

  Future<void> _loadPets() async {
    final preferences = await SharedPreferences.getInstance();
    final String? saveData = preferences.getString(_storageKey);

    if (saveData != null) {
      final List<dynamic> decodedData = jsonDecode(saveData);
      state = decodedData.map((item) => Pet.fromMap(item)).toList();
    }
  }

  void addPet(Pet pet) {
    state = [...state, pet];
    _saveToStorage(state);
  }

  void deletePet(String id) {
    state = state.where((pet) => pet.id != id).toList();
    _saveToStorage(state);
  }

  void updatePet(Pet updatedPet) {
    state = [
      for (final pet in state)
        if (pet.id == updatedPet.id) updatedPet else pet,
    ];
    _saveToStorage(state);
  }
}

final petProvider = NotifierProvider<PetNotifier, List<Pet>>(() {
  return PetNotifier();
});
