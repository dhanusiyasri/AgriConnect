import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _vehicleConditionRating = 4;
  int _ownerBehaviorRating = 4;
  int _valueForMoneyRating = 4;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      setState(() {
        _image = File(selected.path);
      });
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Photo From', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(context, LucideIcons.camera, 'Camera', () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    }),
                    _buildPickerOption(context, LucideIcons.image, 'Gallery', () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.green50, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.green700, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;

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
                    onPressed: () => context.read<AppState>().setScreen('dashboard'),
                  ),
                  const Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                  const SizedBox(width: 48), // Balance for centering
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(equipment?.image ?? 'https://picsum.photos/seed/tractor/400/300', width: 128, height: 128, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                    Text(equipment?.name ?? 'Mahindra Arjun 555', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                    const SizedBox(height: 8),
                    const Text('How was your experience with this vehicle?', style: TextStyle(color: AppTheme.slate500)),
                    const SizedBox(height: 32),
                    _buildRatingRow(
                      'Vehicle Condition', 
                      Icons.agriculture, 
                      _vehicleConditionRating, 
                      (rating) => setState(() => _vehicleConditionRating = rating),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingRow(
                      'Owner Behavior', 
                      LucideIcons.user, 
                      _ownerBehaviorRating, 
                      (rating) => setState(() => _ownerBehaviorRating = rating),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingRow(
                      'Value for Money', 
                      LucideIcons.creditCard, 
                      _valueForMoneyRating, 
                      (rating) => setState(() => _valueForMoneyRating = rating),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Feedback', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                        const SizedBox(height: 16),
                        TextField(
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Tell us more about the performance, fuel efficiency, etc...',
                            hintStyle: const TextStyle(color: AppTheme.slate400, fontSize: 14),
                            filled: true,
                            fillColor: AppTheme.slate50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_image!, width: double.infinity, height: 200, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(LucideIcons.x, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showImagePicker(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.slate50,
                          foregroundColor: AppTheme.slate500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.camera, size: 20),
                            const SizedBox(width: 8),
                            Text(_image == null ? 'Add Photos' : 'Change Photo', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(LucideIcons.checkCircle2, color: AppTheme.green400),
                            SizedBox(width: 12),
                            Text('Review submitted successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        backgroundColor: AppTheme.slate900,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                    context.read<AppState>().setScreen('dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: const Text('Submit Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, IconData icon, int currentRating, ValueChanged<int> onRatingChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4)]),
                child: Icon(icon, color: AppTheme.slate600, size: 20),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate700)),
            ],
          ),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Icon(
                  LucideIcons.star,
                  size: 20,
                  color: index < currentRating ? AppTheme.amber400 : AppTheme.slate300,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
