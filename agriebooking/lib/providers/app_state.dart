import 'package:flutter/material.dart';
import '../models/models.dart';
export '../models/models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../data/translations.dart';

class AppState extends ChangeNotifier {
  String _screen = 'splash';
  String _language = 'en';
  String _role = 'farmer';
  Equipment? _selectedEquipment;
  Booking? _selectedBooking;
  bool _isExpressBooking = false;
  String _bookingType = 'hourly';
  String? _selectedSlot;
  String _paymentOption = 'full';
  String _paymentMethod = 'UPI';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  int _usageTime = 13500;
  bool _isRegistering = false;
  bool _isDarkMode = false;
  List<Booking> _bookings = [];
  String _currentLocationName = 'Fetching location...';
  bool _isLoadingLocation = false;
  UserProfile? _userProfile;
  bool _withDriver = false;
  String _voiceBookingStage = 'idle'; // idle, searching, detailing, confirming
  bool _voiceBookingEnabled = false;
  
  // Search and Filter
  String _searchQuery = '';
  List<Equipment> _filteredEquipment = [];
  
  // Weather
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;
  
  // AI Advice
  String? _customAiAdvice;
  bool _isLoadingAiAdvice = false;
  
  // Voice Search & Guidance
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';
  int _guidedStep = 0; // 0: machine, 1: hours, 2: driver, 3: confirm

  // Notifications
  List<AppNotification> _notifications = [];
  RealtimeChannel? _notifChannel;
  
  AppState() {
    _requestAppPermissions();
    _initTts();
    _fetchSupabaseData();
    _setupRealtime();
    _setupNotificationRealtime();
    _setupEquipmentRealtime();
  }

  Future<void> _requestAppPermissions() async {
    await [
      Permission.location,
      Permission.microphone,
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();
  }

  void _initTts() async {
    await _tts.setLanguage(_language == 'ta' ? 'ta-IN' : 'en-IN');
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  void _setupRealtime() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    supabase
        .from('bookings')
        .stream(primaryKey: ['booking_id'])
        .eq('farmer_id', user.id)
        .listen((data) {
          _bookings = data.map((json) => Booking.fromJson(json)).toList();
          notifyListeners();
        });
  }

  void _setupNotificationRealtime() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _notifChannel = supabase
        .channel('public:notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final newNotif = AppNotification.fromJson(payload.newRecord);
            _notifications.insert(0, newNotif);
            notifyListeners();
          },
        )
        .subscribe();

