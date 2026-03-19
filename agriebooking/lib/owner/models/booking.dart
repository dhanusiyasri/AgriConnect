class Booking {
  final String id;
  final String equipmentName;
  final String equipmentId;
  final String farmerName;
  final String? farmerAvatar;
  final String date;
  final String timeSlot;
  final String location;
  final String status;
  final double? earnings;
  final String? duration;
  final String? usageRemaining;
  final String? usageTotal;
  final double? lat;
  final double? lng;
  final String? speed;

  Booking({
    required this.id,
    required this.equipmentName,
    required this.equipmentId,
    required this.farmerName,
    this.farmerAvatar,
    required this.date,
    required this.timeSlot,
    required this.location,
    required this.status,
    this.earnings,
    this.duration,
    this.usageRemaining,
    this.usageTotal,
    this.lat,
    this.lng,
    this.speed,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      equipmentName: json['equipmentName'],
      equipmentId: json['equipmentId'],
      farmerName: json['farmerName'],
      farmerAvatar: json['farmerAvatar'],
      date: json['date'],
      timeSlot: json['timeSlot'],
      location: json['location'],
      status: json['status'],
      earnings: json['earnings']?.toDouble(),
      duration: json['duration'],
      usageRemaining: json['usageRemaining'],
      usageTotal: json['usageTotal'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      speed: json['speed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentName': equipmentName,
      'equipmentId': equipmentId,
      'farmerName': farmerName,
      'farmerAvatar': farmerAvatar,
      'date': date,
      'timeSlot': timeSlot,
      'location': location,
      'status': status,
      if (earnings != null) 'earnings': earnings,
      if (duration != null) 'duration': duration,
      if (usageRemaining != null) 'usageRemaining': usageRemaining,
      if (usageTotal != null) 'usageTotal': usageTotal,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (speed != null) 'speed': speed,
    };
  }
}
