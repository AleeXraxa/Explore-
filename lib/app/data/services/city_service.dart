import 'dart:math';

import 'package:city_guide_app/app/data/models/city_model.dart';

class CityService {
  const CityService();

  List<CityModel> getAvailableCities() => const <CityModel>[
    CityModel(
      name: 'Karachi',
      country: 'Pakistan',
      description: 'Coastal city known for food streets and waterfronts.',
      latitude: 24.8607,
      longitude: 67.0011,
    ),
    CityModel(
      name: 'Lahore',
      country: 'Pakistan',
      description: 'Cultural hub with heritage architecture and gardens.',
      latitude: 31.5204,
      longitude: 74.3587,
    ),
    CityModel(
      name: 'Islamabad',
      country: 'Pakistan',
      description: 'Planned capital city with scenic hills and clean layout.',
      latitude: 33.6844,
      longitude: 73.0479,
    ),
    CityModel(
      name: 'Dubai',
      country: 'UAE',
      description: 'Modern skyline, luxury shopping, and waterfront leisure.',
      latitude: 25.2048,
      longitude: 55.2708,
    ),
  ];

  CityModel getDefaultCity() => getAvailableCities().first;

  CityModel getNearestCity({
    required double latitude,
    required double longitude,
  }) {
    final List<CityModel> cities = getAvailableCities();
    CityModel nearest = cities.first;
    double minDistance = _distanceInKm(
      latitude,
      longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (final CityModel city in cities.skip(1)) {
      final double distance = _distanceInKm(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }
    return nearest;
  }

  double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * (pi / 180);
}
