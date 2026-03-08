class Hospital {
  final String name;
  final String location;
  final String sector;
  final double latitude;
  final double longitude;

  Hospital({
    required this.name,
    required this.location,
    required this.sector,
    required this.latitude,
    required this.longitude,
  });
}

class HospitalService {
  static final List<Hospital> hospitals = [
    Hospital(
      name: 'Kibagabaga Level Two Teaching Hospital',
      location: 'Kibagabaga, Gasabo District, Kigali',
      sector: 'Kibagabaga',
      latitude: -1.9447,
      longitude: 30.1056,
    ),
    Hospital(
      name: 'Kacyiru District Hospital',
      location: 'Kacyiru, Gasabo District, Kigali',
      sector: 'Kacyiru',
      latitude: -1.9436,
      longitude: 30.0946,
    ),
    Hospital(
      name: 'King Faisal Hospital Rwanda',
      location: 'Kacyiru, Kigali',
      sector: 'Kacyiru',
      latitude: -1.9489,
      longitude: 30.0944,
    ),
    Hospital(
      name: 'University Teaching Hospital of Kigali (CHUK)',
      location: 'Nyamirambo, Nyarugenge District, Kigali',
      sector: 'Nyamirambo',
      latitude: -1.9706,
      longitude: 30.0588,
    ),
    Hospital(
      name: 'Rwanda Military Hospital',
      location: 'Kanombe, Kigali',
      sector: 'Kanombe',
      latitude: -1.9631,
      longitude: 30.1294,
    ),
  ];

  // Approximate sector coordinates in Kigali
  static final Map<String, Map<String, double>> sectorCoordinates = {
    'Kimironko': {'lat': -1.9403, 'lng': 30.1264},
    'Kacyiru': {'lat': -1.9436, 'lng': 30.0946},
    'Kibagabaga': {'lat': -1.9447, 'lng': 30.1056},
    'Kanombe': {'lat': -1.9631, 'lng': 30.1294},
    'Nyamirambo': {'lat': -1.9706, 'lng': 30.0588},
    'Remera': {'lat': -1.9536, 'lng': 30.1047},
    'Gikondo': {'lat': -1.9789, 'lng': 30.0878},
    'Kicukiro': {'lat': -1.9892, 'lng': 30.1089},
    'Nyarugenge': {'lat': -1.9536, 'lng': 30.0606},
    'Gasabo': {'lat': -1.9403, 'lng': 30.1264},
  };

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    
    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  static double _sin(double x) => _dartSin(x);
  static double _cos(double x) => _dartCos(x);
  static double _sqrt(double x) => _dartSqrt(x);
  static double _atan2(double y, double x) => _dartAtan2(y, x);

  static double _dartSin(double x) {
    // Taylor series approximation for sin
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _dartCos(double x) {
    // Taylor series approximation for cos
    double result = 1;
    double term = 1;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _dartSqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _dartAtan2(double y, double x) {
    if (x > 0) return _dartAtan(y / x);
    if (x < 0 && y >= 0) return _dartAtan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _dartAtan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  static double _dartAtan(double x) {
    // Taylor series approximation for atan
    if (x > 1) return 3.141592653589793 / 2 - _dartAtan(1 / x);
    if (x < -1) return -3.141592653589793 / 2 - _dartAtan(1 / x);
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x * (2 * i - 1) / (2 * i + 1);
      result += term;
    }
    return result;
  }

  static List<Map<String, dynamic>> getRecommendedHospitals(String sector) {
    final sectorCoords = sectorCoordinates[sector];
    
    if (sectorCoords == null) {
      // If sector not found, return all hospitals without distance
      return hospitals.map((h) => {
        'hospital': h,
        'distance': null,
        'isRecommended': false,
      }).toList();
    }

    final lat = sectorCoords['lat']!;
    final lng = sectorCoords['lng']!;

    // Calculate distances
    List<Map<String, dynamic>> hospitalsWithDistance = hospitals.map((h) {
      double distance = calculateDistance(lat, lng, h.latitude, h.longitude);
      return {
        'hospital': h,
        'distance': distance,
        'isRecommended': false,
      };
    }).toList();

    // Sort by distance
    hospitalsWithDistance.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double));

    // Mark the nearest as recommended
    if (hospitalsWithDistance.isNotEmpty) {
      hospitalsWithDistance[0]['isRecommended'] = true;
    }

    return hospitalsWithDistance;
  }
}
