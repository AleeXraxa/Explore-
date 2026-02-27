import 'dart:math';

import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CityService {
  CityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> bootstrapCitiesFromListingsIfMissing() async {
    final QuerySnapshot<Map<String, dynamic>> existingCities =
        await _firestore.collection('cities').limit(1).get();
    if (existingCities.docs.isNotEmpty) {
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> listingsSnapshot =
        await _firestore.collection('listings').get();
    if (listingsSnapshot.docs.isEmpty) {
      return;
    }

    final Set<String> cityNames = listingsSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          return doc.data()['city']?.toString().trim() ?? '';
        })
        .where((String city) => city.isNotEmpty)
        .toSet();

    if (cityNames.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final String rawCity in cityNames) {
      final String city = _normalizeCityName(rawCity);
      final ({String country, String description, double latitude, double longitude})
          meta = _seedMetadataForCity(city);
      final String docId = _cityDocId(city, meta.country);
      batch.set(
        _firestore.collection('cities').doc(docId),
        <String, dynamic>{
          'name': city,
          'country': meta.country,
          'description': meta.description,
          'latitude': meta.latitude,
          'longitude': meta.longitude,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Stream<List<CityModel>> watchCities() async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _firestore.collection('cities').snapshots()) {
        final List<CityModel> cities = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
              final Map<String, dynamic> data = <String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              };
              return CityModel.fromMap(data);
            })
            .toList();

        cities.sort(
          (CityModel a, CityModel b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        yield cities;
      }
    } catch (_) {
      yield const <CityModel>[];
    }
  }

  CityModel getNearestCity({
    required List<CityModel> cities,
    required double latitude,
    required double longitude,
  }) {
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

  Future<void> createCity({
    required String name,
    required String country,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    final ({double latitude, double longitude}) resolvedLocation =
        _resolveCoordinates(
          cityName: _normalizeCityName(name),
          country: country.trim(),
          latitude: latitude,
          longitude: longitude,
        );
    final String docId = _cityDocId(name, country);
    await _firestore.collection('cities').doc(docId).set(
      <String, dynamic>{
        'name': name.trim(),
        'country': country.trim(),
        'description': description.trim(),
        'latitude': resolvedLocation.latitude,
        'longitude': resolvedLocation.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateCity({
    required String cityId,
    required String name,
    required String country,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    final ({double latitude, double longitude}) resolvedLocation =
        _resolveCoordinates(
          cityName: _normalizeCityName(name),
          country: country.trim(),
          latitude: latitude,
          longitude: longitude,
        );
    await _firestore.collection('cities').doc(cityId).update(<String, dynamic>{
      'name': name.trim(),
      'country': country.trim(),
      'description': description.trim(),
      'latitude': resolvedLocation.latitude,
      'longitude': resolvedLocation.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCity(String cityId) async {
    await _firestore.collection('cities').doc(cityId).delete();
  }

  String _cityDocId(String name, String country) {
    final String raw = '${country.toLowerCase()}_${name.toLowerCase()}';
    return raw
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  String _normalizeCityName(String input) {
    final String value = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value.isEmpty) return input.trim();
    return value
        .split(' ')
        .map((String part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }

  ({String country, String description, double latitude, double longitude})
      _seedMetadataForCity(String cityName) {
    const Map<String, ({double lat, double lng, String desc})> pakistanCities =
        <String, ({double lat, double lng, String desc})>{
      'Karachi': (
        lat: 24.8607,
        lng: 67.0011,
        desc: 'Coastal metropolis with food streets and waterfronts.',
      ),
      'Lahore': (
        lat: 31.5204,
        lng: 74.3587,
        desc: 'Cultural capital with heritage landmarks and cuisine.',
      ),
      'Islamabad': (
        lat: 33.6844,
        lng: 73.0479,
        desc: 'Planned capital city with scenic hills and wide boulevards.',
      ),
      'Rawalpindi': (
        lat: 33.5651,
        lng: 73.0169,
        desc: 'Historic gateway city neighboring the federal capital.',
      ),
      'Faisalabad': (
        lat: 31.4504,
        lng: 73.1350,
        desc: 'Industrial hub known for markets and local food.',
      ),
      'Multan': (
        lat: 30.1575,
        lng: 71.5249,
        desc: 'City of saints with rich spiritual and cultural heritage.',
      ),
      'Peshawar': (
        lat: 34.0151,
        lng: 71.5249,
        desc: 'Historic frontier city with bazaars and old architecture.',
      ),
      'Quetta': (
        lat: 30.1798,
        lng: 66.9750,
        desc: 'Mountain valley city and regional cultural center.',
      ),
    };

    final ({double lat, double lng, String desc})? known = pakistanCities[cityName];
    if (known != null) {
      return (
        country: 'Pakistan',
        description: known.desc,
        latitude: known.lat,
        longitude: known.lng,
      );
    }

    return (
      country: 'Unknown',
      description: 'Imported from existing listings. Update city profile in admin panel.',
      latitude: 0.0,
      longitude: 0.0,
    );
  }

  ({double latitude, double longitude}) _resolveCoordinates({
    required String cityName,
    required String country,
    required double? latitude,
    required double? longitude,
  }) {
    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      return (latitude: latitude, longitude: longitude);
    }

    final String normalizedCountry = country.trim().toLowerCase();
    if (normalizedCountry == 'pakistan' || normalizedCountry == 'pk') {
      final ({String country, String description, double latitude, double longitude})
          seeded = _seedMetadataForCity(cityName);
      if (seeded.latitude != 0 || seeded.longitude != 0) {
        return (latitude: seeded.latitude, longitude: seeded.longitude);
      }
    }

    return (latitude: 0.0, longitude: 0.0);
  }
}
