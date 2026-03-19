// Unified data models for the Digi Farm app
class Owner {
  final String name;
  final String experience;
  final double rating;

  const Owner({
    required this.name,
    required this.experience,
    required this.rating,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      name: json['name'] ?? 'Owner Name',
      experience: '3 years',
      rating: 4.5,
    );
  }
}

class Equipment {
  final String id;
  final String name;
  final String model;
  final String type;
  final String image;
  final String location;
  final String status;
  final double? fuelLevel;
  final double? batteryLevel;
  final String? nextService;
  final String? lastUsed;
  final int pricePerHour;
  final int pricePerDay;
  final double rating;
  final int reviews;
  final String village;
  final String distance;
  final String vehicleNumber;
  final String rcNumber;
  final bool verified;
  final Owner owner;
  final List<String> availableSlots;
  final Map<String, String> weeklySchedule;
  final List<DateTime> blockedDates;

  const Equipment({
    required this.id,
    required this.name,
    this.model = 'Standard',
    required this.type,
    required this.image,
    this.location = 'Local Farm',
    this.status = 'available',
    this.fuelLevel = 80.0,
    this.batteryLevel = 100.0,
    this.nextService = '10d',
    this.lastUsed,
    required this.pricePerHour,
    required this.pricePerDay,
    this.rating = 4.8,
    this.reviews = 120,
    this.village = 'Local Village',
    this.distance = '2.5 km',
    this.vehicleNumber = 'KA 01 AB 1234',
    this.rcNumber = 'RC12345678',
    this.verified = true,
    this.availableSlots = const ['06:00 - 09:00', '09:00 - 12:00', '12:00 - 15:00', '15:00 - 18:00', '18:00 - 21:00'],
    this.weeklySchedule = const {
      'Monday': '08:00 AM - 06:00 PM',
      'Tuesday': '08:00 AM - 06:00 PM',
      'Wednesday': '08:00 AM - 06:00 PM',
      'Thursday': '08:00 AM - 06:00 PM',
      'Friday': '08:00 AM - 06:00 PM',
      'Saturday': '09:00 AM - 01:00 PM',
      'Sunday': 'Closed',
    },
    this.blockedDates = const [],
    this.owner = const Owner(name: 'Equipment Owner', experience: '3 years', rating: 4.8),
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['equipment_id'] ?? json['id'],
      name: json['equipment_name'] ?? json['name'],
      model: json['model'] ?? 'Standard',
      type: json['equipment_type'] ?? json['type'],
      image: json['image_url'] ?? json['image'] ?? 'https://picsum.photos/seed/${json['equipment_id'] ?? json['id']}/400/300',
      location: json['location'] ?? 'Local Farm',
      status: json['availability_status'] ?? json['status'] ?? 'available',
      fuelLevel: json['fuelLevel']?.toDouble() ?? 80.0,
      batteryLevel: json['batteryLevel']?.toDouble() ?? 100.0,
      nextService: json['nextService'] ?? '10d',
      lastUsed: json['lastUsed'],
      pricePerHour: (json['hourly_price'] as num?)?.toInt() ?? 0,
      pricePerDay: (json['daily_price'] as num?)?.toInt() ?? ((json['hourly_price'] as num?)?.toInt() ?? 0) * 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviews: (json['review_count'] as num?)?.toInt() ?? 0,
      village: json['village'] ?? json['location'] ?? 'Local Village',
      distance: json['distance_text'] ?? '2.5 km',
      vehicleNumber: json['vehicle_number'] ?? 'KA 01 AB 1234',
      rcNumber: json['rc_number'] ?? 'RC12345678',
      verified: json['is_verified'] ?? true,
      availableSlots: (json['available_slots'] as List?)?.map((e) => e.toString()).toList() ?? const ['06:00 - 09:00', '09:00 - 12:00', '12:00 - 15:00', '15:00 - 18:00', '18:00 - 21:00'],
      weeklySchedule: json['weekly_schedule'] != null ? Map<String, String>.from(json['weekly_schedule']) : const {
        'Monday': '08:00 AM - 06:00 PM',
        'Tuesday': '08:00 AM - 06:00 PM',
        'Wednesday': '08:00 AM - 06:00 PM',
        'Thursday': '08:00 AM - 06:00 PM',
        'Friday': '08:00 AM - 06:00 PM',
        'Saturday': '09:00 AM - 01:00 PM',
        'Sunday': 'Closed',
      },
      blockedDates: (json['blocked_dates'] as List?)?.map((e) => DateTime.parse(e.toString())).toList() ?? const [],
      owner: json['users'] != null 
          ? Owner.fromJson(json['users']) 
          : const Owner(name: 'Equipment Owner', experience: '3 years', rating: 4.8),
    );
  }

