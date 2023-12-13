import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:weatherapp/controller/weather_controller.dart';
import 'package:weatherapp/models/model.dart';
import 'package:weatherapp/util/constants.dart';
import 'package:weatherapp/util/weatherstatus.dart';
// import 'package:weatherapp/util/snackbar.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:weatherapp/util/rotateicon.dart';
import 'package:flutter/services.dart';
import 'package:weatherapp/util/wallpaper_constants.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final controller = Get.put(WeatherController());

  final weatherStatus = Get.put(WeatherStatus());

  static String weather_details = "";

  AssetImage decideBackground(var hour, var weather_details) {
    int h = int.parse(hour);
    // print(weather_details == 'mist');
    if (h > 18 || (h >= 0 && h < 5)) {
      if (weather_details == 'rain') {
        keyval = 'rainy_night';
      } else {
        keyval = 'night';
      }
    } else if (h == 18) {
      keyval = 'sunset';
    } else if (h < 18 && h >= 12) {
      if (weather_details == 'rain') {
        keyval = 'rainy_day';
      } else {
        keyval = 'day';
      }
    } else if (h == 5) {
      keyval = 'sunrise';
    } else if (h > 5 && h <= 11) {
      if (weather_details == 'rain') {
        keyval = 'rainy_day';
      } else {
        keyval = 'morning';
      }
    }
    //print(hour);
    return AssetImage(screenImage[keyval].toString());
  }

  void _getTime() {
    final String formattedDateTime =
        DateFormat('dd-MM-yyyy \n kk:mm').format(DateTime.now()).toString();

    setState(() {
      _timeString = formattedDateTime;
      hour = getHour(_timeString);
      background = decideBackground(hour, weather_details);
    });
  }

  String keyval = 'default';
  late AssetImage background = decideBackground(hour, weather_details);

  String getHour(var t) {
    bool flag = false;
    bool flag1 = false;
    int i = 0;
    var hour = "";
    //var minute = "";
    for (i = 0; i < t.length; i++) {
      if (t[i] == '\n') {
        flag = true;
      }
      if (flag) {
        if (t[i] == ':') {
          flag1 = !flag1;
        }
        if (!flag1) {
          if (t[i] != ' ') hour += t[i];
        } else {
          // if (t[i] != ':') minute += t[i];
        }
      }
    }
    return hour;
  }

  late String _timeString =
      DateFormat('dd-MM-yyyy \n kk:mm').format(DateTime.now()).toString();
  late String hour = '00';

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 30), (Timer t) => {_getTime()});
  }

  void onRefreshButtonPressed() {
    // Implement any logic to refresh location data
    setState(() {
      print('Refreshing....');
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(weather_details);
    return FutureBuilder<Weather>(
      future: controller.getWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // _showSnackbar(snapshot.error.toString());
          return Center(
            // child: Text(snapshot.error.toString()),
            child: Text("Oops! Something went wrong."),
          );
        } else if (snapshot.hasData) {
          var data = snapshot.data;
          // print(data);
          // var weatherIcon = weatherStatus.getWeatherIcon(data!.cod);
          weather_details = data?.weather[0].description.toString() ?? "";
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: background,
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.white, BlendMode.dstATop),
                ),
              ),
              constraints: BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TopBar(onRefreshButtonPressed: onRefreshButtonPressed),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: Column(
                      children: [
                        Text(
                          '${_timeString.split('\n')[1].split(' ')[1]}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_timeString.split('\n')[0]}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data?.main.temp.toInt()}°C",
                                  style: kTempTextStyle,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Feels like",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "${data?.main.feelsLike.toInt()}°C",
                                  style: kFeelsTextStyle,
                                ),
                                Text(
                                  weatherStatus.getWeatherIcon(data?.cod ?? 0),
                                  style: kConditionTextStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Seems like there's",
                        ),
                        Text(
                          "${data?.weather[0].description.toString()}",
                          style: kFeelsTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Color.fromARGB(54, 53, 53, 53),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      child: Text(
                        "${weatherStatus.getMessage(data?.main.temp.toInt() ?? 0)}\n in ${data?.name ?? "unknown"}",
                        textAlign: TextAlign.center,
                        style: kMessageTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return loadingscreen();
        }
      },
    );
  }
}

class loadingscreen extends StatelessWidget {
  const loadingscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        new Positioned(
          right: 98,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios,
                size: 90,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 90,
              ),
            ],
          ),
        ),
        new Positioned(
          child: SpinKitFadingCube(
            color: Colors.white,
            size: 45.0,
          ),
        )
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  final VoidCallback onRefreshButtonPressed;

  const TopBar({Key? key, required this.onRefreshButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [
            Colors.black12.withOpacity(1),
            Colors.black.withOpacity(1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade800,
            blurRadius: 2.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotateIcon(onPressed: onRefreshButtonPressed),
          TextButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            child: const Icon(
              Icons.list,
              color: Color.fromARGB(255, 207, 207, 207),
              size: 40.0,
            ),
          ),
        ],
      ),
    );
  }
}

class appdrawer extends StatelessWidget {
  appdrawer({Key? key}) : super(key: key);

  var suggestions = {
    'rain': [
      'Play a board game!',
      'Have a family movie night.',
      'Get crafty!',
      'Make a pillow fort.',
      'Bake a cake!',
    ],
    'sunny': [
      'Go to a park',
      'Have a picnic',
      'Go for a hike',
      'Ride a Bike',
      'Go Fly a Kite. No, Really.',
    ],
    'cloud': [
      'Make a list',
      'Exercise',
      'Meet up with a friend',
      'Go skating',
      'Perfect time for Netflix'
    ],
    'mist': [
      'Draw smileys on foggy windows',
      'Read',
      'Scare people',
      'Roleplay',
      'Pretend you are Snoop Dogg'
    ],
    'haze': [
      'Stay Indoors',
      'Read',
      'Keep yourself hydrated',
      'Perfect time for cold beverages',
      'Wear shades 😎'
    ],
    'clear sky': [
      'Make a list',
      'Exercise',
      'Meet up with a friend',
      'Go skating',
      'Perfect time for Netflix'
    ],
    'default': [
      'No suggestions available.',
      "Don't forget to smile.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    //print(_LocationScreenState.weather_details);
    final suggestion;
    if (suggestions.containsKey(_LocationScreenState.weather_details)) {
      suggestion = (suggestions[_LocationScreenState.weather_details]);
    } else {
      suggestion = (suggestions['default']);
    }
    return ListView(
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Suggestions :',
                style: TextStyle(fontSize: 30.0, color: Colors.white),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
        ),
        Container(
          height: double.maxFinite,
          child: ListView.builder(
            itemCount: suggestion?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  suggestion?.elementAt(index) ?? 'No suggesion available',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
