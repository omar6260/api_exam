import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressIncator extends StatefulWidget {
  const ProgressIncator({Key? key}) : super(key: key);
  @override
  _ProgressIncatorState createState() => _ProgressIncatorState();
}

class _ProgressIncatorState extends State<ProgressIncator> {
  double _progress = 0.0;
  List<Map<String, dynamic>> citiesWeather = [];
  List<String> cities = ['RENNES', 'PARIS', 'NANTES', 'BORDEAUX', 'LYON'];
  List<String> messages = [
    'Téléchargeons les données...',
    'En cours...',
    'Vous aurez les résultats bientot ...'
  ];
  int messageIndex = 0;
  Timer? timer;
  bool _downloadFinished = false;

  @override
  void initState() {
    super.initState();
    _updateProgress();
    startTimer();
  }

  void _updateProgress() async {
    for (var i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _progress = (i + 1) * (100 / 60);
      });
    }
    setState(() {
      _downloadFinished = true;
    });
  }

  Future<Map<String, dynamic>> getWeather(String city) async {
    String apiKey = '605b670085b32d7600a26830e92f1584';
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data for $city');
    }
  }

  void printWeatherDataForOneCity(String cityName) async {
    final weatherData = await getWeather(cityName);
    setState(() {
      citiesWeather.add(weatherData);
    });
  }

  void startTimer() {
    int x = 0;
    timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (x == 4) timer.cancel();
      printWeatherDataForOneCity(cities[x]);
      x = x + 1;
      setState(() {
        messageIndex = (messageIndex + 1) % messages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/weather.png",
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                messages[messageIndex],
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 40,
                animation: true,
                lineHeight: 20.0,
                animationDuration: 1000,
                percent: _progress / 100,
                center: Text('${_progress.round()}%'),
                barRadius: const Radius.circular(22),
                progressColor: Colors.blue,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: citiesWeather.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityName = citiesWeather[index]['name'];
                      final temp = citiesWeather[index]['main']['temp'];
                      final humidity = citiesWeather[index]['main']['humidity'];
                      final feelsLike =
                          citiesWeather[index]['main']['feels_like'];
                      final pressure = citiesWeather[index]['main']['pressure'];
                      final iconCode =
                          citiesWeather[index]['weather'][0]['icon'];
                      return Card(
                        child: ListTile(
                          title: Text(
                              '$cityName: temp: $temp°C humidity $humidity feels_like :$feelsLike pressure:$pressure'),
                        ),
                      );
                    }),
              ),
              if (_downloadFinished)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _progress = 0.0;
                        citiesWeather = [];
                        _downloadFinished = false;
                      });
                      startTimer();
                      _updateProgress();
                    },
                    child: const Text(
                      'Recommencer',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
            ]),
      ),
    );
  }
}
