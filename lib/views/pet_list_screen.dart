import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_pulse/views/add_pet_screen.dart';
import '../providers/pet_provider.dart';
import 'dart:io';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบข้อมูล?'),
        content: Text('คูญแน่ใจใช่มั้ยว่าจะลบข้อมูล ของ "${pet.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              ref.read(petProvider.notifier).deletePet(pet.id);
              Navigator.pop(context);
            },
            child: const Text('ลบเลย', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petList = ref.watch(petProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets 🐾'),
        backgroundColor: Colors.orange,
      ),
      body: petList.isEmpty
          ? const Center(child: Text('ยังไม่มีน้องแมวเลย เพิ่มเลย!'))
          : ListView.builder(
              itemCount: petList.length,
              itemBuilder: (context, index) {
                final pet = petList[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange[100],
                    backgroundImage: pet.imagePath != null
                        ? FileImage(File(pet.imagePath!))
                        : null,
                    child: pet.imagePath == null
                        ? const Icon(Icons.pets, color: Colors.orange)
                        : null,
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('${pet.breed} - ${pet.ageDisplay}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(context, ref, pet);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddPetScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
