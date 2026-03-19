import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import '../../models/models.dart';
import 'vehicle_details_screen.dart';

class AddVehicleScreen extends StatefulWidget {
  final Equipment? equipment; // For editing

  const AddVehicleScreen({super.key, this.equipment});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceHrController = TextEditingController();
  final _priceDayController = TextEditingController();
  final _vehicleNumController = TextEditingController();
  final _rcNumController = TextEditingController();
  
  String _selectedType = 'Tractor';
  XFile? _imageFile;
  PlatformFile? _legalDoc;
  bool _isSaving = false;
  List<String> _availableSlots = ['06:00 - 09:00', '09:00 - 12:00', '12:00 - 15:00', '15:00 - 18:00', '18:00 - 21:00'];

  final List<String> _allSlots = [
    '06:00 - 09:00',
    '09:00 - 12:00',
    '12:00 - 15:00',
    '15:00 - 18:00',
    '18:00 - 21:00',
    '21:00 - 00:00',
    '00:00 - 03:00',
    '03:00 - 06:00'
  ];

  final List<Map<String, dynamic>> _machineryTypes = [
    {'name': 'Tractor', 'icon': Icons.agriculture},
    {'name': 'Harvester', 'icon': Icons.agriculture},
    {'name': 'Drone', 'icon': LucideIcons.plane},
    {'name': 'Plough', 'icon': Icons.handyman},
    {'name': 'Seeder', 'icon': Icons.grain},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _nameController.text = widget.equipment!.name;
      _modelController.text = widget.equipment!.model;
      _priceHrController.text = widget.equipment!.pricePerHour.toString();
      _priceDayController.text = widget.equipment!.pricePerDay.toString();
      _vehicleNumController.text = widget.equipment!.vehicleNumber;
      _rcNumController.text = widget.equipment!.rcNumber;
      _selectedType = widget.equipment!.type;
      _availableSlots = List.from(widget.equipment!.availableSlots);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _legalDoc = result.files.first;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final appState = context.read<AppStateProvider>();
      final newVehicle = Equipment(
        id: widget.equipment?.id ?? '', // Provider will generate if empty, or DB will handle it
        name: _nameController.text,
        model: _modelController.text,
        type: _selectedType,
        image: _imageFile?.path ?? widget.equipment?.image ?? 'https://picsum.photos/seed/tractor/400/300',
        location: widget.equipment?.location ?? 'Main Warehouse',
        status: widget.equipment?.status ?? 'available',
        pricePerHour: int.parse(_priceHrController.text),
        pricePerDay: int.parse(_priceDayController.text),
        vehicleNumber: _vehicleNumController.text,
        rcNumber: _rcNumController.text,
        verified: widget.equipment?.verified ?? false,
        availableSlots: _availableSlots,
        owner: widget.equipment?.owner ?? const Owner(name: 'Equipment Owner', experience: '3 years', rating: 4.8),
      );

      Equipment? createdVehicle;
      if (widget.equipment == null) {
        createdVehicle = await appState.addVehicle(newVehicle, imageFile: _imageFile != null ? File(_imageFile!.path) : null);
      } else {
        await appState.updateVehicle(newVehicle);
      }

      if (mounted) {
        final mainState = context.read<AppState>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.equipment == null ? mainState.translate('successAdd') : mainState.translate('successUpdate'))),
        );
        
        if (widget.equipment == null && createdVehicle != null) {
          // Redirect to details of new vehicle
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VehicleDetailsScreen(equipment: createdVehicle!)),
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.read<AppState>().translate('error')} : $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleSlot(String slot) {
    setState(() {
      if (_availableSlots.contains(slot)) {
        if (_availableSlots.length > 1) {
           _availableSlots.remove(slot);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(context.read<AppState>().translate('atLeastOneSlot'))),
           );
        }
      } else {
        _availableSlots.add(slot);
        // Sort slots for cleanliness
        _availableSlots.sort((a, b) => a.compareTo(b));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(widget.equipment == null ? mainState.translate('addNewMachinery') : mainState.translate('editMachinery')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2F7F33)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Upload Section
                  Text(mainState.translate('machineryPhoto'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.values[1]), // Dashed style not simple, but let's use solid for now
                      ),
                      child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                          )
                        : widget.equipment != null && widget.equipment!.image.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(widget.equipment!.image, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.camera, size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(mainState.translate('uploadImage'), style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Machinery Type Widgets
                  Text(mainState.translate('machineryType'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _machineryTypes.length,
                      itemBuilder: (context, index) {
                        final type = _machineryTypes[index];
                        final isSelected = _selectedType == type['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type['name']),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2F7F33) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF2F7F33) : Colors.grey.shade200),
                              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2F7F33).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(type['icon'], color: isSelected ? Colors.white : Colors.grey.shade600),
                                const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      mainState.translate(type['name'].toString().toLowerCase()),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Info
                  _buildTextField(mainState.translate('machineryName'), _nameController, hint: 'e.g. John Deere 8R 410'),
                  _buildTextField(mainState.translate('modelDesc'), _modelController, hint: 'e.g. 2023 • Heavy Duty'),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('${mainState.translate('price')} / ${mainState.translate('hr')} (₹)', _priceHrController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('${mainState.translate('price')} / ${mainState.translate('day')} (₹)', _priceDayController, isNumber: true)),
                    ],
                  ),

                  _buildTextField(mainState.translate('vehicleNumber'), _vehicleNumController, hint: 'e.g. KA 01 MG 1234'),
                  _buildTextField(mainState.translate('rcNumber'), _rcNumController, hint: 'e.g. RC9876543210'),
                  
                  const SizedBox(height: 24),

                  // Legal Documents
                  Text(mainState.translate('legalDocs'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDocument,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F7F33).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.fileText, color: Color(0xFF2F7F33)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    _legalDoc != null ? _legalDoc!.name : (widget.equipment != null ? 'RC_Book_Verified.pdf' : mainState.translate('attachRc')),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    _legalDoc != null ? '${(_legalDoc!.size / 1024).toStringAsFixed(1)} KB' : mainState.translate('allowedFiles'),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                  const Icon(LucideIcons.upload, size: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Availability Slots
                  Text(mainState.translate('availabilitySlots'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(mainState.translate('selectSlotsDesc'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _allSlots.map((slot) {
                      final isSelected = _availableSlots.contains(slot);
                      return GestureDetector(
                        onTap: () => _toggleSlot(slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2F7F33) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? const Color(0xFF2F7F33) : Colors.grey.shade300),
                            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2F7F33).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : [],
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7F33),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.equipment == null ? mainState.translate('submitMachinery') : mainState.translate('updateMachinery'),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) => value == null || value.isEmpty ? context.read<AppState>().translate('requiredField') : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2F7F33)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
