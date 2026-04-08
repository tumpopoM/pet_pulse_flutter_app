import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

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
    final String? savedData = preferences.getString(_storageKey);

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      state = decodedData.map((item) => Pet.fromMap(item)).toList();
    }
  }

  void addPet(Pet pet) {
    state = [...state, pet];
    _saveToStorage(state);

    if (pet.vaccineSchedule != null) {
      final notificationDate = pet.vaccineSchedule!;
      NotificationService()
          .scheduleNotification(
            id: pet.id.hashCode,
            title: 'นัดฉีดวัคซีนน้อง ${pet.name}!🐾',
            body: 'วันนี้มีนัดพาน้องไปหาหมอนะคะ',
            scheduledDate: notificationDate,
          )
          .then((_) => print('✅ ตั้งเตือนนัดจริงสำเร็จที่!: $notificationDate'))
          .catchError((e) => print('❌ ตั้งเตือนพลาดเพราะ: $e'));
    }

    // print('--- เริ่มนับถอยหลัง 10 วินาทีในแอป ---');

    // // ใช้ Future.delayed ของ Dart เองเลยค่ะ ไม่ต้องง้อระบบ Schedule ของ OS
    // Future.delayed(const Duration(seconds: 10), () {
    //   print('--- ครบ 10 วินาทีแล้ว สั่งเด้งทันที! ---');

    //   // เรียกใช้ฟังก์ชันที่ "เด้งแน่นอน" ที่คุณเมเพิ่งเทสผ่านไปตะกี้ค่ะ
    //   NotificationService().showInstantNotification();
    // });
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
