import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/extentisions.dart';
import 'package:flutter_application_1/models/dailyWeather.dart';
import 'package:flutter_application_1/provider/weatherProvider.dart';
import 'package:flutter_application_1/Screens/sevenDayForecastDetailScreen.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/textStyle.dart';
import 'package:flutter_application_1/widgets/customShimer.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../helper/utils.dart';


class SevenDayForecast extends StatelessWidget {
  const SevenDayForecast({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.calendar),
              const SizedBox(width: 4.0,),
              const Text(
                '7-Day Forecast',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700
                ),
              ),
              const Spacer(),
              Consumer<Weatherprovider>(
                builder: (context,weatherProv, _){
                  return TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      textStyle: mediumText.copyWith(fontSize: 14.0),
                      foregroundColor: primaryBlue,
                    ),
                    onPressed: weatherProv.isLoading
                      ? null
                      : () {
                        Navigator.of(context)
                          .pushNamed(SevenDayForecastDetail.routeName);
                      },
                    child: const Text('more detail ▶'),
                  );
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0,),
        Container(
          child: Consumer<Weatherprovider>(builder: (context, weatherProv, _){
            if(weatherProv.isLoading){
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: 7,
                itemBuilder: (context, index) => CustomShimmer(
                  height: 82.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weatherProv.dailyWeather.length,
              itemBuilder: (context,index){
                final Dailyweather weather = weatherProv.dailyWeather[index];
                return Material(
                  borderRadius: BorderRadius.circular(12.0),
                  color: index.isEven ? backgroundWhite : Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: (){
                      Navigator.of(context).pushNamed(
                        SevenDayForecastDetail.routeName,
                        arguments: index,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/4,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                index ==0 
                                ? 'Today'
                                : DateFormat('EEE').format(weather.date),
                                style: semiboldText,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36.0,
                                height: 36.0,
                                child: Image.asset(
                                  getWeatherImage(weather.weatherCategory),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4.0,),
                              Text(
                                weather.weatherCategory,
                                style: lightText,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width /5,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                weatherProv.isCelsius 
                                  ? '${weather.tempMax.toStringAsFixed(0)}°/${weather.tempMin.toStringAsFixed(0)}°'
                                  : '${weather.tempMax.toFahrenheit().toStringAsFixed(0)}°/${weather.tempMin.toFahrenheit().toStringAsFixed(0)}°',
                                  style: semiboldText,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          }),
        )
      ],
    );
  }
}