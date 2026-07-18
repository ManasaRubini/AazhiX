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
      temperature: json["temperature"].toDouble(),
      humidity: json["humidity"].toDouble(),
      windSpeed: json["wind_speed"].toDouble(),
      waveHeight: json["wave_height"].toDouble(),
      condition: json["condition"],
    );
  }
}