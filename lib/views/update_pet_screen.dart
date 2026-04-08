import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class UpdatePetScreen extends ConsumerStatefulWidget {
  final Pet pet;
  const UpdatePetScreen({super.key, required this.pet});

  @override
  ConsumerState<UpdatePetScreen> createState() => _UpdatePetScreenState();
}

class _UpdatePetScreenState extends ConsumerState<UpdatePetScreen> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late DateTime _selectedDate;
  String? _imagePath;
  DateTime? _selectedVaccineDate;
  TimeOfDay? _selectedTime;
  DateTime? finalSchedule;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _selectedDate = widget.pet.birthDate;
    _imagePath = widget.pet.imagePath;
    _selectedVaccineDate = widget.pet.vaccineSchedule;
    _selectedTime = widget.pet.vaccineSchedule != null
        ? TimeOfDay.fromDateTime(widget.pet.vaccineSchedule!)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
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

    if (_selectedVaccineDate != null && _selectedTime != null) {
      finalSchedule = DateTime(
        _selectedVaccineDate!.year,
        _selectedVaccineDate!.month,
        _selectedVaccineDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final updatedPet = Pet(
      id: widget.pet.id,
      name: _nameController.text,
      breed: _breedController.text,
      birthDate: _selectedDate,
      imagePath: _imagePath,
      vaccineSchedule: finalSchedule,
      isVaccinated: widget.pet.isVaccinated,
    );

    ref.read(petProvider.notifier).updatePet(updatedPet);
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedVaccineDate = picked;
        debugPrint(_selectedVaccineDate.toString());
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลน้องแมว 🐾'),
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
            Row(
              children: [
                // const Icon(Icons.calendar_today),
                // SizedBox(width: 8),
                Text(
                  _selectedVaccineDate == null
                      ? 'ยังไม่ได้เลือกวันนัดหมอ'
                      : 'วันนัดฉีดวัคซีน: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('เลือกวันนัดฉีดวัคซีน'),
                ),
              ],
            ),
            if (_selectedVaccineDate != null)
              Row(
                children: [
                  // const Icon(Icons.access_time),
                  // SizedBox(width: 8),
                  Text(
                    _selectedTime == null
                        ? 'ยังไม่ได้เลือกเวลาแจ้งเตือน'
                        : 'เวลา: ${_selectedTime!.format(context)}',
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _pickTime(context),
                    child: const Text('เลือกเวลาแจ้งเตือน'),
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
              child: const Text('อัปเดตข้อมูลน้องแมว'),
            ),
          ],
        ),
      ),
    );
  }
}
