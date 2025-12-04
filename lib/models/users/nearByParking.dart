class NearByParking {
  // Column: id (int8)
  final int id;

  // Column: created_at (timestamptz)
  final DateTime createdAt;

  // Column: name (text)
  final String name;

  // Column: distance (float8)
  final double distance;

  // Column: price_per_hour (float8)
  final double pricePerHour;

  // Column: available_spots (int8)
  final int availableSpots;

  // Column: area (text)
  final String area;

  // Column: lat (float8)
  final double lat;

  // Column: lang (float8)
  final double lang;

  // Constructor
  NearByParking({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.distance,
    required this.pricePerHour,
    required this.availableSpots,
    required this.area,
    required this.lat,
    required this.lang,
  });

  // Factory method to create a NearByParking object from a Supabase/JSON map
  factory NearByParking.fromJson(Map<String, dynamic> json) {
    return NearByParking(
      // 'id' is typically BigInt in Dart for int8, but int is usually sufficient
      // unless the number exceeds 2^53.
      id: json['id'] as int,

      // Supabase often returns timestamps as ISO 8601 strings
      createdAt: DateTime.parse(json['created_at'] as String),

      name: json['name'] as String,

      // Use (value as num).toDouble() to safely convert from dynamic or int to double
      distance: (json['distance'] as num).toDouble(),
      pricePerHour: (json['price_per_hour'] as num).toDouble(),

      availableSpots: json['available_spots'] as int,

      area: json['area'] as String,

      lat: (json['lat'] as num).toDouble(),
      lang: (json['lang'] as num).toDouble(),
    );
  }

  // Optional: Method to convert the Dart object back to a JSON map
  // (useful for INSERT/UPDATE operations)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(), // Send back as ISO string
      'name': name,
      'distance': distance,
      'price_per_hour': pricePerHour,
      'available_spots': availableSpots,
      'area': area,
      'lat': lat,
      'lang': lang,
    };
  }
}
