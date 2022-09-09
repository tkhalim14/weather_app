import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:weatherapp/controller/weather_controller.dart';
import 'package:weatherapp/models/model.dart';
import 'package:weatherapp/util/constants.dart';
import 'package:weatherapp/util/weatherstatus.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

const screenImage = {
  'default': 'images/location_background.jpg',
  'sunrise': 'images/sunrise_time.jpg',
  'morning': 'images/morning_time.jpg',
  'day': 'images/sunny_time.jpg',
  'rainy': 'images/rainy_time.jpeg',
  'sunset': 'images/sunset_time.jpg',
  'winter': 'images/winter_time.jpg',
  'night': 'images/night_time.jpg',
};

class LocationScreen extends StatefulWidget {
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final controller = Get.put(WeatherController());

  final weatherStatus = Get.put(WeatherStatus());

  late int temp = 0;

  AssetImage decideBackground(var hour, var temp) {
    int h = int.parse(hour);
    if (h > 18 || (h >= 0 && h < 5)) {
      keyval = 'night';
    } else if (h == 18) {
      keyval = 'sunset';
    } else if (h < 18 && h >= 12) {
      keyval = 'day';
    } else if (h >= 0 && h < 5) {
      keyval = 'night';
    } else if (h == 5) {
      keyval = 'sunrise';
    } else if (h > 5 && h <= 11) {
      keyval = 'morning';
    }
    late String img_location = screenImage[keyval].toString();
    //print(hour);
    return AssetImage(img_location);
  }

  void _getTime() {
    final String formattedDateTime =
        DateFormat('dd-MM-yyyy \n kk:mm').format(DateTime.now()).toString();

    setState(() {
      _timeString = formattedDateTime;
      hour = getHour(_timeString);
      background = decideBackground(hour, temp);
      // print(background);
    });
  }

  String keyval = 'default';
  late AssetImage background = decideBackground(hour, temp);

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer.periodic(Duration(seconds: 1), (Timer t) => {_getTime()});
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Weather>(
        future: controller.getWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data;
            // var weatherIcon = weatherStatus.getWeatherIcon(data!.cod);
            temp = data!.main.temp.toInt();
            //print(data.name);
            //var t = timeObj._timeString;
            //dd-MM-yyyy \n kk:mm
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: background,
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
                            Icons.cached,
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
                          Text(
                            '${_timeString}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "${temp.toString()}°C",
                                style: kTempTextStyle,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Feels like",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "${data.main.feelsLike.toInt().toString()}°C",
                                    style: kFeelsTextStyle,
                                  ),
                                  Text(
                                    weatherStatus.getWeatherIcon(data.cod!),
                                    style: kConditionTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Seems like there's",
                          ),
                          Text(
                            "${data.weather[0].description.toString()}",
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
                          "${weatherStatus.getMessage(temp)}",
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
