import 'dart:math';
import 'package:latlong2/latlong.dart';

class ImblService {
  // Key IMBL Boundary Waypoints (Palk Strait & Gulf of Mannar)
  static final List<LatLng> imblPoints = [
    const LatLng(10.0833, 79.8667), // Point 1 (Palk Bay)
    const LatLng(9.9500, 79.6667),  // Point 2
    const LatLng(9.6667, 79.5333),  // Point 3 (Kachchatheevu / Rameswaram sector)
    const LatLng(9.3333, 79.3667),  // Point 4
    const LatLng(9.1000, 79.2167),  // Point 5 (Gulf of Mannar)
  ];

  /// Calculates the shortest distance in Nautical Miles (NM) from boat to IMBL line
  static double getDistanceToIMBL(double boatLat, double boatLon) {
    LatLng boatPos = LatLng(boatLat, boatLon);
    double minDistanceKm = double.infinity;

    for (int i = 0; i < imblPoints.length - 1; i++) {
      double dist = _distanceToSegment(boatPos, imblPoints[i], imblPoints[i + 1]);
      if (dist < minDistanceKm) {
        minDistanceKm = dist;
      }
    }

    // Convert kilometers to Nautical Miles (1 NM = 1.852 km)
    return minDistanceKm / 1.852;
  }

  /// Calculates bearing angle in degrees from start point to destination
  static double calculateBearing(LatLng start, LatLng end) {
    double startLat = _degreesToRadians(start.latitude);
    double startLng = _degreesToRadians(start.longitude);
    double endLat = _degreesToRadians(end.latitude);
    double endLng = _degreesToRadians(end.longitude);

    double dLng = endLng - startLng;

    double y = sin(dLng) * cos(endLat);
    double x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    double bearing = atan2(y, x);
    bearing = _radiansToDegrees(bearing);
    return (bearing + 360) % 360;
  }

  static String getBearingText(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return "${bearing.toStringAsFixed(0)}° N";
    if (bearing >= 22.5 && bearing < 67.5) return "${bearing.toStringAsFixed(0)}° NE";
    if (bearing >= 67.5 && bearing < 112.5) return "${bearing.toStringAsFixed(0)}° E";
    if (bearing >= 112.5 && bearing < 157.5) return "${bearing.toStringAsFixed(0)}° SE";
    if (bearing >= 157.5 && bearing < 202.5) return "${bearing.toStringAsFixed(0)}° S";
    if (bearing >= 202.5 && bearing < 247.5) return "${bearing.toStringAsFixed(0)}° SW";
    if (bearing >= 247.5 && bearing < 292.5) return "${bearing.toStringAsFixed(0)}° W";
    return "${bearing.toStringAsFixed(0)}° NW";
  }

  static double _distanceToSegment(LatLng p, LatLng v, LatLng w) {
    const Distance distance = Distance();
    double l2 = pow(distance.as(LengthUnit.Kilometer, v, w), 2).toDouble();
    if (l2 == 0) return distance.as(LengthUnit.Kilometer, p, v);
    
    double t = ((p.latitude - v.latitude) * (w.latitude - v.latitude) + (p.longitude - v.longitude) * (w.longitude - v.longitude)) / l2;
    t = max(0, min(1, t));
    
    LatLng projection = LatLng(
      v.latitude + t * (w.latitude - v.latitude),
      v.longitude + t * (w.longitude - v.longitude),
    );
    return distance.as(LengthUnit.Kilometer, p, projection);
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;
  static double _radiansToDegrees(double radians) => radians * 180 / pi;
}
