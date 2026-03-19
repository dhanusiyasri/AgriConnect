class RequestBreakdown {
  final double rentalFee;
  final double insurance;
  final double platformFee;
  final double total;

  RequestBreakdown({
    required this.rentalFee,
    required this.insurance,
    required this.platformFee,
    required this.total,
  });

  factory RequestBreakdown.fromJson(Map<String, dynamic> json) {
    return RequestBreakdown(
      rentalFee: json['rentalFee']?.toDouble() ?? 0.0,
      insurance: json['insurance']?.toDouble() ?? 0.0,
      platformFee: json['platformFee']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rentalFee': rentalFee,
      'insurance': insurance,
      'platformFee': platformFee,
      'total': total,
    };
  }
}

class FarmerRequest {
  final String id;
  final String farmerName;
  final String? farmerAvatar;
  final String farmerType;
  final double rating;
  final int reviewsCount;
  final String memberSince;
  final String location;
  final String equipmentId;
  final String equipmentName;
  final String duration;
  final String distance;
  final String? note;
  final bool? isUrgent;
  final String? status;
  final bool? requiresDriver;
  final RequestBreakdown? breakdown;

  FarmerRequest({
    required this.id,
    required this.farmerName,
    this.farmerAvatar,
    required this.farmerType,
    required this.rating,
    required this.reviewsCount,
    required this.memberSince,
    required this.location,
    required this.equipmentId,
    required this.equipmentName,
    required this.duration,
    required this.distance,
    this.note,
    this.isUrgent,
    this.status,
    this.requiresDriver,
    this.breakdown,
  });

  factory FarmerRequest.fromJson(Map<String, dynamic> json) {
    return FarmerRequest(
      id: json['booking_id'] ?? json['id'],
      farmerName: json['farmer']?['name'] ?? json['farmerName'] ?? 'Unknown Farmer',
      farmerAvatar: json['farmerAvatar'] ?? 'https://picsum.photos/seed/${json['booking_id'] ?? json['id']}/400/300',
      farmerType: json['farmerType'] ?? 'Professional Farmer',
      rating: json['rating']?.toDouble() ?? 4.8,
      reviewsCount: json['reviewsCount']?.toInt() ?? 12,
      memberSince: json['memberSince'] ?? '2023',
      location: json['location'] ?? 'Local Village',
      equipmentId: json['equipment_id']?.toString() ?? '',
      equipmentName: json['equipment']?['equipment_name'] ?? json['equipmentName'] ?? 'Equipment',
      duration: json['hours'] != null ? '${json['hours']} Hours' : json['duration'] ?? 'Unknown duration',
      distance: json['distance'] ?? '2.4 miles away',
      note: json['note'],
      isUrgent: json['isUrgent'],
      status: json['status'] ?? 'pending',
      requiresDriver: json['driver_required'] ?? json['requiresDriver'] ?? false,
      breakdown: json['breakdown'] != null 
          ? RequestBreakdown.fromJson(json['breakdown']) 
          : RequestBreakdown(
              rentalFee: (json['hourly_price'] as num?)?.toDouble() ?? 0.0,
              insurance: 0.0,
              platformFee: 0.0,
              total: (json['total_price'] as num?)?.toDouble() ?? 0.0,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerName': farmerName,
      'farmerAvatar': farmerAvatar,
      'farmerType': farmerType,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'memberSince': memberSince,
      'location': location,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'duration': duration,
      'distance': distance,
      if (note != null) 'note': note,
      if (isUrgent != null) 'isUrgent': isUrgent,
      if (status != null) 'status': status,
      if (requiresDriver != null) 'requiresDriver': requiresDriver,
      if (breakdown != null) 'breakdown': breakdown!.toJson(),
    };
  }

  FarmerRequest copyWith({
    String? id,
    String? farmerName,
    String? farmerAvatar,
    String? farmerType,
    double? rating,
    int? reviewsCount,
    String? memberSince,
    String? location,
    String? equipmentId,
    String? equipmentName,
    String? duration,
    String? distance,
    String? note,
    bool? isUrgent,
    String? status,
    bool? requiresDriver,
    RequestBreakdown? breakdown,
  }) {
    return FarmerRequest(
      id: id ?? this.id,
      farmerName: farmerName ?? this.farmerName,
      farmerAvatar: farmerAvatar ?? this.farmerAvatar,
      farmerType: farmerType ?? this.farmerType,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      memberSince: memberSince ?? this.memberSince,
      location: location ?? this.location,
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      note: note ?? this.note,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      requiresDriver: requiresDriver ?? this.requiresDriver,
      breakdown: breakdown ?? this.breakdown,
    );
  }
}
