import 'package:get/get.dart';
import '../models/model.dart';
import '../services/weather_service.dart';
import '../util/snackbar.dart';

class WeatherController extends GetxController {
  final weatherService = Get.put(WeatherService());

  Future<Weather> getWeatherData() async {
    // ignore: prefer_typing_uninitialized_variables
    // print("Fetch Data");
    var res;
    try {
      res = await weatherService.getWeather();
      if (res.statusCode != 200 || res.statusCode != 201) {
        return WeatherSnackBars.errorSnackBar(message: res.data['message']);
      } else {}
    } catch (e) {
      WeatherSnackBars.errorSnackBar(message: e.toString());
    }
    return Weather.fromJson(res.data);
  }
}
