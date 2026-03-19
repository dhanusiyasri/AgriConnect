import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class DamageReportScreen extends StatefulWidget {
  const DamageReportScreen({super.key});

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final TextEditingController _descController = TextEditingController();
  final List<XFile> _imageFiles = [];
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_imageFiles.length >= 3) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFiles.add(image);
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final state = context.read<AppState>();
    final booking = state.selectedBooking;
    
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe the damage')));
      return;
    }
    
    if (booking == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active booking selected')));
       return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final List<String> imageUrls = [];

      for (var file in _imageFiles) {
        final fileName = 'damage_${DateTime.now().millisecondsSinceEpoch}_${_imageFiles.indexOf(file)}.jpg';
        final path = 'claims/$fileName';
        
        await supabase.storage.from('insurance').upload(path, File(file.path));
        final url = supabase.storage.from('insurance').getPublicUrl(path);
        imageUrls.add(url);
      }
      
      await supabase.from('insurance_claims').insert({
        'booking_id': booking.id,
        'equipment_id': booking.equipmentId,
        'damage_description': _descController.text,
        'damage_images': imageUrls,
        'claim_status': 'REPORTED',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.checkCircle, color: AppTheme.green400),
              SizedBox(width: 12),
              Text('Report submitted to owner', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: AppTheme.slate900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      state.setScreen('bookings'); // Go back to bookings after successful report
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppTheme.slate900),
                    onPressed: () => context.read<AppState>().setScreen('vehicle-received'),
                  ),
                  const Text('Report Damage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                  const SizedBox(width: 48), // Balance for centering
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: AppTheme.red600, size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Important Notice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.red600)),
                                const SizedBox(height: 4),
                                Text(
                                  'Reporting false damage can lead to account suspension. Please provide accurate details.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.red600.withOpacity(0.8), height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Upload Photos', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                    const SizedBox(height: 8),
                    const Text('Please upload clear photos of the damage from different angles.', style: TextStyle(fontSize: 14, color: AppTheme.slate500)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ..._imageFiles.map((file) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: FileImage(File(file.path)), fit: BoxFit.cover),
                          ),
                        )),
                        if (_imageFiles.length < 3) _buildPhotoUploadBtn(),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Damage Description', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe where the damage is and how it happened...',
                        hintStyle: const TextStyle(color: AppTheme.slate400, fontSize: 14),
                        filled: true,
                        fillColor: AppTheme.slate50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red600,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.red200,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadBtn() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.green50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.green600, style: BorderStyle.none),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(LucideIcons.camera, color: AppTheme.green600, size: 24),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppTheme.green600, shape: BoxShape.circle),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
