import 'package:flutter/material.dart';
import 'package:weatherapp/pages/home.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:weatherapp/controller/weather_controller.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: WeatherAppShell(),
    );
  }
}

class WeatherAppShell extends StatefulWidget {
  WeatherAppShell({Key? key}) : super(key: key);

  @override
  State<WeatherAppShell> createState() => _WeatherAppShellState();
}

class _WeatherAppShellState extends State<WeatherAppShell> {
  int _selectedIndex = 0;

  List<Widget> pageList = [
    LocationScreen(),
    Favorite(),
    Search(),
  ];
  List<String> pageName = [
    'Home',
    'Favorite',
    'Search',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    print("Shell");
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
    print("Shell Exit");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(pageName[_selectedIndex]),
            ),
      endDrawer: _selectedIndex == 0
          ? Drawer(
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              width: 250,
              child: appdrawer(),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: "Search",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: pageList.elementAt(_selectedIndex),
    );
  }
}

class FavouriteList {
  List<Map> FavList = [];

  bool checkIfPresent(String item) {
    for (var element in FavList) {
      if (element['Location'] == item) {
        return true;
      }
    }
    return false;
  }

  void addtoFavList(Map item) {
    for (var element in FavList) {
      if (element['Location'] == item['Location']) {
        return;
      }
    }
    FavList.add(item);
    print(FavList);
  }

  void removefromFavList(Map item) {
    List<Map> NewList = [];
    for (var element in FavList) {
      if (element['Location'] != item['Location']) {
        NewList.add(element);
      }
    }
    FavList = NewList;
    print(FavList);
  }
}

class Favorite extends StatefulWidget {
  Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Map> FavList = Get.put(FavouriteList()).FavList;

  bool checkEmpty = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];

    setState(() {
      FavList = Get.put(FavouriteList()).FavList;
      elements = FavList.map((element) {
        return Column(
          children: [
            FavoriteListTile(
              geoInfo: element['Location'],
            ),
            const Divider(),
          ],
        );
      }).toList();
    });

    return elements.isNotEmpty
        ? Column(
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.star_border_purple500,
                      color: Colors.amber,
                      size: 70,
                    ),
                    Center(
                      child: Text(
                        'Take a look at your saved favorites! 😊',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14.0),
                height: MediaQuery.of(context).size.height * 0.5,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.3,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 66, 66, 66),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: FavList.length, // * 2,
                        itemBuilder: (BuildContext context, int index) {
                          // if (index.isOdd) {
                          //   return const Divider(
                          //     color: Colors.grey,
                          //     thickness: 0.2,
                          //   ); // Add a Divider after every odd index
                          // } else {
                          return FavoriteListTile(
                            geoInfo: FavList[index]['Location'],
                          );
                          // }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const Expanded(
            child: Center(
              child: Text('Hey There! You have no favorites.'),
            ),
          );
    Column(
      children: elements.isEmpty
          ? [
              const Expanded(
                child: Center(
                  child: Text('Hey There! You have no favorites.'),
                ),
              ),
            ]
          : elements,
    );
  }
}

class FavoriteListTile extends StatefulWidget {
  final String geoInfo;
  const FavoriteListTile({super.key, required this.geoInfo});

  @override
  State<FavoriteListTile> createState() => _FavoriteListTileState();
}

class _FavoriteListTileState extends State<FavoriteListTile> {
  String coordinatesDisplay = "Coordinates";
  String latitude = "Latitude";
  String longitude = "Longitude";
  Map results = {"default": "Results"};

  bool isSearch = false;
  bool _isSelected = true;

  Future<void> _searchLocation(String query) async {
    final controller = Get.put(WeatherController());

    try {
      // Use the geocoding function to get a list of addresses based on the query
      final addresses = await Geocoder.local.findAddressesFromQuery(query);

      if (addresses.isNotEmpty) {
        final first = addresses.first;
        final response =
            await controller.getWeatherDataFromLatitudeAndLongitude(
                first.coordinates.latitude ?? 0.00,
                first.coordinates.longitude ?? 0.00);

        setState(() {
          // Update the result with latitude and longitude
          latitude = first.coordinates.latitude.toString();
          longitude = first.coordinates.longitude.toString();
          coordinatesDisplay =
              '${first.coordinates.latitude!.toStringAsFixed(3)}° N , ${first.coordinates.longitude!.toStringAsFixed(3)}° E';
          var responseJson = response.toJson();
          print(responseJson);
          results = {
            'Temperature': "${responseJson['main']['temp']} °C",
            'Humidity': "${responseJson['main']['humidity']} %",
            'Wind speed':
                "${responseJson['wind']['speed']} m/s at ${responseJson['wind']['deg']}°",
            'Type': responseJson['weather'][0]['description'],
            'Pressure': "${responseJson['main']['pressure']} hPa",
          };
          // print(results);
        });
      } else {
        setState(() {
          coordinatesDisplay = 'No results found';
        });
      }
    } catch (error) {
      setState(() {
        coordinatesDisplay = 'Error: $error';
      });
    }
  }

  final favcontroller = Get.put(FavouriteList());

  @override
  void initState() {
    super.initState();
    _searchLocation(widget.geoInfo);
  }

