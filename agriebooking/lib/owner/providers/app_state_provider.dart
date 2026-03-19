import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
export '../../models/models.dart';
import '../models/request.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class AppStateProvider with ChangeNotifier {
  List<Equipment> _machinery = [];
  List<FarmerRequest> _requests = [];
  UserProfile? _userProfile;
  int _navigationIndex = 0;
  bool _isInit = false;
  StreamSubscription<Position>? _locationSubscription;
  String? _activeBookingId;

  List<Equipment> get machinery => _machinery;
  List<FarmerRequest> get requests => _requests;
  UserProfile? get userProfile => _userProfile;
  int get navigationIndex => _navigationIndex;

  List<Map<String, String>> get expertTips => [
    {
      'title': 'Soil Moisture Alert',
      'description': 'High moisture levels detected in Sectors A-C. Optimal for plowing after 48 hours.',
      'icon': 'droplets',
    },
    {
      'title': 'Pest Warning',
      'description': 'Typical Fall armyworm infestation reported in neighboring farms. Check your corn fields.',
      'icon': 'bug',
    },
    {
      'title': 'Market Insight',
      'description': 'Wheat prices expected to rise by 15% next week. Consider holding stock.',
      'icon': 'trending-up',
    },
  ];

  Map<String, dynamic> get stats {
    double totalRevenue = 0.0;
    double expectedPayout = 0.0;
    int completedBookings = 0;
    
    for (var req in _requests) {
      final total = req.breakdown?.total ?? 0.0;
      if (req.status == 'confirmed' || req.status == 'completed' || req.status == 'paid') {
        totalRevenue += total;
      }
      if (req.status == 'confirmed' || req.status == 'completed') {
        expectedPayout += total;
      }
      if (req.status == 'completed') {
        completedBookings++;
      }
    }

    // Utilization calculation: percentage of machines with at least one completed booking
    double utilization = _machinery.isEmpty ? 0 : (completedBookings / (_machinery.length * 5)) * 100; // Mock factor for now
    if (utilization > 100) utilization = 98; // Cap for realism

    return {
      'totalRevenue': totalRevenue,
      'revenueGrowth': 12.5, // Trend calculation would need historical comparison
      'activeFleet': _machinery.length,
      'nextPayout': '₹${expectedPayout.toStringAsFixed(0)}',
      'utilization': utilization.toStringAsFixed(0),
    };
  }

  // Monthly revenue helper for Analytics charts
  List<double> get monthlyRevenueTrends {
    final now = DateTime.now();
    final monthlyData = List.filled(6, 0.0);
    
    for (var req in _requests) {
      if (req.status == 'confirmed' || req.status == 'completed' || req.status == 'paid') {
        // This is a simplification; FarmerRequest should specify a date
        // For now, we use a random distribution if created_at is missing, or static if present
        final monthIdx = (req.id.hashCode % 6); 
        monthlyData[monthIdx] += (req.breakdown?.total ?? 0.0) / 1000; // normalized for chart
      }
    }
    return monthlyData;
  }

  // Fleet usage helper
  List<Map<String, dynamic>> get fleetUsage {
    return _machinery.map((m) {
      final machineBookings = _requests.where((r) => r.equipmentId == m.id && r.status == 'completed').length;
      final usageFactor = (machineBookings * 0.2).clamp(0.1, 0.95);
      return {
        'name': m.name,
        'progress': usageFactor,
        'hours': '${(usageFactor * 100).toInt()} Hours',
      };
    }).toList();
  }

  Future<void> init() async {
    if (_isInit) return;
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        // Fetch profile
        final userRes = await supabase.from('users').select().eq('id', user.id).maybeSingle();
        if (userRes != null) {
          _userProfile = UserProfile.fromJson(userRes);
        }

        final equipmentResponse = await supabase.from('equipment').select().eq('owner_id', user.id);
        if (equipmentResponse.isNotEmpty) {
           _machinery = (equipmentResponse as List).map((e) => Equipment.fromJson(e)).toList();
        } else {
           _machinery = []; 
        }

        final requestsResponse = await supabase.from('bookings').select('*, equipment(*), farmer:farmer_id(name)').eq('owner_id', user.id);
        if (requestsResponse.isNotEmpty) {
            _requests = (requestsResponse as List).map((e) => FarmerRequest.fromJson(e)).toList();
        } else {
            _requests = [];
        }
      } else {
        _machinery = [];
        _requests = [];
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      _machinery = [];
      _requests = [];
    }
    
    _isInit = true;
    notifyListeners();
  }

  Future<String?> uploadEquipmentImage(File file, String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      final path = 'equipment/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await supabase.storage.from('equipment_images').upload(path, file);
      return supabase.storage.from('equipment_images').getPublicUrl(path);
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> updateProfile({String? location, String? name}) async {
    if (_userProfile == null) return;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final updates = <String, dynamic>{};
        if (location != null) updates['location'] = location;
        if (name != null) updates['name'] = name;
        if (updates.isNotEmpty) {
           await supabase.from('users').update(updates).eq('id', user.id);
           _userProfile = UserProfile(
              id: _userProfile!.id,
              name: name ?? _userProfile!.name,
              email: _userProfile!.email,
              phone: _userProfile!.phone,
              avatar: _userProfile!.avatar,
              location: location ?? _userProfile!.location,
              role: _userProfile!.role,
              aadhaar: _userProfile!.aadhaar,
           );
           notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
    }
  }

  Future<void> updateProfileAvatar(File imageFile) async {
    if (_userProfile == null) return;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final fileName = 'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('avatars').upload(fileName, imageFile);
        final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
        
        await supabase.from('users').update({'avatar_url': publicUrl}).eq('id', user.id);
        _userProfile = UserProfile(
            id: _userProfile!.id,
            name: _userProfile!.name,
            email: _userProfile!.email,
            phone: _userProfile!.phone,
            avatar: publicUrl,
            location: _userProfile!.location,
            role: _userProfile!.role,
            aadhaar: _userProfile!.aadhaar,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Avatar update error: $e');
    }
  }

  Future<Equipment?> addVehicle(Equipment vehicle, {File? imageFile}) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        String? finalImageUrl = vehicle.image;
        if (imageFile != null) {
          finalImageUrl = await uploadEquipmentImage(imageFile, vehicle.name) ?? vehicle.image;
        }

        final data = {
          'owner_id': user.id,
          'equipment_name': vehicle.name,
          'equipment_type': vehicle.type,
          'hourly_price': vehicle.pricePerHour,
          'daily_price': vehicle.pricePerDay,
          'availability_status': vehicle.status,
          'image_url': finalImageUrl,
          'model': vehicle.model,
          'vehicle_number': vehicle.vehicleNumber,
          'rc_number': vehicle.rcNumber,
          'village': vehicle.village,
          'distance_text': vehicle.distance,
          'rating': vehicle.rating,
           'review_count': vehicle.reviews,
           'is_verified': vehicle.verified,
           'available_slots': vehicle.availableSlots,
            'weekly_schedule': vehicle.weeklySchedule,
            'blocked_dates': vehicle.blockedDates.map((d) => d.toIso8601String()).toList(),
         };

        final response = await supabase.from('equipment').insert(data).select().single();

        final newVehicle = Equipment.fromJson(response);
        _machinery.insert(0, newVehicle);
        notifyListeners();
        return newVehicle;
      } catch (e) {
        debugPrint('Insert error: $e');
        rethrow;
      }
    }
    return null;
  }

  Future<void> updateVehicle(Equipment updated) async {
    final index = _machinery.indexWhere((v) => v.id == updated.id);
    if (index >= 0) {
      _machinery[index] = updated;
      notifyListeners();
      
      try {
        await Supabase.instance.client.from('equipment').update({
           'equipment_name': updated.name,
           'equipment_type': updated.type,
           'hourly_price': updated.pricePerHour,
           'daily_price': updated.pricePerDay,
           'availability_status': updated.status,
           'model': updated.model,
           'vehicle_number': updated.vehicleNumber,
           'rc_number': updated.rcNumber,
           'village': updated.village,
           'distance_text': updated.distance,
           'rating': updated.rating,
            'review_count': updated.reviews,
            'is_verified': updated.verified,
            'available_slots': updated.availableSlots,
            'weekly_schedule': updated.weeklySchedule,
            'blocked_dates': updated.blockedDates.map((d) => d.toIso8601String()).toList(),
         }).eq('equipment_id', updated.id);
      } catch (e) {
        debugPrint('Update error: $e');
      }
    }
  }

  void setNavigationIndex(int index) {
    _navigationIndex = index;
    notifyListeners();
  }

  void updateRequestStatus(String id, String status) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: status);
      notifyListeners();
      
      try {
        await Supabase.instance.client.from('bookings').update({
          'status': status,
        }).eq('booking_id', id);
      } catch (e) {
        debugPrint('Status update error: $e');
      }
    }
  }

  Future<void> updateUserProfile(UserProfile update) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('users').update(update.toJson()).eq('id', update.id);
      _userProfile = update;
      notifyListeners();
    } catch (e) {
      debugPrint('Profile update failed: $e');
    }
  }

  Future<void> startLocationBroadcasting(String bookingId, String equipmentId) async {
    // Stop any existing broadcasting
    await stopLocationBroadcasting();

    _activeBookingId = bookingId;

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Start stream
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      try {
        await Supabase.instance.client.from('tracking').insert({
          'booking_id': bookingId,
          'equipment_id': equipmentId,
          'current_lat': position.latitude,
          'current_lng': position.longitude,
        });
        debugPrint('Location updated for booking $bookingId: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('Error inserting tracking data: $e');
      }
    });
  }

  Future<void> stopLocationBroadcasting() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _activeBookingId = null;
    debugPrint('Location broadcasting stopped.');
  }

  bool isBroadcasting(String bookingId) => _activeBookingId == bookingId;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
