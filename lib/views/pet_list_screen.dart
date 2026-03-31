import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_pulse/views/add_pet_screen.dart';
import '../providers/pet_provider.dart';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

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
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(pet.name),
                  subtitle: Text('${pet.breed} - ${pet.ageDisplay}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(petProvider.notifier).deletePet(pet.id);
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
