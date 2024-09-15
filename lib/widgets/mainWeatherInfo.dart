import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/extentisions.dart';
import 'package:flutter_application_1/helper/utils.dart';
import 'package:flutter_application_1/provider/weatherProvider.dart';
import 'package:flutter_application_1/theme/textStyle.dart';
import 'package:provider/provider.dart';

import 'customShimer.dart';

class MainWeatherInfor extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Consumer<Weatherprovider>(builder: (context, weeatherProv, _){
      if(weeatherProv.isLoading){
        return const  Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CustomShimmer(
                height: 148.0,
                width: 148.0,
              ),
            ),
            SizedBox(width: 16.0,),
            CustomShimmer(
              height: 148.0,
              width: 148.0,
            )
          ],
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            weeatherProv.isCelsius
                              ? weeatherProv.weather.temp.toStringAsFixed(1)
                              : weeatherProv.weather.temp
                                .toFahrenheit()
                                .toStringAsFixed(1),
                            style: boldText.copyWith(fontSize: 86),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            weeatherProv.measurementUnit,
                            style: mediumText.copyWith(fontSize: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    weeatherProv.weather.description.toTitleCase(),
                    style: lightText.copyWith(fontSize: 16),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 148.0,
              width: 148.0,
              child: Image.asset(
                getWeatherImage(weeatherProv.weather.weatherCategory),
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      );
    });
  }

}