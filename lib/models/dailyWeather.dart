import 'package:flutter/material.dart';

class Dailyweather with ChangeNotifier {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double tempMorning;
  final double tempDay;
  final double tempEvening;
  final double tempNight;
  final String weatherCategory;
  final String condition;
  final DateTime date;
  final String precipitation;
  final double rainVolume;
  final int clouds;
  final int humidity;

  Dailyweather({
    required this.temp, 
    required this.tempMin, 
    required this.tempMax, 
    required this.tempMorning, 
    required this.tempDay, 
    required this.tempEvening, 
    required this.tempNight, 
    required this.weatherCategory, 
    required this.condition, 
    required this.date, 
    required this.precipitation,
    required this.rainVolume,
    required this.clouds, 
    required this.humidity
  });

  static Dailyweather fromDailyJson(dynamic json) {
    return Dailyweather(
      temp: (json['temp']['day']).toDouble(),
      tempMin: (json['temp']['min']).toDouble(),
      tempMax: (json['temp']['max']).toDouble(),
      tempMorning: (json['temp']['morn']).toDouble(),
      tempDay: (json['temp']['day']).toDouble(),
      tempEvening: (json['temp']['eve']).toDouble(),
      tempNight: (json['temp']['night']).toDouble(),
      weatherCategory: json['weather'][0]['main'],
      condition: json['weather'][0]['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      precipitation: ((json['pop']).toDouble() * 100).toStringAsFixed(0),
      rainVolume: json.containsKey('rain') ? (json['rain']).toDouble() : 0.0,
      clouds: json['clouds'],
      humidity: json['humidity'],
    );
  }
}