  @override
  Widget build(BuildContext context) {
    return _isSelected
        ? ListTile(
            title: Text("${widget.geoInfo}   ${coordinatesDisplay}"),
            subtitle: Text(
                "Temperature: ${results['Temperature']}\nHumidity: ${results['Humidity']}\nForecast: ${results['Type']}\nWind Speed: ${results['Wind speed']}"),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite_rounded,
                color: _isSelected == false ? Colors.white : Colors.red,
              ),
              isSelected: _isSelected,
              onPressed: () => {
                setState(() {
                  if (_isSelected == false) {
                    _isSelected = true;
                    favcontroller.addtoFavList({
                      "Location": widget.geoInfo,
                      "Latitude": latitude,
                      "Longitude": longitude,
                    });
                  } else {
                    _isSelected = false;
                    favcontroller.removefromFavList({
                      "Location": widget.geoInfo,
                      "Latitude": latitude,
                      "Longitude": longitude,
                    });
                  }
                }),
              },
            ),
          )
        : const Text("");
  }
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<String> searchTiles = [
    'Mumbai',
    'Chicago',
    'Chennai',
    'Pune',
    'Bangalore',
    'Andhra Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat'
  ];

  String outputData = "Output Area";
  String coordinatesDisplay = "Coordinates";
  String latitude = "Latitude";
  String longitude = "Longitude";
  Map results = {"default": "Results"};

  bool isSearch = false;
  bool _isSelected = false;

  Future<void> _searchLocation(String query) async {
    final controller = Get.put(WeatherController());

    try {
      // Use the geocoding function to get a list of addresses based on the query
      final addresses = await Geocoder.local.findAddressesFromQuery(query);

      if (addresses.isNotEmpty) {
        final first = addresses.first;
        final response =
            await controller.getWeatherDataFromLatitudeAndLongitude(
                first.coordinates.latitude ?? 0.00,
                first.coordinates.longitude ?? 0.00);

        setState(() {
          // Update the result with latitude and longitude
          latitude = first.coordinates.latitude.toString();
          longitude = first.coordinates.longitude.toString();
          coordinatesDisplay =
              '${first.coordinates.latitude!.toStringAsFixed(3)}° N , ${first.coordinates.longitude!.toStringAsFixed(3)}° E';
          var responseJson = response.toJson();
          print(responseJson);
          results = {
            'Temperature': "${responseJson['main']['temp']} °C",
            'Humidity': "${responseJson['main']['humidity']} %",
            'Wind speed':
                "${responseJson['wind']['speed']} m/s at ${responseJson['wind']['deg']}°",
            'Type': responseJson['weather'][0]['description'],
            'Pressure': "${responseJson['main']['pressure']} hPa",
          };
          // print(results);
        });
      } else {
        setState(() {
          coordinatesDisplay = 'No results found';
        });
      }
    } catch (error) {
      setState(() {
        coordinatesDisplay = 'Error: $error';
      });
    }
  }

  final favcontroller = Get.put(FavouriteList());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              Future<void> onTapped(String item) async {
                setState(() {
                  outputData = item;
                  isSearch = true;
                  _isSelected = favcontroller.checkIfPresent(item);
                });
                await _searchLocation(item);
              }

              return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      outputData = value;
                      isSearch = true;
                      _isSelected = favcontroller.checkIfPresent(value);
                      print(outputData);
                    });
                    onTapped(value);
                  },
                  leading: Tooltip(
                    message: 'Suggested places to search',
                    child: IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: (() {
                        controller.openView();
                      }),
                    ),
                  ),
                  trailing: [
                    Tooltip(
                      message: 'Search',
                      child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: (() {
                          setState(() {
                            outputData = controller.text;
                            isSearch = true;
                            _isSelected =
                                favcontroller.checkIfPresent(controller.text);
                            print(outputData);
                          });
                          onTapped(controller.text);
                        }),
                      ),
                    ),
                  ]);
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              Future<void> tapped(String item) async {
                setState(() {
                  outputData = item;
                  isSearch = true;
                  _isSelected = favcontroller.checkIfPresent(item);
                });
                await _searchLocation(item);
              }

              return searchTiles.map((String item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                      tapped(item);
                    });
                  },
                );
              });
            },
          ),
          isSearch
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("${outputData}   ${coordinatesDisplay}"),
                        subtitle: Text(
                            "Temperature: ${results['Temperature']}\nHumidity: ${results['Humidity']}\nForecast: ${results['Type']}\nWind Speed: ${results['Wind speed']}"),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.favorite_rounded,
                            color: _isSelected == false
                                ? Colors.white
                                : Colors.red,
                          ),
                          isSelected: _isSelected,
                          onPressed: () => {
                            setState(() {
                              if (_isSelected == false) {
                                _isSelected = true;
                                favcontroller.addtoFavList({
                                  "Location": outputData,
                                  "Latitude": latitude,
                                  "Longitude": longitude,
                                });
                              } else {
                                _isSelected = false;
                                favcontroller.removefromFavList({
                                  "Location": outputData,
                                  "Latitude": latitude,
                                  "Longitude": longitude
                                });
                              }
                            }),
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text("Search location"),
                  ),
                ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatefulWidget {
  final Function addtoFavList, removefromFavList;
  final String text;
  const CustomIconButton(
      {super.key,
      required this.addtoFavList,
      required this.removefromFavList,
      required this.text});

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = false;
  }

  @override
  dispose() {
    super.dispose();
    _isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.favorite_rounded,
        color: _isSelected == false ? Colors.white : Colors.red,
      ),
      isSelected: _isSelected,
      onPressed: () => {
        setState(() {
          if (_isSelected == false) {
            _isSelected = true;
            widget.addtoFavList(widget.text);
          } else {
            _isSelected = false;
            widget.removefromFavList(widget.text);
          }
        }),
      },
    );
  }
}
