// smartparking/models/users/nearByParking.dart

class NearByParking {
  final int? id;
  final String name;
  final double? distance;
  final double pricePerHour;
  final int spots;
  final double lat;
  final double lng; // Assuming 'lang' from DB is mapped to 'lng' here
  final String? address; // Field you used as 'adress' in error log
  final String? openTime;
  final String? closeTime;
  final String? descrip;
  final String? image; // Mapped as 'image' in your error log
  final bool? checkout;

  NearByParking({
    this.id,
    required this.name,
    this.distance,
    required this.pricePerHour,
    required this.spots,
    required this.lat,
    required this.lng,
    this.address,
    this.openTime,
    this.closeTime,
    this.descrip,
    this.image,
    this.checkout,
  });

  factory NearByParking.fromJson(Map<String, dynamic> json) {
    // ⚠️ CRITICAL FIX: Use the ?? operator to provide a default value (0 or 0.0)
    // when a field that you need as a non-nullable number is null in the database.

    return NearByParking(
      // Ensure id is treated as nullable or given a default
      id: json['id'] as int?,

      // Name is generally non-nullable
      name: json['name'] as String? ?? 'N/A',

      // Numeric fields: Use as double? or as int? with a default
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,

      // If 'spots' is null in the database, use 0 instead of crashing.
      spots: json['spots'] as int? ?? 0,

      // Latitude/Longitude
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng:
          (json['lang'] as num?)?.toDouble() ??
          0.0, // Assuming 'lang' is your DB column
      // String fields: Use as String? with a default
      address: json['adress'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      descrip: json['descrip'] as String?,
      image: json['image'] as String?,
      checkout: json['checkout'] as bool?,
    );
  }
}
