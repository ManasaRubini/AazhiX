class WeatherModel {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double waveHeight;
  final String condition;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.waveHeight,
    required this.condition,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json["temperature"] as num?)?.toDouble() ?? 28.0,
      humidity: (json["humidity"] as num?)?.toDouble() ?? 75.0,
      windSpeed: (json["wind_speed"] as num?)?.toDouble() ?? 15.0,
      waveHeight: (json["wave_height"] as num?)?.toDouble() ?? 1.2,
      condition: json["condition"]?.toString() ?? "Partly Cloudy",
    );
  }
}