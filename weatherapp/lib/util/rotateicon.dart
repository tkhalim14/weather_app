import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weatherapp/controller/weather_controller.dart';

class RotateIcon extends StatefulWidget {
  const RotateIcon({Key? key}) : super(key: key);

  @override
  _RotateIconState createState() => _RotateIconState();
}

class _RotateIconState extends State<RotateIcon>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(WeatherController());
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool toggle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            controller.getWeatherData();
            if (_controller.isDismissed) {
              _controller.forward();
            }
            // //toggle = !toggle;
            // //print(toggle);
            // //if (toggle == true) {
            //}
          },
          child: RotationTransition(
            turns: _animation,
            child: const Icon(
              Icons.cached,
              size: 35,
            ),
          ),
        )
      ],
    );
  }
}
