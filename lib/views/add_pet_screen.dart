import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import 'package:uuid/uuid.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _savePet() {
    if (_nameController.text.isEmpty || _breedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    } else if (_selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันเกิดที่ถูกต้อง')),
      );
      return;
    }

    final pet = Pet(
      id: const Uuid().v4(),
      name: _nameController.text,
      breed: _breedController.text,
      birthDate: _selectedDate,
    );

    ref.read(petProvider.notifier).addPet(pet);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มสมาชิกใหม่ 🐾'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อน้อง'),
            ),
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'สายพันธุ์'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                //Text('วันเกิด: ${_selectedDate.toLocal()}'.split(' ')[0]),
                Text(
                  'วันที่: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                        debugPrint(_selectedDate.toString());
                      });
                    }
                  },
                  child: const Text('เลือกวันเกิด'),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _savePet,
              child: const Text('บันทึกน้องแมว'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
