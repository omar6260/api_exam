import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LoadingPageState extends StatefulWidget {
  const LoadingPageState({super.key});

  @override
  State<LoadingPageState> createState() => _LoadingPageStateState();
}

class _LoadingPageStateState extends State<LoadingPageState> {
  double progress = 0.0;
  List<Map<String, dynamic>> weatherData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        progress += 1 / 60;
        if (progress >= 2.0) {
          timer.cancel();
        } else if (progress % (1 / 6) == 0) {
          int index = (progress / (1 / 6)).round() - 1;
          String cityName;
          switch (index) {
            case 0:
              cityName = 'Rennes';
              break;
            case 1:
              cityName = 'Paris';
              break;
            case 2:
              cityName = 'Nantes';
              break;
            // Add more cities here...
            default:
              cityName = '';
          }
          if (cityName != '') {
            String apiKey = '605b670085b32d7600a26830e92f1584';
            String apiUrl =
                'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
            http.get(Uri.parse(apiUrl)).then((response) {
              if (response.statusCode == 200) {
                setState(() {
                  weatherData.add({
                    'name': cityName,
                  });
                });
              }
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('text'),
      ),
      body: Center(
        // child: LinearProgressIndicator(
        //   backgroundColor: Colors.green,
        //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
        //   value: progress / 100,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 40,
              animation: true,
              lineHeight: 20.0,
              animationDuration: 1000,
              percent: progress,
              center: Text('${(progress * 100).round()}%'),
              barRadius: const Radius.circular(22),
              progressColor: Colors.red,
            )
          ],
        ),
      ),
    );
  }
}
