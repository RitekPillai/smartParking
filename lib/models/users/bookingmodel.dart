// File: lib/models/booking.dart (Revised)

import 'package:supabase_flutter/supabase_flutter.dart';

class Booking {
  final int id;
  final int parkingId;
  final String userId;

  // NEW FIELDS
  final String?
  userName; // User name (nullable in DB based on standard practice)
  final String numberPlate; // Vehicle identifier (set to NOT NULL)

  final DateTime startTime;
  final DateTime endTime;
  final double? durationHours;
  final double? pricePerHour;
  final double? totalAmount;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.parkingId,
    required this.userId,
    // Add new fields to the constructor
    this.userName,
    required this.numberPlate,

    required this.startTime,
    required this.endTime,
    this.durationHours,
    this.pricePerHour,
    this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDateTime(String? timestamp) {
      if (timestamp == null) return null;
      return DateTime.tryParse(timestamp)?.toLocal();
    }

    return Booking(
      id: json['id'] as int,
      parkingId: json['parking_id'] as int,
      userId: json['user_id'] as String,

      // MAPPING NEW FIELDS
      userName: json['user_name'] as String?,
      numberPlate: json['number_plate'] as String, // Must be present

      startTime: safeParseDateTime(json['start_time'] as String?)!,
      endTime: safeParseDateTime(json['end_time'] as String?)!,

      durationHours: (json['duration_hours'] as num?)?.toDouble(),
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),

      status: json['status'] as String? ?? 'pending',
      createdAt: safeParseDateTime(json['created_at'] as String?)!,
    );
  }

  // --- Utility method to prepare data for INSERT/UPDATE ---
  Map<String, dynamic> toJson() {
    return {
      'parking_id': parkingId,
      'user_id': userId,

      // INCLUDE NEW FIELDS FOR INSERT
      'user_name': userName,
      'number_plate': numberPlate,

      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'duration_hours': durationHours,
      'price_per_hour': pricePerHour,
      'total_amount': totalAmount,
      'status': status,
    };
  }
}
