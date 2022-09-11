class WeatherStatus {
  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'SummerTime 😎';
    } else if (temp <= 20 && temp > 10) {
      return 'Maybe consider wearing a 🧥';
    } else if (temp <= 10) {
      return 'It\'s too damn chilly.\n🧣 & 🧤 time';
    } else {
      return 'Oopsie, error in temperature info 😅';
    }
  }
}
