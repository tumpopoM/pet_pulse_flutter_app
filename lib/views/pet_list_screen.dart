import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_pulse/models/pet.dart';
import 'package:pet_pulse/views/add_pet_screen.dart';
import 'package:pet_pulse/views/update_pet_screen.dart';
import '../providers/pet_provider.dart';
import 'dart:io';

class PetListScreen extends ConsumerStatefulWidget {
  const PetListScreen({super.key});

  @override
  ConsumerState<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends ConsumerState<PetListScreen> {
  String _searchQuery = '';
  bool _sortByAge = false;

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Pet pet) {
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
  Widget build(BuildContext context) {
    final petList = ref.watch(petProvider);

    List<Pet> filteredPets = petList.where((pet) {
      return pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_sortByAge) {
      filteredPets.sort((a, b) => b.birthDate.compareTo(a.birthDate));
    } else {
      filteredPets.sort((a, b) => a.name.compareTo(b.name));
    }

    Widget buildBody() {
      if (petList.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text('ยังไม่มีน้องแมวเลย เพิ่มสมาชิกตัวแรกกัน 🐾'),
            ],
          ),
        );
      }

      if (filteredPets.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  labelText: 'ค้นหาชื่อน้องแมวหรือสายพันธุ์...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 100, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('ไม่พบน้องแมวที่คุณค้นหา 😿'),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'ค้นหาชื่อน้องแมวหรือสายพันธุ์...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPets.length,
              itemBuilder: (context, index) {
                final pet = filteredPets[index];
                return ListTile(
                  leading: pet.imagePath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(pet.imagePath!)),
                        )
                      : CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(pet.name),
                  subtitle: Text('${pet.breed} - ${pet.ageDisplay}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, ref, pet),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePetScreen(pet: pet),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets 🐾'),
        backgroundColor: Colors.orange,
        actions: [
          petList.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    _sortByAge ? Icons.calendar_month : Icons.sort_by_alpha,
                  ),
                  onPressed: () {
                    setState(() {
                      _sortByAge = !_sortByAge;
                    });
                  },
                )
              : SizedBox(),
        ],
      ),
      body: buildBody(),
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
