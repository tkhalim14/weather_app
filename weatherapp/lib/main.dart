import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:weatherapp/controller/weather_controller.dart';
import 'package:weatherapp/models/model.dart';
import 'package:weatherapp/util/constants.dart';
import 'package:weatherapp/util/weatherstatus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LocationScreen(),
    );
  }
}

class TimeData extends StatefulWidget {
  TimeData({Key? key}) : super(key: key);

  @override
  State<TimeData> createState() => _TimeDataState();
}

class _TimeDataState extends State<TimeData> {
  void _getTime() {
    final String formattedDateTime =
        DateFormat('dd-MM-yyyy \n kk:mm').format(DateTime.now()).toString();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  late String _timeString;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_timeString}',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class LocationScreen extends StatelessWidget {
  final controller = Get.put(WeatherController());

  final weatherStatus = Get.put(WeatherStatus());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Weather>(
        future: controller.getWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error.toString()}"),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data;
            var weatherIcon = weatherStatus.getWeatherIcon(data!.cod);

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('images/location_background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.white, BlendMode.dstATop),
                ),
              ),
              constraints: BoxConstraints.expand(),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            controller.getWeatherData();
                          },
                          child: Icon(
                            Icons.near_me,
                            size: 35.0,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Icon(
                            Icons.location_city,
                            size: 35.0,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Column(
                        children: [
                          TimeData(),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "${data.main.temp.toInt().toString()}°C",
                                style: kTempTextStyle,
                              ),
                              Text(
                                weatherStatus.getWeatherIcon(data.cod),
                                style: kConditionTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Feels like",
                          ),
                          Text(
                            "${data.main.feelsLike.toInt().toString()}°C",
                            style: kFeelsTextStyle,
                          )
                        ],
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(100, 53, 53, 53),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          "${weatherStatus.getMessage(data.main.temp.toInt())} in ${data.name}!",
                          textAlign: TextAlign.center,
                          style: kMessageTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: SpinKitDoubleBounce(
              color: Colors.redAccent,
              size: 50.0,
            ),
          );
        },
      ),
    );
  }
}
