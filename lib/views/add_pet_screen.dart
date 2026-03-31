import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  late DateTime _selectedDate;
  String? _imagePath;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // ในที่นี้เรายังไม่ได้เก็บ imagePath ไว้ใน Pet model
      // แต่ถ้าต้องการเก็บก็สามารถเพิ่มฟิลด์ imagePath ใน Pet และอัพเดตโค้ดที่นี่ได้เลย
      setState(() {
        _imagePath = image.path;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เลือกรูปภาพสำเร็จ')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่ได้เลือกรูปภาพ')));
    }
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
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),

                //child: const Center(child: Text('แตะเพื่อเลือกรูปภาพ')),
                child: _imagePath == null
                    // ? const Center(
                    //     child: Text('แตะเพื่อเลือกรูปภาพ'),
                    //   ) //Image.file(File(_imagePath!), fit: BoxFit.cover),
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('เพิ่มรูปน้องแมว'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imagePath!),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
              ),
              child: const Text('บันทึกน้องแมว'),
            ),
          ],
        ),
      ),
    );
  }
}
