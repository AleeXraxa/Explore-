class CityModel {
  const CityModel({
    required this.name,
    required this.country,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final String description;
  final double latitude;
  final double longitude;

  factory CityModel.fromMap(Map<String, dynamic> map) {
    return CityModel(
      name: (map['name'] as String?)?.trim() ?? 'Unknown City',
      country: (map['country'] as String?)?.trim() ?? 'Unknown Country',
      description:
          (map['description'] as String?)?.trim() ?? 'No description available.',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