    // Initial fetch
    _fetchNotifications();
  }
  
  void _setupEquipmentRealtime() {
    final supabase = Supabase.instance.client;
    supabase
        .channel('public:equipment')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'equipment',
          callback: (payload) {
             // Re-fetch all or update local list selectively?
             // Re-fetching is safer for complex joins (owner name etc)
             _fetchSupabaseData();
          },
        )
        .subscribe();
  }

  Future<void> _fetchNotifications() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final res = await supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);
      _notifications = (res as List).map((e) => AppNotification.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Notification fetch error: $e');
    }
  }

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      try {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('notification_id', id);
      } catch (e) {
        debugPrint('Mark read error: $e');
      }
    }
  }

  void markAllNotificationsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id);
      }
    } catch (e) {
      debugPrint('Mark all read error: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    String? bookingId,
  }) async {
    try {
      await Supabase.instance.client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'booking_id': bookingId,
      });
    } catch (e) {
      debugPrint('Create notification error: $e');
    }
  }

  Future<void> _fetchSupabaseData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Fetch user profile
        final userRes = await supabase.from('users').select().eq('id', user.id).maybeSingle();
        if (userRes != null) {
          _userProfile = UserProfile.fromJson(userRes);
        } else {
          // Fallback or init profile
          _userProfile = UserProfile(id: user.id, name: 'Farmer', phone: '+91 98765 43210', email: user.email ?? '');
        }

        // Fetch farmer's bookings
        final bRes = await supabase.from('bookings').select('*, equipment(*, users:owner_id(name))').eq('farmer_id', user.id);
        if (bRes.isNotEmpty) {
          _bookings = (bRes as List)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _bookings = [];
        }
      }

      // Fetch available equipment
      final eqRes = await supabase.from('equipment').select('*, users:owner_id(name)');
      if (eqRes.isNotEmpty) {
        _filteredEquipment = (eqRes as List)
            .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
         _filteredEquipment = [];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
      _filteredEquipment = [];
      _bookings = [];
      notifyListeners();
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

  String get screen => _screen;
  String get language => _language;
  String get role => _role;
  Equipment? get selectedEquipment => _selectedEquipment;
  Booking? get selectedBooking => _selectedBooking;
  bool get isExpressBooking => _isExpressBooking;
  String get bookingType => _bookingType;
  String? get selectedSlot => _selectedSlot;
  String get paymentOption => _paymentOption;
  String get paymentMethod => _paymentMethod;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  int get usageTime => _usageTime;
  bool get isRegistering => _isRegistering;
  bool get isDarkMode => _isDarkMode;
  List<Booking> get bookings => _bookings;
  String get currentLocationName => _currentLocationName;
  bool get isLoadingLocation => _isLoadingLocation;
  UserProfile? get userProfile => _userProfile;
  bool get withDriver => _withDriver;
  String get voiceBookingStage => _voiceBookingStage;
  bool get voiceBookingEnabled => _voiceBookingEnabled;
  
  String get searchQuery => _searchQuery;
  List<Equipment> get filteredEquipment => _filteredEquipment;
  
  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoadingWeather => _isLoadingWeather;
  
  String? get customAiAdvice => _customAiAdvice;
  bool get isLoadingAiAdvice => _isLoadingAiAdvice;
  
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  void setScreen(String screen) {
    _screen = screen;
    if (screen == 'dashboard') {
      _searchQuery = '';
      _fetchSupabaseData(); // Re-fetch to guarantee it is fresh
    }
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    _tts.setLanguage(lang == 'ta' ? 'ta-IN' : (lang == 'hi' ? 'hi-IN' : 'en-IN'));
    notifyListeners();
  }

  String translate(String key) {
    return translations[_language]?[key] ?? translations['en']?[key] ?? key;
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void setSelectedEquipment(Equipment eq) {
    _selectedEquipment = eq;
    notifyListeners();
  }

  void setSelectedBooking(Booking? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void setIsExpressBooking(bool val) {
    _isExpressBooking = val;
    notifyListeners();
  }

  void setBookingType(String type) {
    _bookingType = type;
    notifyListeners();
  }

  void setSelectedSlot(String? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }


  void setPaymentOption(String option) {
    _paymentOption = option;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotificationsEnabled(bool val) {
    _notificationsEnabled = val;
    notifyListeners();
  }

  void setLocationEnabled(bool val) {
    _locationEnabled = val;
    notifyListeners();
  }

  void setUsageTime(int time) {
    _usageTime = time;
    notifyListeners();
  }

  void setIsRegistering(bool val) {
    _isRegistering = val;
    notifyListeners();
  }

  void setDarkMode(bool val) {
    _isDarkMode = val;
    notifyListeners();
  }

  void addBooking(Booking booking) async {
    _bookings.insert(0, booking);
    _searchQuery = ''; // Reset search on new booking
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        final eqData = await supabase.from('equipment').select('owner_id').eq('equipment_id', booking.equipmentId).maybeSingle();
        
        final inserted = await supabase.from('bookings').insert({
          'farmer_id': user.id,
          'equipment_id': booking.equipmentId,
          'owner_id': eqData?['owner_id'],
          'hours': _bookingType == 'hourly' ? _usageTime : (_usageTime * 24),
          'driver_required': _withDriver,
          'hourly_price': _bookingType == 'hourly' 
              ? (booking.amount / (_usageTime > 0 ? _usageTime : 1)).round()
              : (booking.amount / (_usageTime * 24 > 0 ? _usageTime * 24 : 1)).round(), 
          'driver_price': _withDriver ? 200 : 0,
          'total_price': booking.amount,
          'status': 'REQUESTED',
          'start_time': booking.startTime,
          'end_time': booking.endTime,
          'booking_date': booking.date,
        }).select('booking_id').maybeSingle();

        // Send a confirmation notification to the farmer
        final dbBookingId = inserted?['booking_id'] as String?;
        await createNotification(
          userId: user.id,
          title: '✅ Booking Requested!',
          body: 'Your booking for ${booking.equipmentName} on ${booking.date} has been submitted. Awaiting owner confirmation.',
          type: 'booking',
          bookingId: dbBookingId,
        );
      }
    } catch (e) {
      debugPrint('Booking insert error: $e');
    }
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
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
           _userProfile = _userProfile!.copyWith(
              name: name ?? _userProfile!.name,
              location: location ?? _userProfile!.location,
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
        final fileName = 'farmer_avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('avatars').upload(fileName, imageFile);
        final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
        
        await supabase.from('users').update({'avatar_url': publicUrl}).eq('id', user.id);
        _userProfile = _userProfile!.copyWith(avatar: publicUrl);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Avatar update error: $e');
    }
  }

  void setWithDriver(bool val) {
    _withDriver = val;
    notifyListeners();
  }

  void setVoiceBookingStage(String stage) {
    _voiceBookingStage = stage;
    notifyListeners();
  }

  void setVoiceBookingEnabled(bool val) {
    _voiceBookingEnabled = val;
    if (!val) {
      _voiceBookingStage = 'idle';
      _guidedStep = 0;
      if (_isListening) {
        _isListening = false;
        _speech.stop();
      }
      _tts.stop();
    } else {
      _voiceBookingStage = 'searching';
      _guidedStep = 0;
      speak("Welcome to AgriConnect Voice Booking. Which machine do you want to rent?");
      Future.delayed(const Duration(seconds: 3), () => toggleListening());
    }
    notifyListeners();
  }

  void extendBooking(int hours, int minutes) {
    // In a real app, this would update the booking in DB
    final extensionStr = "${hours > 0 ? '$hours hrs ' : ''}${minutes > 0 ? '$minutes mins' : ''}";
    print("Booking extended by: $extensionStr");
    // Optionally update local bookings if needed
    notifyListeners();
  }

  // Search Logic
  void setSearchQuery(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      await _fetchSupabaseData();
    } else {
      try {
        final supabase = Supabase.instance.client;
        final eqRes = await supabase.from('equipment')
            .select('*, users:owner_id(name)')
            .ilike('equipment_name', '%$query%');
            
        _filteredEquipment = (eqRes as List)
            .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _filteredEquipment = [];
        debugPrint('Search failed: $e');
      }
    }
    notifyListeners();
  }

  // Weather Logic
  Future<void> fetchWeather() async {
    _isLoadingWeather = true;
    notifyListeners();
    
    // Simulate API call for now (In real app, use OpenWeatherMap API)
    try {
      // Mock weather response
      await Future.delayed(const Duration(seconds: 1));
      _weatherData = {
        'temp': 28,
        'condition': 'Sunny',
        'hum': 65,
        'wind': '12 km/h'
      };
    } catch (e) {
      _weatherData = null;
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  // AI Recommendation Logic
  Future<void> generateAiRecommendation(String crop, String size, String task) async {
    _isLoadingAiAdvice = true;
    notifyListeners();

    // Simulated AI processing delay
    await Future.delayed(const Duration(seconds: 1));

    String advice = "";
    if (task == 'Harvesting' && crop == 'Rice') {
      advice = "For harvesting $size of rice, we recommend a Combine Harvester. Current humidity is ${_weatherData?['hum'] ?? 62}%, which is ideal for dry harvesting. Aim to finish before any sudden showers predicted for next week.";
    } else if (task == 'Land Prep') {
      advice = "Land preparation for $crop on $size requires a high-torque tractor with a rotavator. Since the soil temperature is elevated (${_weatherData?['temp'] ?? 32}°C), ensure deep ploughing to moisture retention.";
    } else if (task == 'Spraying') {
      advice = "Based on the wind speed of ${_weatherData?['wind'] ?? '14km/h'}, spraying should be done in the early morning to avoid drift. A tractor-mounted boom sprayer is most efficient for $size.";
    } else {
      advice = "For $task of $crop on a farm of $size, a standard 45HP tractor with appropriate implements is recommended. Ensure the equipment is verified for $currentLocationName conditions.";
    }

    _customAiAdvice = advice;
    _isLoadingAiAdvice = false;
    notifyListeners();
  }

  // Voice Search Logic
  Future<void> toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _isListening = true;
        notifyListeners();
        _speech.listen(
          onResult: (val) {
            _lastWords = val.recognizedWords;
            if (val.finalResult) {
              _processVoiceCommand(_lastWords);
              _isListening = false;
              notifyListeners();
            }
          },
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  void _processVoiceCommand(String command) {
    final lowerCmd = command.toLowerCase();
    
    if (!_voiceBookingEnabled) {
      // Simple search if guided mode is off
      final equipmentTypes = ['tractor', 'rotavator', 'harvester', 'sprayer', 'plough'];
      for (var type in equipmentTypes) {
        if (lowerCmd.contains(type)) {
          setSearchQuery(type);
          return;
        }
      }
      return;
    }

    // Guided Mode Logic
    switch (_guidedStep) {
      case 0: // Machine selection
        final equipmentTypes = ['tractor', 'rotavator', 'harvester', 'sprayer', 'plough'];
        for (var type in equipmentTypes) {
          if (lowerCmd.contains(type)) {
            setSearchQuery(type);
            _guidedStep = 1;
            speak("Found $type. For how many hours do you need it?");
            Future.delayed(const Duration(seconds: 3), () => toggleListening());
            return;
          }
        if (_voiceBookingEnabled) {
          Future.delayed(const Duration(seconds: 1), () => toggleListening());
        }
      }
      return;
    }

    // Stage: Confirming ("book now", "confirm", "proceed")
    if (_voiceBookingStage == 'detailing' && (lowerCmd.contains('confirm') || lowerCmd.contains('book') || lowerCmd.contains('proceed'))) {
      setScreen('booking-details');
      _voiceBookingStage = 'confirming';
      notifyListeners();
      
      if (_voiceBookingEnabled) {
        Future.delayed(const Duration(seconds: 1), () => toggleListening());
      }
      return;
    }

    // Stage: Payment/Complete ("pay now", "checkout", "final")
    if (_voiceBookingStage == 'confirming' && (lowerCmd.contains('pay') || lowerCmd.contains('checkout') || lowerCmd.contains('final'))) {
      setScreen('checkout');
      _voiceBookingStage = 'idle'; // Reset after flow
      notifyListeners();
      return;
    }

    // Generic "Next" or "Continue" if enabled
    if (_voiceBookingEnabled && (lowerCmd.contains('next') || lowerCmd.contains('continue'))) {
       if (_voiceBookingStage == 'searching' && filteredEquipment.isNotEmpty) {
         setSelectedEquipment(filteredEquipment.first);
         setScreen('equipment-details');
         _voiceBookingStage = 'detailing';
       } else if (_voiceBookingStage == 'detailing') {
         setScreen('booking-details');
         _voiceBookingStage = 'confirming';
       } else if (_voiceBookingStage == 'confirming') {
         setScreen('checkout');
         _voiceBookingStage = 'idle';
       }
       notifyListeners();
       if (_voiceBookingEnabled && _voiceBookingStage != 'idle') {
          Future.delayed(const Duration(seconds: 1), () => toggleListening());
       }
       return;
    }

    // If enabled and no match, keep listening or prompt?
    if (_voiceBookingEnabled) {
       // Keep listening if enabled to maintain the "only voice inputs" promise
       Future.delayed(const Duration(seconds: 2), () => toggleListening());
    }
  }

  Future<void> launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchSms(String phoneNumber) async {
    final Uri url = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> fetchLocation() async {
    _isLoadingLocation = true;
    _currentLocationName = 'Fetching location...';
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentLocationName = 'Tap to enable GPS';
        _isLoadingLocation = false;
        notifyListeners();
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentLocationName = 'Location permission denied';
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentLocationName = 'Location permission permanently denied';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subLocality ?? 'Unknown City';
        String state = place.administrativeArea ?? '';
        _currentLocationName = state.isNotEmpty ? '$city, $state' : city;
      } else {
        _currentLocationName = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }
    } catch (e) {
      _currentLocationName = 'Error fetching location';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }
}
