import 'package:flutter/material.dart';

class HourlyWeather with ChangeNotifier {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final double windGust;
  final int clouds;
  final String weatherCategory;
  final String condition;
  final DateTime date;
  final String precipitation;
  final double rainVolume;
  final int visibility;

  HourlyWeather({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windGust,
    required this.clouds,
    required this.weatherCategory,
    required this.condition,
    required this.date,
    required this.precipitation,
    required this.rainVolume,
    required this.visibility,
  });

  static HourlyWeather fromJson(dynamic json) {
    return HourlyWeather(
      temp: (json['main']['temp']).toDouble(),
      feelsLike: (json['main']['feels_like']).toDouble(),
      tempMin: (json['main']['temp_min']).toDouble(),
      tempMax: (json['main']['temp_max']).toDouble(),
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed']).toDouble(),
      windGust: json['wind'].containsKey('gust') ? (json['wind']['gust']).toDouble() : 0.0,
      clouds: json['clouds']['all'],
      weatherCategory: json['weather'][0]['main'],
      condition: json['weather'][0]['description'],
      date: DateTime.parse(json['dt_txt']),
      precipitation: ((json['pop']).toDouble() * 100).toStringAsFixed(0),
      rainVolume: json.containsKey('rain') && json['rain'].containsKey('1h')
          ? (json['rain']['1h']).toDouble()
          : 0.0,
      visibility: json['visibility'],
    );
  }
}
