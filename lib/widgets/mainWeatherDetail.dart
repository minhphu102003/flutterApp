import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/extentisions.dart';
import 'package:flutter_application_1/theme/textStyle.dart';
import 'package:flutter_application_1/widgets/customShimer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/provider/weatherProvider.dart';
import 'package:flutter_application_1/theme/colors.dart';

import '../helper/utils.dart';

class MainWeatherDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Weatherprovider>(builder: (context, weatherProv, _){
      if(weatherProv.isLoading){
        return CustomShimmer(
          height: 132.0,
          borderRadius: BorderRadius.circular(16.0),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundWhite,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.thermometerSimple,
                        color: Colors.white,
                      ),
                      title: 'Feels Like',
                      data: weatherProv.isCelsius
                      ? '${weatherProv.weather.feelsLike.toStringAsFixed(1)}°'
                      : '${weatherProv.weather.feelsLike.toFahrenheit().toStringAsFixed(1)}°',
                    ),
                    const VerticalDivider(
                      thickness: 1.0,
                      indent: 4.0,
                      endIndent: 4.0,
                      color: backgroundBlue,
                    ),
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.drop,
                        color: Colors.white,
                      ),
                      title: 'Precipitation',
                      data: '${weatherProv.dailyWeather[0].precipitation}',
                    ),
                    const VerticalDivider(
                      thickness: 1.0,
                      indent: 4.0,
                      endIndent: 4.0,
                      color: backgroundBlue,
                    ),
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.sun,
                        color: Colors.white,
                      ),
                      title: 'Rain Volume',
                      data: uviValueToString(
                        weatherProv.dailyWeather[0].rainVolume,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1.0,
              color: backgroundBlue,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.wind,
                      color: Colors.white,
                    ),
                    title: 'Wind',
                    data: '${weatherProv.weather.windSpeed} m/s',
                  ),
                  const VerticalDivider(
                    thickness: 1.0,
                    indent: 4.0,
                    endIndent: 4.0,
                    color: backgroundBlue,
                  ),
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.dropHalfBottom,
                      color: Colors.white,
                    ),
                    title: 'Huminity',
                    data: '${weatherProv.weather.humidity}%',
                  ),
                  const VerticalDivider(
                    thickness: 1.0,
                    indent: 4.0,
                    endIndent: 4.0,
                    color: backgroundBlue,
                  ),
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.cloud,
                      color: Colors.white,
                    ),
                    title: 'Cloudiness',
                    data: '${weatherProv.dailyWeather[0].clouds}%',
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}


class DetailInfoTile extends StatelessWidget{
  final String title;
  final String data;
  final Widget icon;

  const DetailInfoTile({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: primaryBlue, child: icon,),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(child: Text(title, style: lightText,),),
                FittedBox(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1.0),
                    child: Text(
                      data,
                      style: mediumText,
                      maxLines: 1,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}