  Equipment copyWith({
    String? id,
    String? name,
    String? model,
    String? type,
    String? image,
    String? location,
    String? status,
    double? fuelLevel,
    double? batteryLevel,
    String? nextService,
    String? lastUsed,
    int? pricePerHour,
    int? pricePerDay,
    double? rating,
    int? reviews,
    String? village,
    String? distance,
    String? vehicleNumber,
    String? rcNumber,
    bool? verified,
    List<String>? availableSlots,
    Map<String, String>? weeklySchedule,
    List<DateTime>? blockedDates,
    Owner? owner,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      type: type ?? this.type,
      image: image ?? this.image,
      location: location ?? this.location,
      status: status ?? this.status,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      nextService: nextService ?? this.nextService,
      lastUsed: lastUsed ?? this.lastUsed,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      village: village ?? this.village,
      distance: distance ?? this.distance,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      verified: verified ?? this.verified,
      availableSlots: availableSlots ?? this.availableSlots,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      blockedDates: blockedDates ?? this.blockedDates,
      owner: owner ?? this.owner,
    );
  }
}

class Booking {
  final String id;
  final String equipmentId;
  final String equipmentName;
  String status;
  final String startTime;
  final String endTime;
  final String date;
  final int amount;
  final String village;
  final String ownerName;
  final String image;

  Booking({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.amount,
    required this.village,
    required this.ownerName,
    required this.image,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? eq = json['equipment'] as Map<String, dynamic>?;
    return Booking(
      id: json['booking_id'] ?? '',
      equipmentId: json['equipment_id'] ?? '',
      equipmentName: eq?['equipment_name'] ?? 'Equipment',
      status: json['status'] ?? 'Requested',
      startTime: json['start_time'] ?? '09:00 AM',
      endTime: json['end_time'] ?? '12:00 PM',
      date: json['booking_date'] ?? '20 Oct 2023',
      amount: (json['total_price'] as num?)?.toInt() ?? 0,
      village: eq?['village'] ?? 'Local Village',
      ownerName: eq?['users']?['name'] ?? 'Owner',
      image: eq?['image_url'] ?? 'https://picsum.photos/seed/tractor/400/300',
    );
  }
}
class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? aadhaar;
  final String? role;
  final String? avatar;
  final String? location;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.aadhaar,
    this.role,
    this.avatar,
    this.location,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '+91 98765 43210',
      email: json['email'] ?? '',
      aadhaar: json['aadhaar_number'],
      role: json['role'],
      avatar: json['avatar_url'],
      location: json['location'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? aadhaar,
    String? role,
    String? avatar,
    String? location,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      aadhaar: aadhaar ?? this.aadhaar,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'aadhaar_number': aadhaar,
      'role': role,
      'avatar_url': avatar,
      'location': location,
    };
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // booking, payment, ai, tracking, insurance, general
  final bool isRead;
  final String? bookingId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.bookingId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['notification_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['is_read'] ?? false,
      bookingId: json['booking_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      bookingId: bookingId,
      createdAt: createdAt,
    );
  }
}

